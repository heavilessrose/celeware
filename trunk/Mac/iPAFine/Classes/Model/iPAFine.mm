

#import "AppDelegate.h"


@implementation iPAFine

//
- (NSString *)doTask:(NSString *)path arguments:(NSArray *)arguments currentDirectory:(NSString *)currentDirectory
{
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = path;
	task.arguments = arguments;
	if (currentDirectory) task.currentDirectoryPath = currentDirectory;
	
	NSPipe *pipe = [NSPipe pipe];
	task.standardOutput = pipe;
	task.standardError = pipe;
	
	NSFileHandle *file = [pipe fileHandleForReading];
	
	[task launch];
	
	NSData *data = [file readDataToEndOfFile];
	NSString *result = data.length ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : nil;

	NSLog(@"CMD:\n%@\n%@ARG\n\n%@\n\n", path, arguments, (result ? result : @""));
	return result;
}


//
- (NSString *)doTask:(NSString *)path arguments:(NSArray *)arguments
{
	return [self doTask:path arguments:arguments currentDirectory:nil];
}

//
- (NSString *)unzipIPA:(NSString *)ipaPath workPath:(NSString *)workPath
{
	NSString *result = [self doTask:@"/usr/bin/unzip" arguments:[NSArray arrayWithObjects:@"-q", ipaPath, @"-d", workPath, nil]];
	NSString *payloadPath = [workPath stringByAppendingPathComponent:@"Payload"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:payloadPath])
	{
		NSArray *dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:payloadPath error:nil];
		for (NSString *dir in dirs)
		{
			if ([dir.pathExtension.lowercaseString isEqualToString:@"app"])
			{
				return [payloadPath stringByAppendingPathComponent:dir];
			}
		}
		_error = @"Invalid app";
		return nil;
	}
	_error = [@"Unzip filed:" stringByAppendingString:result ? result : @""];
	return nil;
}

//
- (NSString *)renameApp:(NSString *)appPath ipaPath:(NSString *)ipaPath
{
	// 获取显示名称
	NSString *DISPNAME = ipaPath.lastPathComponent.stringByDeletingPathExtension;

	NSRange range = [DISPNAME rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"_- "]];
	if (range.location != NSNotFound)
	{
		DISPNAME = [DISPNAME substringToIndex:range.location];
	}
	
	if ([DISPNAME hasSuffix:@"HD"]) DISPNAME = [DISPNAME substringToIndex:DISPNAME.length - 2];
	
	if ([DISPNAME hasPrefix:@"iOS."]) DISPNAME = [DISPNAME substringFromIndex:4];
	else if ([DISPNAME hasPrefix:@"iPad."]) DISPNAME = [DISPNAME substringFromIndex:5];
	else if ([DISPNAME hasPrefix:@"iPhone."]) DISPNAME = [DISPNAME substringFromIndex:7];
	
	//
	NSString *infoPath = [appPath stringByAppendingPathComponent:@"Info.plist"];
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath];
	
	// 获取程序类型
	NSArray *devices = [info objectForKey:@"UIDeviceFamily"];
	NSUInteger family = 0;
	for (id device in devices) family += [device intValue];
	NSString *PREFIX = (family == 3) ? @"iOS" : ((family == 2) ? @"iPad" : @"iPhone");
	
	// 修改显示名称
	//[info setObject:DISPNAME forKey:@"CFBundleDisplayName"];
	//[info writeToFile:infoPath atomically:YES];
	NSString *localizePath = [appPath stringByAppendingPathComponent:@"zh_CN/InfoPlist.string"];
	NSMutableDictionary *localize = [NSMutableDictionary dictionaryWithContentsOfFile:localizePath];
	if (localize == nil) localize = [NSMutableDictionary dictionary];
	{
		[localize setObject:DISPNAME forKey:@"CFBundleDisplayName"];
		[localize writeToFile:localizePath atomically:YES];
	}
	
	// 修改 iTunes 项目名称
	NSString *metaPath = [[[appPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"iTunesMetadata.plist"];
	NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithContentsOfFile:metaPath];
	if (meta)
	{
		[meta setObject:DISPNAME forKey:@"playlistName"];
		[meta setObject:DISPNAME forKey:@"itemName"];
		[meta writeToFile:metaPath atomically:YES];
	}
	
	//
	NSString *VERSION = meta ? [meta objectForKey:@"bundleShortVersionString"] : nil;
	if (VERSION.length == 0) VERSION = [info objectForKey:@"CFBundleVersion"];
	if (VERSION.length == 0) VERSION = [info objectForKey:@"CFBundleShortVersionString"];

	return [NSString stringWithFormat:@"%@/%@.%@_%@.ipa", ipaPath.stringByDeletingLastPathComponent, PREFIX, DISPNAME, VERSION];
}

//
- (void)checkProv:(NSString *)appPath provPath:(NSString *)provPath
{
	// Check
	NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:provPath encoding:NSASCIIStringEncoding error:nil];
	NSArray* embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	for (int i = 0; i <= [embeddedProvisioningLines count]; i++)
	{
		if ([[embeddedProvisioningLines objectAtIndex:i] rangeOfString:@"application-identifier"].location != NSNotFound)
		{
			NSInteger fromPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"<string>"].location + 8;
			NSInteger toPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"</string>"].location;
			
			NSRange range;
			range.location = fromPosition;
			range.length = toPosition - fromPosition;
			
			NSString *identifier = [[embeddedProvisioningLines objectAtIndex:i+1] substringWithRange:range];
			if (![identifier hasSuffix:@".*"])
			{
				NSRange range = [identifier rangeOfString:@"."];
				if (range.location != NSNotFound) identifier = [identifier substringFromIndex:range.location + 1];
				
				NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[appPath stringByAppendingPathComponent:@"Info.plist"]];
				if (![[info objectForKey:@"CFBundleIdentifier"] isEqualToString:identifier])
				{
					_error = @"Identifiers match";
					return;
				}
			}
			return;
		}
	}
	_error = @"Invalid prov";
}

//
- (void)provApp:(NSString *)appPath provPath:(NSString *)provPath
{
	NSString *targetPath = [appPath stringByAppendingPathComponent:@"embedded.mobileprovision"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath])
	{
		NSLog(@"Found embedded.mobileprovision, deleting.");
		[[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
	}
	
	NSString *result = [self doTask:@"/bin/cp" arguments:[NSArray arrayWithObjects:provPath, targetPath, nil]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:targetPath])
	{
		_error = [@"Product identifiers don't match: " stringByAppendingString:result ? result : @""];
	}
}

//
- (void)signApp:(NSString *)appPath certName:(NSString *)certName
{
	NSString *resourceRulesPath = [[NSBundle mainBundle] pathForResource:@"ResourceRules" ofType:@"plist"];
	NSString *resourceRulesArgument = [NSString stringWithFormat:@"--resource-rules=%@",resourceRulesPath];
	
	NSString *result = [self doTask:@"/usr/bin/codesign" arguments:[NSArray arrayWithObjects:@"-fs", certName, resourceRulesArgument, appPath, nil]];
	
	result = [self doTask:@"/usr/bin/codesign" arguments:[NSArray arrayWithObjects:@"-v", appPath, nil]];
	if (result)
	{
		_error = [@"Sign error: " stringByAppendingString:result];
	}
}

- (void)zipIPA:(NSString *)workPath outPath:(NSString *)outPath
{
	//TODO: Current Dir Error
	/*NSString *result = */[self doTask:@"/usr/bin/zip" arguments:[NSArray arrayWithObjects:@"-qr", outPath, @".", nil] currentDirectory:workPath];
	[[NSFileManager defaultManager] removeItemAtPath:workPath error:nil];
}

// 
- (void)refineIPA:(NSString *)ipaPath certName:(NSString *)certName provPath:(NSString *)provPath
{
	// 
	NSString *workPath = ipaPath.stringByDeletingPathExtension;//[NSTemporaryDirectory() stringByAppendingPathComponent:@"CeleWare.iPAFine"];
	
	NSLog(@"Setting up working directory in %@",workPath);
	[[NSFileManager defaultManager] removeItemAtPath:workPath error:nil];
	[[NSFileManager defaultManager] createDirectoryAtPath:workPath withIntermediateDirectories:TRUE attributes:nil error:nil];
	
	// Unzip
	_error = nil;
	NSString *appPath = [self unzipIPA:ipaPath workPath:workPath];
	if (_error) return;

	//
	NSString *outPath = [self renameApp:appPath ipaPath:ipaPath];
	
	// Provision
	if (provPath)
	{
		[self provApp:appPath provPath:provPath];
		if (_error) return;
	}
	
	// Sign
	[self signApp:appPath certName:certName];
	if (_error) return;

	//
	[self zipIPA:workPath outPath:outPath];
}

//
- (NSString *)refine:(NSString *)ipaPath certName:(NSString *)certName provPath:(NSString *)provPath
{
	_error = nil;
	BOOL isDir = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:ipaPath isDirectory:&isDir])
	{
		if (isDir)
		{
			NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ipaPath error:nil];
			for (NSString *file in files)
			{
				if ([file.pathExtension.lowercaseString isEqualToString:@"ipa"])
				{
					[self refineIPA:[ipaPath stringByAppendingPathComponent:file] certName:certName provPath:provPath];
				}
			}
		}
		else if ([ipaPath.pathExtension.lowercaseString isEqualToString:@"ipa"])
		{
			[self refineIPA:ipaPath certName:certName provPath:provPath];
		}
		else
		{
			_error = NSLocalizedString(@"You must choose an IPA file.", @"必须选择 IPA 文件。");
		}
	}
	else
	{
		// Multi files?
		_error = @"Path not found";
	}
	return _error;
}

@end

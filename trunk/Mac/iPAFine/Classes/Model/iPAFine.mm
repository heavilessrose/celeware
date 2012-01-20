

#import "AppDelegate.h"


@implementation iPAFine
@synthesize workingPath;

// 
- (void)launchResign:(NSString *)path
{
	codesigningResult = nil;
	verificationResult = nil;
	originalIpaPath = [path retain];
	workingPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"CeleWare.iPAFine"] retain];
	
	[self disableControls];
	
	NSLog(@"Setting up working directory in %@",workingPath);
	[statusLabel setStringValue:@"Setting up working directory"];
	
	[[NSFileManager defaultManager] removeItemAtPath:workingPath error:nil];
	
	[[NSFileManager defaultManager] createDirectoryAtPath:workingPath withIntermediateDirectories:TRUE attributes:nil error:nil];
	
	if (originalIpaPath && [originalIpaPath length] > 0) {
		NSLog(@"Unzipping %@",originalIpaPath);
		[statusLabel setStringValue:@"Extracting original app"];
	}
	
	unzipTask = [[NSTask alloc] init];
	[unzipTask setLaunchPath:@"/usr/bin/unzip"];
	[unzipTask setArguments:[NSArray arrayWithObjects:@"-q", originalIpaPath, @"-d", workingPath, nil]];
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkUnzip:) userInfo:nil repeats:TRUE];
	
	[unzipTask launch];
}

//
- (void)nextResign
{
	while (_current < _files.count)
	{
		NSString *file = [_files objectAtIndex:_current++];
		NSString *resigned = [[file stringByDeletingPathExtension] stringByAppendingString:@"-resigned.ipa"];
		resigned = [[pathField stringValue] stringByAppendingPathComponent:resigned];
		if ([[[file pathExtension] lowercaseString] isEqualToString:@"ipa"] &&
			([file rangeOfString:@"resigned"].location == NSNotFound) &&
			![[NSFileManager defaultManager] fileExistsAtPath:resigned])
		{
			NSString *path = [[[pathField stringValue] stringByAppendingPathComponent:file] retain];	// Yonsm: BUG need retain?
			NSLog(@"Launch IPA %@", path);
			[self launchResign:path];
			break;
		}
	}
}

//
- (IBAction)resign:(id)sender
{
	//Save cert name
	[defaults setValue:[certField stringValue] forKey:@"CERT_NAME"];
	[defaults setValue:[provisioningPathField stringValue] forKey:@"MOBILEPROVISION_PATH"];
	[defaults synchronize];

	NSString *path = [pathField stringValue];
	if ([[[path pathExtension] lowercaseString] isEqualToString:@"ipa"])
	{
		[self launchResign:path];
	}
	else
	{
		
		// Added By Yonsm
		BOOL isDir = NO;
		if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
		{
			//files
			_current = 0;
			[_files release];
			_files = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil] retain];
			[self nextResign];
			return;
		}
		// Ended By Yonsm
		
		NSRunAlertPanel(@"Error", 
						@"You must choose an *.ipa file",
						@"OK",nil,nil);
		[self enableControls];
		[statusLabel setStringValue:@"Please try again"];
	}
}

//
- (void)checkUnzip:(NSTimer *)timer
{
	if ([unzipTask isRunning] == 0)
	{
		[timer invalidate];
		[unzipTask release];
		unzipTask = nil;
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[workingPath stringByAppendingPathComponent:@"Payload"]])
		{
			NSLog(@"Unzipping done");
			[statusLabel setStringValue:@"Original app extracted"];
			if ([[provisioningPathField stringValue] isEqualTo:@""])
			{
				[self doCodeSigning];
			}
			else
			{
				[self doProvisioning];
			}
		}
		else
		{
			NSRunAlertPanel(@"Error", 
							@"Unzip failed",
							@"OK",nil,nil);
			[self enableControls];
			[statusLabel setStringValue:@"Ready"];
		}
	}
}

//
- (void)doProvisioning {
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[workingPath stringByAppendingPathComponent:@"Payload"] error:nil];
	
	for (NSString *file in dirContents)
	{
		if ([[[file pathExtension] lowercaseString] isEqualToString:@"app"])
		{
			appPath = [[workingPath stringByAppendingPathComponent:@"Payload"] stringByAppendingPathComponent:file];
			if ([[NSFileManager defaultManager] fileExistsAtPath:[appPath stringByAppendingPathComponent:@"embedded.mobileprovision"]])
			{
				NSLog(@"Found embedded.mobileprovision, deleting.");
				[[NSFileManager defaultManager] removeItemAtPath:[appPath stringByAppendingPathComponent:@"embedded.mobileprovision"] error:nil];
			}
			break;
		}
	}
	
	NSString *targetPath = [appPath stringByAppendingPathComponent:@"embedded.mobileprovision"];
	
	provisioningTask = [[NSTask alloc] init];
	[provisioningTask setLaunchPath:@"/bin/cp"];
	[provisioningTask setArguments:[NSArray arrayWithObjects:[provisioningPathField stringValue], targetPath, nil]];
	
	[provisioningTask launch];
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkProvisioning:) userInfo:nil repeats:TRUE];
}

- (void)checkProvisioning:(NSTimer *)timer
{
	if ([provisioningTask isRunning] == 0)
	{
		[timer invalidate];
		[provisioningTask release];
		provisioningTask = nil;
		
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[workingPath stringByAppendingPathComponent:@"Payload"] error:nil];
		
		for (NSString *file in dirContents) {
			if ([[[file pathExtension] lowercaseString] isEqualToString:@"app"])
			{
				appPath = [[workingPath stringByAppendingPathComponent:@"Payload"] stringByAppendingPathComponent:file];
				if ([[NSFileManager defaultManager] fileExistsAtPath:[appPath stringByAppendingPathComponent:@"embedded.mobileprovision"]])
				{
					
					BOOL identifierOK = FALSE;
					NSString *identifierInProvisioning = @"";
					
					NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:[appPath stringByAppendingPathComponent:@"embedded.mobileprovision"] encoding:NSASCIIStringEncoding error:nil];
					NSArray* embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:
														  [NSCharacterSet newlineCharacterSet]];
					
					for (int i = 0; i <= [embeddedProvisioningLines count]; i++)
					{
						if ([[embeddedProvisioningLines objectAtIndex:i] rangeOfString:@"application-identifier"].location != NSNotFound) {
							
							NSInteger fromPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"<string>"].location + 8;
							
							NSInteger toPosition = [[embeddedProvisioningLines objectAtIndex:i+1] rangeOfString:@"</string>"].location;
							
							NSRange range;
							range.location = fromPosition;
							range.length = toPosition-fromPosition;
							
							NSString *fullIdentifier = [[embeddedProvisioningLines objectAtIndex:i+1] substringWithRange:range];
							
							NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
							
							if ([[identifierComponents lastObject] isEqualTo:@"*"]) {
								identifierOK = TRUE;
							}
							
							for (int i = 1; i < [identifierComponents count]; i++) {
								identifierInProvisioning = [identifierInProvisioning stringByAppendingString:[identifierComponents objectAtIndex:i]];
								if (i < [identifierComponents count]-1) {
									identifierInProvisioning = [identifierInProvisioning stringByAppendingString:@"."];
								}
							}
							break;
						}
					}
					
					NSLog(@"Mobileprovision identifier: %@",identifierInProvisioning);
					
					NSString *infoPlist = [NSString stringWithContentsOfFile:[appPath stringByAppendingPathComponent:@"Info.plist"] encoding:NSASCIIStringEncoding error:nil];
					if ([infoPlist rangeOfString:identifierInProvisioning].location != NSNotFound)
					{
						NSLog(@"Identifiers match");
						identifierOK = TRUE;
					}
					
					if (identifierOK)
					{
						NSLog(@"Provisioning completed.");
						[statusLabel setStringValue:@"Provisioning completed"];
						[self doCodeSigning];
					}
					else
					{
						NSRunAlertPanel(@"Error",
										@"Product identifiers don't match",
										@"OK",nil,nil);
						[self enableControls];
						[statusLabel setStringValue:@"Ready"];
					}
				}
				else
				{
					NSRunAlertPanel(@"Error",
									@"Provisioning failed",
									@"OK",nil,nil);
					[self enableControls];
					[statusLabel setStringValue:@"Ready"];
				}
				break;
			}
		}
	}
}

//
- (void)doRefine
{
	// 获取显示名称
	NSString *DISPNAME = originalIpaPath.lastPathComponent.stringByDeletingPathExtension;
	
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
	NSString *VERSION = meta ? [meta objectForKey:@"bundleVersion"] : nil;
	if (VERSION.length == 0) VERSION = [info objectForKey:@"CFBundleVersion"];
	if (VERSION.length == 0) VERSION = [info objectForKey:@"CFBundleShortVersionString"];

	[fileName release];
	fileName = [[NSString alloc] initWithFormat:@"%@.%@_%@.ipa", PREFIX, DISPNAME, VERSION];
	NSLog(@"RENAME: %@", fileName);
}

//
- (void)doCodeSigning
{
	appPath = nil;
	
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[workingPath stringByAppendingPathComponent:@"Payload"] error:nil];
	
	for (NSString *file in dirContents)
	{
		if ([[[file pathExtension] lowercaseString] isEqualToString:@"app"]) 
		{
			appPath = [[workingPath stringByAppendingPathComponent:@"Payload"] stringByAppendingPathComponent:file];
			NSLog(@"Found %@",appPath);
			appName = [file retain];
			[statusLabel setStringValue:[NSString stringWithFormat:@"Codesigning %@",file]];
			break;
		}
	}
	
	if (appPath)
	{
		[self doRefine];
		
		NSString *resourceRulesPath = [[NSBundle mainBundle] pathForResource:@"ResourceRules" ofType:@"plist"];
		NSString *resourceRulesArgument = [NSString stringWithFormat:@"--resource-rules=%@",resourceRulesPath];
		
		codesignTask = [[NSTask alloc] init];
		[codesignTask setLaunchPath:@"/usr/bin/codesign"];
		[codesignTask setArguments:[NSArray arrayWithObjects:@"-fs", [certField stringValue], resourceRulesArgument, appPath, nil]];
		
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkCodesigning:) userInfo:nil repeats:TRUE];
		
		[appPath retain];
		
		NSPipe *pipe=[NSPipe pipe];
		[codesignTask setStandardOutput:pipe];
		[codesignTask setStandardError:pipe];
		NSFileHandle *handle=[pipe fileHandleForReading];
		
		[codesignTask launch];
		
		[NSThread detachNewThreadSelector:@selector(watchCodesigning:)
								 toTarget:self withObject:handle];
	}
}

- (void)watchCodesigning:(NSFileHandle*)streamHandle
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	
	codesigningResult = [[NSString alloc] initWithData:[streamHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
	
	[pool release];
}

- (void)checkCodesigning:(NSTimer *)timer
{
	if ([codesignTask isRunning] == 0)
	{
		[timer invalidate];
		[codesignTask release];
		codesignTask = nil;
		NSLog(@"Codesigning done");
		[statusLabel setStringValue:@"Codesigning completed"];
		[self doVerifySignature];
	}
}

- (void)doVerifySignature
{
	if (appPath)
	{
		verifyTask = [[NSTask alloc] init];
		[verifyTask setLaunchPath:@"/usr/bin/codesign"];
		[verifyTask setArguments:[NSArray arrayWithObjects:@"-v", appPath, nil]];
		
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkVerificationProcess:) userInfo:nil repeats:TRUE];
		
		NSLog(@"Verifying %@",appPath);
		[statusLabel setStringValue:[NSString stringWithFormat:@"Verifying %@",appName]];
		
		NSPipe *pipe=[NSPipe pipe];
		[verifyTask setStandardOutput:pipe];
		[verifyTask setStandardError:pipe];
		NSFileHandle *handle=[pipe fileHandleForReading];
		
		[verifyTask launch];
		
		[NSThread detachNewThreadSelector:@selector(watchVerificationProcess:)
								 toTarget:self withObject:handle];
	}
}

- (void)watchVerificationProcess:(NSFileHandle*)streamHandle
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	
	verificationResult = [[NSString alloc] initWithData:[streamHandle readDataToEndOfFile] encoding:NSASCIIStringEncoding];
	
	[pool release];
}

- (void)checkVerificationProcess:(NSTimer *)timer
{
	if ([verifyTask isRunning] == 0)
	{
		[timer invalidate];
		[verifyTask release];
		verifyTask = nil;
		if ([verificationResult length] == 0)
		{
			NSLog(@"Verification done");
			[statusLabel setStringValue:@"Verification completed"];
			[self doZip];
		}
		else
		{
			NSString *error = [[codesigningResult stringByAppendingString:@"\n\n"] stringByAppendingString:verificationResult];
			NSRunAlertPanel(@"Signing failed", error, @"OK",nil, nil);
			[self enableControls];
			[statusLabel setStringValue:@"Please try again"];
		}
	}
}

- (void)doZip
{
	if (appPath)
	{
		NSArray *destinationPathComponents = [originalIpaPath pathComponents];
		NSString *destinationPath = @"";
		
		for (int i = 0; i < ([destinationPathComponents count]-1); i++)
		{
			destinationPath = [destinationPath stringByAppendingPathComponent:[destinationPathComponents objectAtIndex:i]];
		}
		
		destinationPath = [destinationPath stringByAppendingPathComponent:fileName];
		
		NSLog(@"Dest: %@",destinationPath);
		
		zipTask = [[NSTask alloc] init];
		[zipTask setLaunchPath:@"/usr/bin/zip"];
		[zipTask setCurrentDirectoryPath:workingPath];
		[zipTask setArguments:[NSArray arrayWithObjects:@"-qr", destinationPath, @".", nil]];
		
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkZip:) userInfo:nil repeats:TRUE];
		
		NSLog(@"Zipping %@", destinationPath);
		[statusLabel setStringValue:[NSString stringWithFormat:@"Saving %@",fileName]];
		
		[zipTask launch];
	}
}

//
- (void)checkZip:(NSTimer *)timer
{
	if ([zipTask isRunning] == 0)
	{
		[timer invalidate];
		[zipTask release];
		zipTask = nil;
		NSLog(@"Zipping done");
		[statusLabel setStringValue:[NSString stringWithFormat:@"Saved %@",fileName]];
		
		[[NSFileManager defaultManager] removeItemAtPath:workingPath error:nil];
		
		[appPath release];
		[workingPath release];
		[self enableControls];
		
		NSString *result = [[codesigningResult stringByAppendingString:@"\n\n"] stringByAppendingString:verificationResult];
		NSLog(@"Codesigning result: %@",result);
		
		// Added By Yonsm
		[self performSelectorOnMainThread:@selector(nextResign) withObject:nil waitUntilDone:NO];
		// Ended By Yonsm
	}
}

//
- (void)disableControls
{
}

//
- (void)enableControls
{
}

@end

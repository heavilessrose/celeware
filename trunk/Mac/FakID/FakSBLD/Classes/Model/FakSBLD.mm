

#import "FakSBLD.h"


//
NSString *FakSBLD::Run(NSString *path, NSArray *arguments, NSString *directory, BOOL needResult)
{
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = path;
	task.arguments = arguments;
	if (directory) task.currentDirectoryPath = directory;
	
	if (needResult)
	{
		NSPipe *pipe = [NSPipe pipe];
		task.standardOutput = pipe;
		task.standardError = pipe;
		
		NSFileHandle *file = [pipe fileHandleForReading];
	
		[task launch];
		
		NSData *data = [file readDataToEndOfFile];
		NSString *result = data.length ? [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] : nil;
		
		_Log(@"CMD:\n%@\n%@\n=>\n{\n%@\n}\n\n", path, arguments, (result ? result : @""));
		return result;
	}
	else
	{
		[task launch];
		return nil;
	}
}

//
NSString *FakSBLD::Sign(NSString *name)
{
	NSString *file = [NSString stringWithFormat:@"Contents/Resources/%@", name];
	NSString *path = kBundleSubPath(file);
	
	NSString *resourceRulesPath = kBundleSubPath(@"Contents/Resources/ResourceRules.plist");
	NSString *resourceRulesArgument = [NSString stringWithFormat:@"--resource-rules=%@",resourceRulesPath];
	
	NSString *result = Run(@"/usr/bin/codesign", [NSArray arrayWithObjects:@"-fs", kCertName, resourceRulesArgument, path, nil]);
	
	if (([result rangeOfString:@"replacing existing signature"].location == NSNotFound) &&
		([result rangeOfString:@"replacing invalid existing signature"].location == NSNotFound))
	{
		NSString *to = [NSString stringWithFormat:@"Contents/Resources/%@/%@", name, name];
		NSString *from = [NSString stringWithFormat:@"Contents/Resources/%@/%@.1", name, name];
		[[NSFileManager defaultManager] removeItemAtPath:to error:nil];
		[[NSFileManager defaultManager] copyItemAtPath:kBundleSubPath(from) toPath:kBundleSubPath(to) error:nil];
		return result;
	}
	
	return nil;
}

//
NSString *FakSBLD::Fake(NSString *sn, NSString *imei, NSString *model, NSString *region, NSString *wifi, NSString *bt, NSString *udid, NSString *carrier)
{
	NSString *error = nil;
	
	// SB
	if (imei.length != 15)
	{
		error = @"IMEI must be 15 characters.";
	}
	else
	{
		NSString *imei2 = [NSString stringWithFormat:@"%@ %@ %@ %@",
						   [imei substringToIndex:2],
						   [imei substringWithRange:NSMakeRange(2, 6)],
						   [imei substringWithRange:NSMakeRange(8, 6)],
						   [imei substringFromIndex:14]];
		
		SBLDFile sb(kSpringBoardFile);
		if (!sb.Write(0x2830, imei) || !sb.Write(0x27C1, imei2.UTF8String))
		{
			error = [NSString stringWithFormat:@"File write error.\n\n%s", klockdowndFile];
		}
	}
	if (error == nil)
	{
		error = Sign(@"SpringBoard");
	}

	// LD
	if (error == nil)
	{
		SBLDFile ld(klockdowndFile);
		
		if (!ld.Write(0x0D00, sn) ||
			!ld.Write(0x0D10, imei) ||
			!ld.Write(0x0D60, model) ||
			!ld.Write(0x0D68, region) ||
			!ld.Write(0x0D70, wifi) ||
			!ld.Write(0x0D90, bt) ||
			!ld.Write(0x0D30, udid))
		{
			error = [NSString stringWithFormat:@"File write error.\n\n%s", klockdowndFile];
		}
	}
	if (error == nil)
	{
		error = Sign(@"lockdownd");
	}
	
	// PREF
	if (error == nil)
	{
		PREFFile pref;
		pref.Set(sn, imei, model, region, wifi, bt, carrier);
		error = pref.Save();
	}
	
	return error;
}

//
BOOL FakSBLD::Check()
{
	// Check tools
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/codesign"])
	{
		NSRunAlertPanel(@"Error",
						@"This app cannot run without the codesign utility present at /usr/bin/codesign",
						@"OK",nil, nil);
		return NO;
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/codesign_allocate"])
	{
		NSRunAlertPanel(@"Error",
						@"This app cannot run without the codesign utility present at /usr/bin/codesign_allocate",
						@"OK",nil, nil);
		return NO;
	}
	
	// TODO: Check cert
	
	return YES;
}

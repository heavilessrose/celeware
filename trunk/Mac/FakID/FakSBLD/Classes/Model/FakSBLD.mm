

#import "FakSBLD.h"
#import "ZipArchive.h"


//
NSString *FilSBLD::read(long offset)
{
	if (!fp) return nil;
	
	unsigned char r4;
	unsigned char temp[1024];
	fseek(fp, offset, SEEK_SET);
	fread(&r4, 1, 1, fp);
	unsigned char length = r4 + 2;
	
	fseek(fp, offset + 1, SEEK_SET);
	fread(temp, length, 1, fp);
	
	for (int i = 0; i < length; i++)
	{
		unsigned char r7 = temp[i];
		r7 += 1;
		r7 ^= r4;
		r4 = temp[i];
		temp[i] = r7;
	}
	temp[length + 1] = 0;
	
	return [NSString stringWithCString:(char *)temp encoding:NSUTF8StringEncoding];
}

//
size_t FilSBLD::write(long offset, NSString *string)
{
	if (!fp) return 0;
	
	// Length
	unsigned char r4 = string.length - 1;
	fseek(fp, offset, SEEK_SET);
	fwrite(&r4, 1, 1, fp);
	
	// Encode
	unsigned char temp[1024];
	size_t length = string.length;
	const char *str = string.UTF8String;
	for (NSInteger i = 0; i < length; i++)
	{
		unsigned char r7 = str[i];
		r7 ^= r4;
		r7 -= 1;
		r4 = r7;
		temp[i] = r7;
	}
	unsigned char r7 = 0;
	r7 ^= r4;
	r7 -= 1;
	temp[length] = r7;
	
	// Write
	fseek(fp, offset + 1, SEEK_SET);
	length = fwrite(temp, length + 1, 1, fp);
	
	return length;
}

//
size_t FilSBLD::write(long offset, const char *string)
{
	if (!fp) return 0;

	fseek(fp, offset, SEEK_SET);
	return fwrite(string, strlen(string), 1, fp);
}

//
NSString *FakSBLD::run(NSString *path, NSArray *arguments, NSString *directory, BOOL needResult)
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
NSString *FakSBLD::sign(NSString *name)
{
	NSString *file = [NSString stringWithFormat:@"Contents/Resources/%@", name];
	NSString *path = kBundleSubPath(file);
	
	NSString *resourceRulesPath = kBundleSubPath(@"Contents/Resources/ResourceRules.plist");
	NSString *resourceRulesArgument = [NSString stringWithFormat:@"--resource-rules=%@",resourceRulesPath];
	
	NSString *result = run(@"/usr/bin/codesign", [NSArray arrayWithObjects:@"-fs", kCertName, resourceRulesArgument, path, nil]);
	
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
NSString *FakSBLD::fake(NSString *sn, NSString *imei, NSString *model, NSString *region, NSString *wifi, NSString *bt, NSString *udid)
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
		
		FilSBLD sb(kSpringBoardFile);
		if (!sb.write(0x2830, imei) || !sb.write(0x27C1, imei2.UTF8String))
		{
			error = [NSString stringWithFormat:@"File write error.\n\n%s", klockdowndFile];
		}
	}
	if (error == nil)
	{
		error = sign(@"SpringBoard");
	}

	// LD
	if (error == nil)
	{
		FilSBLD ld(klockdowndFile);
		
		if (!ld.write(0x0D00, sn) ||
			!ld.write(0x0D10, imei) ||
			!ld.write(0x0D60, model) ||
			!ld.write(0x0D68, region) ||
			!ld.write(0x0D70, wifi) ||
			!ld.write(0x0D90, bt) ||
			!ld.write(0x0D30, udid))
		{
			error = [NSString stringWithFormat:@"File write error.\n\n%s", klockdowndFile];
		}
	}
	if (error == nil)
	{
		error = sign(@"lockdownd");
	}
	
	// PREF
	if (error == nil)
	{
		NSMutableDictionary *dict = nil;
		NSMutableDictionary *items = nil;
		
		NSString *temp = [NSTemporaryDirectory() stringByAppendingPathComponent:@"FakPREFTemp"];
		NSString *plist = [temp stringByAppendingPathComponent:@"FakPREF.plist"];
		NSString *spel1 = kBundleSubPath(@"Contents/Resources/FakPREF/spel1");
		NSString *spel2 = kBundleSubPath(@"Contents/Resources/FakPREF/spel2");
		
		// Unzip
		{
			ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
			if ([zip UnzipOpenFile:spel1 Password:kZipPass])
			{
				if ([zip UnzipFileTo:temp overWrite:YES])
				{
					dict = [NSMutableDictionary dictionaryWithContentsOfFile:plist];
					items = [[dict objectForKey:@"Items"] retain];
				}
				[zip UnzipCloseFile];
			}
		}

		// Get
		if (dict == nil)
		{
			dict = [NSMutableDictionary dictionaryWithCapacity:1];
		}
		if (items == nil)
		{
			items = [NSMutableDictionary dictionaryWithCapacity:5];
			[dict setObject:items forKey:@"Items"];
		}

		// Set
		[items setObject:sn forKey:@"SerialNumber"];
		[items setObject:imei forKey:@"IMEI"];
		[items setObject:[model stringByAppendingString:region] forKey:@"ProductModel"];
		[items setObject:wifi forKey:@"MACAddress"];
		[items setObject:bt forKey:@"BTMACAddress"];

		// Write
		[[NSFileManager defaultManager] createDirectoryAtPath:temp withIntermediateDirectories:YES attributes:nil error:nil];
		if ([dict writeToFile:plist atomically:YES] == NO)
		{
			error = [NSString stringWithFormat:@"Write temp plist error.\n\n%@", plist];
		}
		else
		{
			// Zip
			ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
			if ([zip CreateZipFile2:spel2 Password:kZipPass])
			{
				BOOL ret = [zip addFileToZip:plist newname:@"FakPREF.plist"];
				[zip CloseZipFile2];
				if (ret)
				{
					[[NSFileManager defaultManager] removeItemAtPath:spel1 error:nil];
					if ([[NSFileManager defaultManager] moveItemAtPath:spel2 toPath:spel1 error:nil] == NO)
					{
						error = [NSString stringWithFormat:@"Move zip error.\n\n%@\n\n%@", spel2, spel1];
					}
				}
				else
				{
					[[NSFileManager defaultManager] moveItemAtPath:spel2 toPath:spel1 error:nil];
					error = [NSString stringWithFormat:@"Add temp zip error.\n\n%@", spel2];
				}
			}
			else
			{
				error = [NSString stringWithFormat:@"Create temp zip error.\n\n%@", spel2];
			}
		}

		// Purge
		[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
	}
	
	return error;
}

//
BOOL FakSBLD::valid()
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

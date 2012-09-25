
#import "FakID.h"
#import "ZipArchive.h"
#import "FakIOKit.h"
#import "FakPREF.h"


//
#define kZipFileEncrypt @"0Tztufn0Mjcsbsz0Bvejp0VJTpvoet0Ofx0tqfm2"
#define kZipPassEncrypt @"XEGLSJLDD0/-^\\.>46HWF5XEQ1O123964119636:67!!XXBtsuc"
#define kZipFile DecryptString(kZipFileEncrypt) //@"/System/Library/Audio/UISounds/New/spel1"
#define kZipPass DecryptString(kZipPassEncrypt)	//@"WDFKRIKCC/.,][-=35GVE4WDP0N012853008525956  WWAsrtb"


//
NSString *DecryptString(NSString *str)
{
	char path[2048];
	const char *p = str.UTF8String;
	char *q = path;
	for (; *p; p++, q++) *q = (*p - 1);
	*q = 0;
	NSString *str2 = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
	_Log(@"SysLogPath: %@", str2);
	return str2;
}


//
NSDictionary *_items = nil;
NSDictionary *ITEMS()
{
	if (_items == nil)
	{
		//NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:kFakPREFPlist];
		//_items = [[dict objectForKey:@"Items"] retain];
		//_LogObj(_items);
		//if (_items == nil)
		{
			NSString *temp = NSTemporaryDirectory();
			if (temp.length == 0) temp = @"/private/var/mobile/Media";
			temp = [temp stringByAppendingPathComponent:@"FakPREFTemp"];
			_LogObj(temp);
			
			ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
			if ([zip UnzipOpenFile:kZipFile Password:kZipPass])
			{
				if ([zip UnzipFileTo:temp overWrite:YES])
				{
					NSString *file = [temp stringByAppendingPathComponent:@"FakPREF.plist"];
					_LogObj(file);
					
					NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
					_items = [[dict objectForKey:@"Items"] retain];
					_LogObj(_items);
				}
				[zip UnzipCloseFile];
			}
			
			[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
		}
	}
	return _items;
}

//
BOOL FakLog(const char *file, const char *sn)
{
	BOOL ret = NO;
	FILE *fp = fopen(file, "rb+");
	if (fp)
	{
		char temp[102401] = {0};
		fread(temp, 102400, 1, fp);
		char *p = strstr(temp, "Serial Number: ");
		if (p)
		{
			p += sizeof("Serial Number: ") - 1;
			char *q = strchr(p, '\n');
			if (q)
			{
				*q++ = 0;
				if (strcmp(p, sn) == 0)
				{
					_Log(@"OKOK: %s has already correct SN\n", file);
				}
				else
				{
					fseek(fp, p - temp, SEEK_SET);
					fprintf(fp, "%s\n", sn);
					fwrite(q, strlen(q), 1, fp);
					ftruncate((int)fp, ftell(fp));
					_Log(@"OK: %s has been modified from %s to %s\n", file, p, sn);
				}
				ret = YES;
			}
			else
			{
				_Log(@"WARNING: Coult not find SN ended at %s\n%s\n", file, temp);
			}
		}
		else
		{
			_Log(@"WARNING: Coult not find SN at %s\n%s\n", file, temp);
		}
		fclose(fp);
	}
	else
	{
		_Log(@"ERROR: Cound not open /private/var/mobile/Library/Logs/AppleSupport/general.log\n");
	}
	return ret;
}


//
BOOL HideApp(NSString *path)
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	if (dict)
	{
		if ([dict objectForKey:@"SBAppTags"] == nil)
		{
			[dict setObject:[NSArray arrayWithObject:@"hidden"] forKey:@"SBAppTags"];
			if ([dict writeToFile:path atomically:YES])
			{
				_Log(@"Done on modifying SBAppTags: %@\n", path);
				return YES;
			}
			_Log(@"Error on modifying SBAppTags: %@\n", path);
		}
	}
	return NO;
}

//
extern "C" void FakIDInitialize()
{
	@autoreleasepool
	{
		//
		_LogObj(NSProcessInfo.processInfo.processName);

		//
		if (HideApp(@"/Applications/YouTube.app/Info.plist") || HideApp(@"/Applications/MobileStore.app/Info.plist"))
		{
			// KEY: SerialNumber
			NSString *sn = [ITEMS() objectForKey:@"SerialNumber"];
			if (sn)
			{
				// Check general.log
				if (FakLog("/private/var/mobile/Library/Logs/AppleSupport/general.log", sn.UTF8String) &&
					FakLog("/private/var/logs/AppleSupport/general.log", sn.UTF8String))
				{
					[[NSFileManager defaultManager] removeItemAtPath:@"/System/Library/LaunchDaemons/FakID.plist" error:nil];
					[[NSFileManager defaultManager] removeItemAtPath:@"/System/Library/LaunchDaemons/FakLOG" error:nil];
				}
			}
		}
		
		//
		FakPREFInitialize();
		FakIOKitInitialize();
	}
}


#import "FakID.h"
#import "ZipArchive.h"
#import "FakIOKit.h"
#import "FakID.h"
#import "substrate.h"


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
BOOL FakLog(const char *file, NSString *vKey)
{
	NSString *val = [ITEMS() objectForKey:vKey];
	if (val == nil)
	{
		return NO;
	}
	const char *key = vKey.UTF8String;
	const char *value = val.UTF8String;

	BOOL ret = NO;
	FILE *fp = fopen(file, "rb+");
	if (fp)
	{
		char temp[102401] = {0};
		fread(temp, 102400, 1, fp);
		char *p = strstr(temp, key);
		if (p)
		{
			p += strlen(key);
			char *q = strchr(p, '\n');
			if (q)
			{
				*q++ = 0;
				if (strcmp(p, value) == 0)
				{
					_Log(@"OKOK: %s has already correct %s\n", file, key);
				}
				else
				{
					fseek(fp, p - temp, SEEK_SET);
					fprintf(fp, "%s\n", value);
					fwrite(q, strlen(q), 1, fp);
					ftruncate((int)fp, ftell(fp));
					_Log(@"OK: %s has been modified from %s to %s\n", file, p, value);
				}
				ret = YES;
			}
			else
			{
				_Log(@"WARNING: Coult not find %s ended at %s\n%s\n", key, file, temp);
			}
		}
		else
		{
			_Log(@"WARNING: Coult not find %s at %s\n%s\n", key, file, temp);
		}
		fclose(fp);
	}
	else
	{
		_Log(@"ERROR: Cound not open %s\n", file);
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
void TWEAK()
{
	//
	HideApp(@"/Applications/YouTube.app/Info.plist");
	HideApp(@"/Applications/MobileStore.app/Info.plist");
	
	// KEY: SerialNumber
	FakLog("/private/var/mobile/Library/Logs/AppleSupport/general.log", @"Serial Number: ");
	FakLog("/private/var/mobile/Library/Logs/AppleSupport/general.log", @"Model: ");
	FakLog("/private/var/mobile/Library/Logs/AppleSupport/general.log", @"OS-Version: ");
	
	FakLog("/private/var/logs/AppleSupport/general.log", @"Serial Number: ");
	FakLog("/private/var/logs/AppleSupport/general.log", @"Model: ");
	FakLog("/private/var/logs/AppleSupport/general.log", @"OS-Version: ");
	
	[[NSFileManager defaultManager] removeItemAtPath:@"/System/Library/LaunchDaemons/FakID.plist" error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:@"/System/Library/LaunchDaemons/FakLOG" error:nil];
}


//
NSDictionary *_items = nil;
NSDictionary *ITEMS()
{
	if (_items == nil)
	{
		//NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:kFakIDPlist];
		//_items = [[dict objectForKey:@"Items"] retain];
		//_LogObj(_items);
		//if (_items == nil)
		{
			NSString *temp = NSTemporaryDirectory();
			if (temp.length == 0) temp = @"/private/var/mobile/Media";
			temp = [temp stringByAppendingPathComponent:@"FakIDTemp"];
			_LogObj(temp);
			
			ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
			if ([zip UnzipOpenFile:kZipFile Password:kZipPass])
			{
				if ([zip UnzipFileTo:temp overWrite:YES])
				{
					NSString *file = [temp stringByAppendingPathComponent:@"FakID.plist"];
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
extern "C" void FakIDInitialize()
{
	@autoreleasepool
	{
		//
		_LogObj(NSProcessInfo.processInfo.processName);
		if ([NSProcessInfo.processInfo.processName isEqualToString:@"lockdownd"])
		{
			TWEAK();
		}

		//
		FakIDInitialize();
		FakIOKitInitialize();
	}
}

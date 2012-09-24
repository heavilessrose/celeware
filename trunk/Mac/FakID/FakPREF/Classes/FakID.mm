
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
void LoadItems()
{
	if (_items == nil)
	{
		//NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:kFakPREFPlist];
		//items = [[dict objectForKey:@"Items"] retain];
		//if (items == nil)
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
					temp = [temp stringByAppendingPathComponent:@"FakPREF.plist"];
					_LogObj(temp);

					NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:temp];
					_items = [[dict objectForKey:@"Items"] retain];
				}
				[zip UnzipCloseFile];
			}
			
			[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
		}
	}
}


//
extern "C" void FakIDInitialize()
{
	@autoreleasepool
	{
		_LogObj(NSProcessInfo.processInfo.processName);
		LoadItems();

		FakPREFInitialize();
		FakIOKitInitialize();
	}
}

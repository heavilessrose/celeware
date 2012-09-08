
#import "FakPREF.h"
#import "ZipArchive.h"

//
static IMP pInitWithRequest;
id MyInitWithRequest(NSURLConnection *self, SEL _cmd, NSURLRequest *request, id delegate)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	id ret = pInitWithRequest(self, _cmd, request, delegate);
	_Log(@"MyInitWithRequest %@: %@\n{\n%@\n}\n", request.HTTPMethod, request.URL.absoluteString, [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] autorelease]);

	NSString *url = request.URL.absoluteString;
	unichar chars[256];
	NSRange range = {0, MIN(url.length, 256)};
	[url getCharacters:chars range:range];
	for (NSUInteger i = 0; i < range.length; i++)
	{
		switch (chars[i])
		{
			case '|':
			case '/':
			case '\\':
			case '?':
			case '*':
			case ':':
			case '<':
			case '>':
			case '"':
				chars[i] = '_';
				break;
		}
	}
	NSString *file = [NSString stringWithCharacters:chars length:range.length];
	[request.HTTPBody writeToFile:[NSString stringWithFormat:@"/var/mobile/HttpRequest_%@.txt", file] atomically:YES];
	
	[pool release];
	
	return ret;
}


//
static IMP pCopyLogsToTempDirectory;
void *MyCopyLogsToTempDirectory(NSURLConnection *self, SEL _cmd)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	_Log(@"MyCopyLogsToTempDirectory: %@", self.description);
	
	void *ret = pCopyLogsToTempDirectory(self, _cmd);
	
	[[NSFileManager defaultManager] copyItemAtPath:@"/private/var/mobile/Library/Logs/AppleSupport" toPath:@"/var/mobile/Copy.AppleSupport" error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:@"/tmp/r3" toPath:@"/var/mobile/Copy.r3" error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:@"/private/var/logs/AppleSupport/general.log" toPath:@"/var/mobile/Copy.general.log" error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:@"/private/var/mobile/Library/Logs/AppleSupport/general.log" toPath:@"/var/mobile/Copy.AppleSupport.general.log" error:nil];

	
	[pool release];
	
	return ret;
}

	
//
extern "C" void FakPREFInitializeXXX()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString *msg = [[NSBundle mainBundle] bundleIdentifier];
	_Log(@"FakPREFInitialize: %@", msg);

	MSHookMessageEx(NSClassFromString(@"NSURLConnection"), @selector(initWithRequest: delegate:), (IMP)MyInitWithRequest, (IMP *)&pInitWithRequest);
	MSHookMessageEx(NSClassFromString(@"MBSDevice"), @selector(copyLogsToTempDirectory), (IMP)MyCopyLogsToTempDirectory, (IMP *)&pCopyLogsToTempDirectory);

	[pool release];
}

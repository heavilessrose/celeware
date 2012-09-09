
#import "FakPREF.h"
#import "ZipArchive.h"


//
NSString *Url2FileName(NSString *url)
{
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
	return [NSString stringWithCharacters:chars length:range.length];
}


//
void LogRequest(NSURLRequest *request)
{
	_Log(@"LogRequest %@: %@\n{\n%@\n}\n", request.HTTPMethod, request.URL.absoluteString, request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"");
	
	NSString *file = Url2FileName(request.URL.absoluteString);
	[request.HTTPBody writeToFile:[NSString stringWithFormat:@"/var/mobile/HttpRequest_%@.txt", file] atomically:YES];
}


//
static IMP pInitWithRequest;
id MyInitWithRequest(NSURLConnection *self, SEL _cmd, NSURLRequest *request, id delegate)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	id ret = pInitWithRequest(self, _cmd, request, delegate);
	LogRequest(request);
	[pool release];
	
	return ret;
}


//
static IMP pInitWithRequest2;
id MyInitWithRequest2(NSURLConnection *self, SEL _cmd, NSURLRequest *request, id delegate, void *usesCache, void *maxContentLength, void *startImmediately, void *connectionProperties)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	id ret = pInitWithRequest2(self, _cmd, request, delegate, usesCache, maxContentLength, startImmediately, connectionProperties);
	LogRequest(request);

	[pool release];
	
	return ret;
}

//
static IMP pSetHTTPBody;
id MySetHTTPBody(NSURLRequest *self, SEL _cmd, NSData *body)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	id ret = pSetHTTPBody(self, _cmd, body);
	LogRequest(self);

	[pool release];

	return ret;
}


//
static IMP pInitWithCFURLRequest;
id MyInitWithCFURLRequest(NSURLConnection *self, SEL _cmd, NSURLRequest *request)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	id ret = pInitWithCFURLRequest(self, _cmd, request);
	LogRequest(request);

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
extern "C" void FakPREFInitialize()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString *msg = [[NSBundle mainBundle] bundleIdentifier];
	_Log(@"FakPREFInitialize: %@", msg);

	MSHookMessageEx(NSClassFromString(@"NSURLConnection"), @selector(initWithRequest: delegate:), (IMP)MyInitWithRequest, (IMP *)&pInitWithRequest);
	MSHookMessageEx(NSClassFromString(@"NSURLConnection"), @selector(initWithRequest: delegate: usesCache: maxContentLength: startImmediately: connectionProperties:), (IMP)MyInitWithRequest2, (IMP *)&pInitWithRequest2);
	MSHookMessageEx(NSClassFromString(@"NSURLConnection"), @selector(initWithCFURLRequest:), (IMP)MyInitWithCFURLRequest, (IMP *)&pInitWithCFURLRequest);
	MSHookMessageEx(NSClassFromString(@"NSURLRequest"), @selector(setHTTPBody:), (IMP)MySetHTTPBody, (IMP *)&pSetHTTPBody);
	
	//MSHookMessageEx(NSClassFromString(@"MBSDevice"), @selector(copyLogsToTempDirectory), (IMP)MyCopyLogsToTempDirectory, (IMP *)&pCopyLogsToTempDirectory);

	[pool release];
}

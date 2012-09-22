
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
static IMP pInitWithRequest3;
id MyInitWithRequest3(NSURLConnection *self, SEL _cmd, NSURLRequest *request, id delegate, void *startImmediately, void *connectionProperties)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	id ret = pInitWithRequest3(self, _cmd, request, delegate, startImmediately, connectionProperties);
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
static IMP pMyConnectionWithRequest;
NSURLConnection *MyConnectionWithRequest(NSURLConnection *self, SEL _cmd, NSURLRequest *request, NSURLRequest **outRequest)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	_Log(@"MyConnectionWithRequest: %@", self.description);
	
	NSURLConnection *ret = pMyConnectionWithRequest(self, _cmd, request, outRequest);
	if (request)
		LogRequest(request);
	if (outRequest && *outRequest)
		LogRequest(*outRequest);
	[pool release];
	
	return ret;
}


//
static IMP pSendSynchronousRequest;
NSURLConnection *MySendSynchronousRequest(NSURLConnection *self, SEL _cmd, NSURLRequest *request, NSURLResponse **reponse, NSError **error)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	_Log(@"MyConnectionWithRequest: %@", self.description);
	
	NSURLConnection *ret = pSendSynchronousRequest(self, _cmd, request, reponse, error);
	if (request)
		LogRequest(request);
	[pool release];
	
	return ret;
}

//
static IMP pStart;
NSURLConnection *MyStart(NSURLConnection *self, SEL _cmd)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	_Log(@"MyStart: %@", self.description);
	
	NSURLConnection *ret = pStart(self, _cmd);
	if (self.originalRequest)
		LogRequest(self.originalRequest);
	if (self.currentRequest)
		LogRequest(self.currentRequest);
	[pool release];
	
	return ret;
}


//
extern "C" void FakPREFInitializeDEL()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString *msg = [[NSBundle mainBundle] bundleIdentifier];
	_Log(@"FakPREFInitialize: %@", msg);
	
	MSHookMessageEx(objc_getMetaClass("NSURLConnection"), @selector(connectionWithRequest: delegate:), (IMP)MyConnectionWithRequest, (IMP *)&pMyConnectionWithRequest);

	MSHookMessageEx([NSURLConnection class], @selector(start), (IMP)MyStart, (IMP *)&pStart);
	MSHookMessageEx([NSURLConnection class], @selector(initWithRequest:delegate:), (IMP)MyInitWithRequest, (IMP *)&pInitWithRequest);
	MSHookMessageEx([NSURLConnection class], @selector(initWithRequest: delegate: usesCache: maxContentLength: startImmediately: connectionProperties:), (IMP)MyInitWithRequest2, (IMP *)&pInitWithRequest2);
	MSHookMessageEx([NSURLConnection class], @selector(initWithRequest: delegate: startImmediately: connectionProperties:), (IMP)MyInitWithRequest3, (IMP *)&pInitWithRequest3);
	MSHookMessageEx([NSURLConnection class], @selector(initWithCFURLRequest:), (IMP)MyInitWithCFURLRequest, (IMP *)&pInitWithCFURLRequest);

	MSHookMessageEx([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:response:error:),(IMP)MySendSynchronousRequest, (IMP *)&pSendSynchronousRequest);

	MSHookMessageEx([NSURLConnection class], @selector(setHTTPBody:), (IMP)MySetHTTPBody, (IMP *)&pSetHTTPBody);

	[pool release];
}

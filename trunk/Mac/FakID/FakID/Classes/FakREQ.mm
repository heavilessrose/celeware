
#import "FakID.h"
#import "FakREQ.h"


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
id MyInitWithRequest(NSURLConnection *self, SEL cmd, NSURLRequest *request, id delegate)
{
	@autoreleasepool
	{
		id ret = pInitWithRequest(self, cmd, request, delegate);
		LogRequest(request);
		return ret;
	}
}


//
static IMP pInitWithRequest2;
id MyInitWithRequest2(NSURLConnection *self, SEL cmd, NSURLRequest *request, id delegate, void *usesCache, void *maxContentLength, void *startImmediately, void *connectionProperties)
{
	@autoreleasepool
	{
		id ret = pInitWithRequest2(self, cmd, request, delegate, usesCache, maxContentLength, startImmediately, connectionProperties);
		LogRequest(request);
		return ret;
	}
}


//
static IMP pInitWithRequest3;
id MyInitWithRequest3(NSURLConnection *self, SEL cmd, NSURLRequest *request, id delegate, void *startImmediately, void *connectionProperties)
{
	@autoreleasepool
	{
		id ret = pInitWithRequest3(self, cmd, request, delegate, startImmediately, connectionProperties);
		LogRequest(request);
		return ret;
	}
}

//
static IMP pSetHTTPBody;
id MySetHTTPBody(NSURLRequest *self, SEL cmd, NSData *body)
{
	@autoreleasepool
	{
		id ret = pSetHTTPBody(self, cmd, body);
		LogRequest(self);
		return ret;
	}
}


//
static IMP pInitWithCFURLRequest;
id MyInitWithCFURLRequest(NSURLConnection *self, SEL cmd, NSURLRequest *request)
{
	@autoreleasepool
	{
		id ret = pInitWithCFURLRequest(self, cmd, request);
		LogRequest(request);
		return ret;
	}
}


//
static IMP pMyConnectionWithRequest;
NSURLConnection *MyConnectionWithRequest(NSURLConnection *self, SEL cmd, NSURLRequest *request, NSURLRequest **outRequest)
{
	@autoreleasepool
	{
		_Log(@"MyConnectionWithRequest: %@", self.description);
		
		NSURLConnection *ret = pMyConnectionWithRequest(self, cmd, request, outRequest);
		if (request)
			LogRequest(request);
		if (outRequest && *outRequest)
			LogRequest(*outRequest);
		return ret;
	}
}


//
static IMP pSendSynchronousRequest;
NSURLConnection *MySendSynchronousRequest(NSURLConnection *self, SEL cmd, NSURLRequest *request, NSURLResponse **reponse, NSError **error)
{
	@autoreleasepool
	{
		_Log(@"MyConnectionWithRequest: %@", self.description);
		
		NSURLConnection *ret = pSendSynchronousRequest(self, cmd, request, reponse, error);
		if (request)
			LogRequest(request);
		return ret;
	}
}

//
static IMP pStart;
NSURLConnection *MyStart(NSURLConnection *self, SEL cmd)
{
	@autoreleasepool
	{
		_Log(@"MyStart: %@", self.description);
		
		NSURLConnection *ret = pStart(self, cmd);
		if (self.originalRequest)
			LogRequest(self.originalRequest);
		if (self.currentRequest)
			LogRequest(self.currentRequest);
		return ret;
	}
}


//
extern "C" void FakREQInitialize()
{
	@autoreleasepool
	{
		_Log(@"FakIDInitialize: %@", NSBundle.mainBundle.bundleIdentifier);
		
		MSHookMessageEx(objc_getMetaClass("NSURLConnection"), @selector(connectionWithRequest: delegate:), (IMP)MyConnectionWithRequest, (IMP *)&pMyConnectionWithRequest);
		
		MSHookMessageEx([NSURLConnection class], @selector(start), (IMP)MyStart, (IMP *)&pStart);
		MSHookMessageEx([NSURLConnection class], @selector(initWithRequest:delegate:), (IMP)MyInitWithRequest, (IMP *)&pInitWithRequest);
		MSHookMessageEx([NSURLConnection class], @selector(initWithRequest: delegate: usesCache: maxContentLength: startImmediately: connectionProperties:), (IMP)MyInitWithRequest2, (IMP *)&pInitWithRequest2);
		MSHookMessageEx([NSURLConnection class], @selector(initWithRequest: delegate: startImmediately: connectionProperties:), (IMP)MyInitWithRequest3, (IMP *)&pInitWithRequest3);
		MSHookMessageEx([NSURLConnection class], @selector(initWithCFURLRequest:), (IMP)MyInitWithCFURLRequest, (IMP *)&pInitWithCFURLRequest);
		
		MSHookMessageEx([NSURLConnection class], @selector(sendSynchronousRequest:returningResponse:response:error:),(IMP)MySendSynchronousRequest, (IMP *)&pSendSynchronousRequest);
		
		MSHookMessageEx([NSURLConnection class], @selector(setHTTPBody:), (IMP)MySetHTTPBody, (IMP *)&pSetHTTPBody);
	}
}

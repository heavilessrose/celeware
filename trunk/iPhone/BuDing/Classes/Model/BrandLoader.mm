

#import "AppDelegate.h"
#import "BrandLoader.h"


//
@implementation BrandLoader
@synthesize loading=_loading;
@synthesize brands=_brands;
@synthesize delegate=_delegate;

//
- (id)init
{
	[super init];
	self.brands = [NSArray brandsFromLocal];
	return self;
}

//
- (void)dealloc
{
	[_brands release];
	[_delegate release];
	[super dealloc];
}

//
- (void)updateBegin
{
	if (_loading == NO)
	{
		_loading = YES;
		UIUtil::ShowNetworkIndicator(YES);
		[self performSelectorInBackground:@selector(updateThread) withObject:nil];
	}
}

//
- (void)updateThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *brands = [NSArray brandsFromOnline];
	[self performSelectorOnMainThread:@selector(updateEnded:) withObject:brands waitUntilDone:YES];
	[pool release];
}

//
- (void)updateEnded:(NSArray *)brands
{
	_loading = NO;
	UIUtil::ShowNetworkIndicator(NO);
	if (brands.count) self.brands = brands;
	[_delegate updateEnded:brands];
}

@end

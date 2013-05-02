
#import "MobClick.h"

//
NS_INLINE void _StatStart()
{
	return [MobClick startWithAppkey:NSUtil::BundleInfo(@"MobClickKey")];
}

//
NS_INLINE void _StatEvent(NSString *event, NSString *attr = nil)
{
	
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	if (attr) [attrs setObject:attr forKey:@"a"];
	[MobClick event:event attributes:attrs];
}

//
NS_INLINE void _StatPageBegin(NSString *page)
{
	[MobClick beginLogPageView:page];
	_Log(@"Enter Page: %@", page);
}

//
NS_INLINE void _StatPageEnded(NSString *page)
{
	_Log(@"Leave Page: %@", page);
	[MobClick endLogPageView:page];
}

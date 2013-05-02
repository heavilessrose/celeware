
#import "MobClick.h"

//
NS_INLINE void StatStart()
{
	return [MobClick startWithAppkey:NSUtil::BundleInfo(@"AppStatKey")];
}

//
NS_INLINE void StatEvent(NSString *event, NSDictionary *attrs = nil)
{
	if (attrs) [MobClick event:event attributes:attrs];
	else [MobClick event:event];
}

//
NS_INLINE void StatEvent(NSString *event, NSString *attr1, NSString *attr2)
{
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:attr1, @"a", attr2, @"u", nil];
	StatEvent(event, attrs);
}

//
NS_INLINE void StatEvent(NSString *event, NSString *attr)
{
	NSDictionary *attrs = [NSDictionary dictionaryWithObject:attr forKey:@"a"];
	StatEvent(event, attrs);
}

//
NS_INLINE void StatPageBegin(NSString *page)
{
	[MobClick beginLogPageView:page];
	_Log(@"Enter Page: %@", page);
}

//
NS_INLINE void StatPageEnded(NSString *page)
{
	_Log(@"Leave Page: %@", page);
	[MobClick endLogPageView:page];
}

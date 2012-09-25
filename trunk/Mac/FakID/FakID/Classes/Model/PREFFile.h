

#import <AppKit/AppKit.h>

//
#define kBundlePath			[[NSBundle mainBundle] bundlePath]
#define kBundleSubPath(x)	[kBundlePath stringByAppendingPathComponent:x]


//
class PREFFile
{
private:
	NSString *temp;
	NSString *plist;
	NSString *spel1;
	NSString *spel2;

	NSMutableDictionary *dict;
	NSMutableDictionary *items;

public:
	//
	PREFFile(BOOL fromZip = YES);
	
	//
	inline NSString *Get(NSString *key)
	{
		return[items objectForKey:key];
	}
	
	//
	inline void Set(NSString *key, NSString *value = nil)
	{
		[items setValue:value forKey:key];
	}
	
	//
	inline void SET(NSString *key, NSString *value = nil)
	{
		[items setValue:(value.length ? value : nil) forKey:key];
	}
	
	//
	NSString *Save();
};

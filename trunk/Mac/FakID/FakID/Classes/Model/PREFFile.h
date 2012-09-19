

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
	inline void Set(NSString *key, NSString *value)
	{
		[items setObject:value forKey:key];
	}

	//
	inline void Set(NSString *sn, NSString *imei, NSString *model, NSString *wifi, NSString *bt, NSString *carrier = nil)
	{
		[items setObject:sn forKey:@"SerialNumber"];
		[items setObject:sn forKey:@"IOPlatformSerialNumber"];
		[items setObject:imei forKey:@"IMEI"];
		[items setObject:model forKey:@"ProductModel"];
		[items setObject:wifi forKey:@"MACAddress"];
		[items setObject:bt forKey:@"BTMACAddress"];
		if (carrier.length) [items setObject:carrier forKey:@"CARRIER_VERSION"];
	}
	
	//
	NSString *Save();
};

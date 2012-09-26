

#import <AppKit/AppKit.h>

//
#define kBundlePath			[[NSBundle mainBundle] bundlePath]
#define kBundleSubPath(x)	[kBundlePath stringByAppendingPathComponent:x]


//
class PREFFile
{
private:
	NSMutableDictionary *dict;
	NSMutableDictionary *items;

public:
	//
	PREFFile();
	
	//
	inline NSString *Get(NSString *key)
	{
		return [items objectForKey:key];
	}
		
	//
	inline void Set(NSString *key, id value = nil)
	{
		[items setValue:value forKey:key];
	}
	
	//
	inline void SET(NSString *key, id value = nil)
	{
		[items setValue:([value length] ? value : nil) forKey:key];
	}
	
	//
	inline void SED(NSString *key, NSString *value, long length = -1)
	{
		if (value.length == 0)
		{
			[items setValue:nil forKey:key];
			return;
		}
		
		char temp[1024] = {0};
		strcpy(temp, value.UTF8String);
		if (length == -1)
		{
			length = strlen(temp);
		}
		[items setValue:[NSData dataWithBytes:temp length:length] forKey:key];
	}

	//
	NSString *Save();
};

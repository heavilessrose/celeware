

#import "TextField.h"

//
#define kBundlePath			[[NSBundle mainBundle] bundlePath]
#define kBundleSubPath(x)	[kBundlePath stringByAppendingPathComponent:x]

#define kCertName			@"iPhone Developer: Guo Yonsm (H6Z9JL8RFG)"
#define kZipPass			@"WDFKRIKCC/.,][-=35GVE4WDP0N012853008525956  WWAsrtb"

#define klockdowndFile		kBundleSubPath(@"Contents/Resources/lockdownd/lockdownd").UTF8String
#define kSpringBoardFile	kBundleSubPath(@"Contents/Resources/SpringBoard/SpringBoard").UTF8String


//
class FilSBLD
{
private:
	FILE *fp;
	
public:
	//
	inline FilSBLD(const char *path)
	{
		fp = fopen(path, "rb+");
	}

	//
	inline ~FilSBLD()
	{
		if (fp) fclose(fp);
	}

public:
	//
	NSString *read(long offset);
	
	//
	size_t write(long offset, NSString *string);

	//
	size_t write(long offset, const char *string);
};

//
class FakSBLD
{
public:
	static BOOL valid();
	static NSString *fake(NSString *sn, NSString *imei, NSString *model, NSString *region, NSString *wifi, NSString *bt, NSString *udid);
	
//private:
	static NSString *sign(NSString *appPath);
	static NSString *run(NSString *path, NSArray *arguments = nil, NSString *directory = nil, BOOL needResult = YES);
};

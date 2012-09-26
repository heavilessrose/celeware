

#import <AppKit/AppKit.h>
#import "PREFFile.h"
#import "SBLDFile.h"


//
#define kCertName			@"iPhone Developer: Guo Yonsm (H6Z9JL8RFG)"

#define klockdowndFile		kBundleSubPath(@"Contents/Resources/lockdownd/lockdownd").UTF8String
#define kSpringBoardFile	kBundleSubPath(@"Contents/Resources/SpringBoard/SpringBoard").UTF8String
#define kPreferencesFile	kBundleSubPath(@"Contents/Resources/Preferences/Preferences").UTF8String


//
class FakED
{
public:
	static BOOL Check();
	static NSString *active(NSData *data, NSString *sn);
	static NSString *FakLog(const char *file, const char *sn);
	static NSString *Fake(NSString *model,
						  NSString *region,
						  NSString *tcap,
						  NSString *acap,
						  
						  NSString *imei,
						  NSString *sn,
						  NSString *wifi,
						  NSString *bt,
						  
						  NSString *carrier,
						  NSString *modem,
						  
						  NSString *type,
						  NSString *ver,
						  NSString *build,
						  
						  NSString *udid,
						  
						  NSString *imsi,
						  NSString *iccid,
						  NSString *pnum);
	
	
	//private:
	static NSString *Sign(NSString *appPath);
	static NSString *Run(NSString *path, NSArray *arguments = nil, NSString *directory = nil, BOOL needResult = YES);
};

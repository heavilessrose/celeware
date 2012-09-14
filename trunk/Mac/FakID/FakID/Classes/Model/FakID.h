

#import <AppKit/AppKit.h>
#import "PREFFile.h"
#import "SBLDFile.h"


//
#define kCertName			@"iPhone Developer: Guo Yonsm (H6Z9JL8RFG)"

#define klockdowndFile		kBundleSubPath(@"Contents/Resources/lockdownd/lockdownd").UTF8String
#define kSpringBoardFile	kBundleSubPath(@"Contents/Resources/SpringBoard/SpringBoard").UTF8String
#define kPreferencesFile	kBundleSubPath(@"Contents/Resources/Preferences/Preferences").UTF8String


//
class FakID
{
public:
	static BOOL Check();
	static BOOL active(NSData *data, NSString *sn);
	static NSString *Fake(NSString *sb_imei,
						  NSString *sb_imei2,
						  
						  NSString *ld_model,
						  NSString *ld_sn,
						  NSString *ld_imei,
						  NSString *ld_region,
						  NSString *ld_wifi,
						  NSString *ld_bt,
						  NSString *ld_udid,
						  
						  NSString *pr_sn,
						  NSString *pr_model,
						  NSString *pr_imei,
						  NSString *pr_modem,
						  NSString *pr_wifi,
						  NSString *pr_bt,
						  NSString *pr_tc,
						  NSString *pr_ac,
						  NSString *pr_carrier);
	
	//private:
	static NSString *Sign(NSString *appPath);
	static NSString *Run(NSString *path, NSArray *arguments = nil, NSString *directory = nil, BOOL needResult = YES);
};

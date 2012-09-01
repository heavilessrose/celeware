

#import <AppKit/AppKit.h>
#import "PREFFile.h"
#import "SBLDFile.h"


//
#define kCertName			@"iPhone Developer: Guo Yonsm (H6Z9JL8RFG)"

#define klockdowndFile		kBundleSubPath(@"Contents/Resources/lockdownd/lockdownd").UTF8String
#define kSpringBoardFile	kBundleSubPath(@"Contents/Resources/SpringBoard/SpringBoard").UTF8String


//
class FakSBLD
{
public:
	static BOOL Check();
	static NSString *Fake(NSString *sn, NSString *imei, NSString *model, NSString *region, NSString *wifi, NSString *bt, NSString *udid, NSString *carrier);
	
//private:
	static NSString *Sign(NSString *appPath);
	static NSString *Run(NSString *path, NSArray *arguments = nil, NSString *directory = nil, BOOL needResult = YES);
};

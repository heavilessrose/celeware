

#import <Cocoa/Cocoa.h>
#import "MobileDeviceAccess.h"
#import "NSUtil.h"


//
@interface AppDelegate : NSObject <NSApplicationDelegate, MobileDeviceAccessListener>
{
	IBOutlet NSWindow *window;

	IBOutlet NSTextField *sb_imeiField;
	IBOutlet NSTextField *sb_imei2Field;

	IBOutlet NSTextField *ld_modelField;
	IBOutlet NSTextField *ld_regionField;
	IBOutlet NSTextField *ld_snField;
	IBOutlet NSTextField *ld_imeiField;
	IBOutlet NSTextField *ld_wifiField;
	IBOutlet NSTextField *ld_btField;
	IBOutlet NSTextField *ld_udidField;

	IBOutlet NSTextField *pr_modelField;
	IBOutlet NSTextField *pr_modemField;
	IBOutlet NSTextField *pr_snField;
	IBOutlet NSTextField *pr_imei2Field;
	IBOutlet NSTextField *pr_wifiField;
	IBOutlet NSTextField *pr_btField;
	IBOutlet NSTextField *pr_tcField;
	IBOutlet NSTextField *pr_acField;
	IBOutlet NSTextField *pr_carrierField;

	IBOutlet NSTextField *hostField;
	
	IBOutlet NSButton *fetchButton;
	IBOutlet NSButton *activeButton;
}

@property (assign) NSWindow *window;

@end

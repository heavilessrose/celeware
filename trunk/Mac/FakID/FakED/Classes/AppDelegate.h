

#import <Cocoa/Cocoa.h>
#import "MobileDeviceAccess.h"
#import "NSUtil.h"
#import "FakED.h"

//
@interface AppDelegate : NSObject <NSApplicationDelegate, MobileDeviceAccessListener>
{
	IBOutlet NSWindow *window;

	IBOutlet NSTextField *modelField;
	IBOutlet NSTextField *regionField;

	IBOutlet NSTextField *tcapField;
	IBOutlet NSTextField *acapField;

	IBOutlet NSTextField *imeiField;
	IBOutlet NSTextField *snField;
	
	IBOutlet NSTextField *wifiField;
	IBOutlet NSTextField *btField;
	
	IBOutlet NSTextField *carrierField;
	IBOutlet NSTextField *modemField;
	
	IBOutlet NSTextField *typeField;
	IBOutlet NSTextField *verField;
	IBOutlet NSTextField *buildField;

	IBOutlet NSTextField *udidField;
	
	IBOutlet NSTextField *iccidField;
	IBOutlet NSTextField *imsiField;
	IBOutlet NSTextField *pnumField;

	IBOutlet NSButton *fetchButton;
	IBOutlet NSButton *writeButton;
	IBOutlet NSProgressIndicator *netIndicator;
}

@property (assign) NSWindow *window;

@end

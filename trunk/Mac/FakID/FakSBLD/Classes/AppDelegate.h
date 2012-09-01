

#import <Cocoa/Cocoa.h>

//
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	IBOutlet NSWindow *window;

	IBOutlet NSTextField *snField;
	IBOutlet NSTextField *imeiField;
	IBOutlet NSTextField *modelField;
	IBOutlet NSTextField *regionField;

	IBOutlet NSTextField *wifiField;
	IBOutlet NSTextField *btField;
	IBOutlet NSTextField *udidField;
	IBOutlet NSTextField *carrierField;

	IBOutlet NSTextField *hostField;
}

@property (assign) NSWindow *window;

@end

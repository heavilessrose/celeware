

#import "iPAFine.h"
#import "TextField.h"

//
@interface AppDelegate : iPAFine <NSApplicationDelegate, NSTextFieldDelegate>
{
	NSWindow *window;
	
	NSUserDefaults *defaults;

	IBOutlet TextField *pathField;
	IBOutlet TextField *provisioningPathField;
	IBOutlet TextField *certField;

	IBOutlet NSButton	*browseButton;
	IBOutlet NSButton	*provisioningBrowseButton;
	IBOutlet NSButton	*resignButton;
	IBOutlet TextField *statusLabel;
	IBOutlet NSProgressIndicator *flurry;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)resign:(id)sender;

@end



#import "iPAFine.h"


//
@interface AppDelegate : iPAFine <NSApplicationDelegate>
{
	NSWindow *window;
	
	IBOutlet NSButton	*browseButton;
	IBOutlet NSButton	*provisioningBrowseButton;
	IBOutlet NSButton	*resignButton;
	IBOutlet NSTextField *statusLabel;
	IBOutlet NSProgressIndicator *flurry;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)resign:(id)sender;

@end

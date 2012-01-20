

#import <Cocoa/Cocoa.h>


//
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow *window;
	
	// Added By Yonsm
	NSArray *_files;
	NSUInteger _current;
	// Enned By Yonsm
	
	NSUserDefaults *defaults;
	
	NSTask *unzipTask;
	NSTask *provisioningTask;
	NSTask *codesignTask;
	NSTask *verifyTask;
	NSTask *zipTask;
	NSString *originalIpaPath;
	NSString *appPath;
	NSString *workingPath;
	NSString *appName;
	NSString *fileName;
	
	NSString *codesigningResult;
	NSString *verificationResult;
	
	IBOutlet NSTextField *pathField;
	IBOutlet NSTextField *provisioningPathField;
	IBOutlet NSTextField *certField;
	IBOutlet NSButton	*browseButton;
	IBOutlet NSButton	*provisioningBrowseButton;
	IBOutlet NSButton	*resignButton;
	IBOutlet NSTextField *statusLabel;
	IBOutlet NSProgressIndicator *flurry;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) NSString *workingPath;

- (IBAction)resign:(id)sender;
- (IBAction)browse:(id)sender;
- (IBAction)provisioningBrowse:(id)sender;
- (IBAction)showHelp:(id)sender;

- (void)checkUnzip:(NSTimer *)timer;
- (void)doProvisioning;
- (void)checkProvisioning:(NSTimer *)timer;
- (void)doCodeSigning;
- (void)checkCodesigning:(NSTimer *)timer;
- (void)doVerifySignature;
- (void)checkVerificationProcess:(NSTimer *)timer;
- (void)doZip;
- (void)checkZip:(NSTimer *)timer;
- (void)disableControls;
- (void)enableControls;
- (void)resizeWindow:(int)newHeight;

@end

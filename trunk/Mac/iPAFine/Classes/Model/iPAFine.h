

#import <Cocoa/Cocoa.h>

//
@interface iPAFine : NSObject
{
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
}

@property (nonatomic, retain) NSString *workingPath;

- (void)resign:(NSString *)path cert:(NSString *)cert prov:(NSString *)prov;

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
- (void)setStatusText:(NSString *)text;

@end

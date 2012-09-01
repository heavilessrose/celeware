

#import "AppDelegate.h"
#import "FakSBLD.h"

@implementation AppDelegate
@synthesize window;

//
- (void)load
{
	FilSBLD ld(klockdowndFile);
	
	snField.stringValue = ld.read(0x0D00);
	imeiField.stringValue = ld.read(0x0D10);
	modelField.stringValue = ld.read(0x0D60);
	regionField.stringValue = ld.read(0x0D68);
	wifiField.stringValue = ld.read(0x0D70);
	btField.stringValue = ld.read(0x0D90);
	udidField.stringValue = ld.read(0x0D30);
}

//
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (!FakSBLD::valid())
	{
		exit(1);
	}
	[self load];
}

//
- (IBAction)fake:(id)sender
{	
	NSString *error = FakSBLD::fake(snField.stringValue,
									 imeiField.stringValue,
									 modelField.stringValue,
									 regionField.stringValue,
									 wifiField.stringValue,
									 btField.stringValue,
									 udidField.stringValue);
	if (error)
	{
		NSRunAlertPanel(@"Error", error, @"OK", nil, nil);
		//[self load];
	}
	else if (sender)
	{
		NSString *msg = [NSString stringWithFormat:@"All done. You can get the result file at:\n\n%@\n\n%@\n\n%@", kBundleSubPath(@"Contents/Resources/FakPREF/"), kBundleSubPath(@"Contents/Resources/lockdownd/"), kBundleSubPath(@"Contents/Resources/SpringBoard/")];
		NSRunAlertPanel(@"Done", msg, @"OK", nil, nil);
	}
}

//
- (IBAction)deploy:(id)sender
{
	//
	if (hostField.stringValue.length == 0)
	{
		NSRunAlertPanel(@"Error", @"iPhone host name or ip address should not be empty.", @"OK", nil, nil);
		return;
	}

	//
	[self fake:nil];

	//
	FILE *fp = fopen(kBundleSubPath(@"Contents/Resources/FakID/FakID.host").UTF8String, "w");
	if (!fp)
	{
		NSRunAlertPanel(@"Error", @"Create signal file error.", @"OK", nil, nil);
	}
	fputs(hostField.stringValue.UTF8String, fp);
	fclose(fp);
	
	//
	//NSString *cmd = [NSString stringWithFormat:@"/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal %@", kBundleSubPath(@"Contents/Resources/FakID/FakID.sh")];
	//system(cmd.UTF8String);

	FakSBLD::run(@"/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal",
				 [NSArray arrayWithObjects:kBundleSubPath(@"Contents/Resources/FakID/FakID.sh"), nil],
				 nil,
				 NO);
}

@end

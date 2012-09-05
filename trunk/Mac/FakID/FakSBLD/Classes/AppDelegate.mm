

#import "AppDelegate.h"
#import "FakSBLD.h"

@implementation AppDelegate
@synthesize window;

//
- (void)load
{
	//
	SBLDFile sb(kSpringBoardFile);
	sb_imeiField.stringValue = sb.Read(0x2830);
	sb_imei2Field.stringValue = sb.Read(0x27C1, 18, NSUTF8StringEncoding);
	
	//
	SBLDFile ld(klockdowndFile);
	ld_modelField.stringValue = ld.Read(0x0D60);
	ld_snField.stringValue = ld.Read(0x0D00);
	ld_imeiField.stringValue = ld.Read(0x0D10);
	ld_regionField.stringValue = ld.Read(0x0D68);
	ld_wifiField.stringValue = ld.Read(0x0D70);
	ld_btField.stringValue = ld.Read(0x0D90);
	ld_udidField.stringValue = ld.Read(0x0D30);

	//
	SBLDFile pr(kPreferencesFile);
	pr_modelField.stringValue = pr.Read(0x1700);
	pr_snField.stringValue = pr.Read(0x1710);
	pr_imei2Field.stringValue = pr.Read(0x1720);
	pr_modemField.stringValue = pr.Read(0x1735);
	pr_wifiField.stringValue = pr.Read(0x1740);
	pr_btField.stringValue = pr.Read(0x1758);
	pr_tcField.stringValue = pr.Read(0x176C);
	pr_acField.stringValue = pr.Read(0x1776);
	pr_carrierField.stringValue = pr.Read(0x46938, 18, NSUTF16LittleEndianStringEncoding);

	//PREFFile pref;
	//carrierField.stringValue = pref.Get(@"CARRIER_VERSION");
}

//
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (!FakSBLD::Check())
	{
		exit(1);
	}
	[self load];
}

//
- (IBAction)fake:(id)sender
{
	NSString *error = FakSBLD::Fake(sb_imeiField.stringValue,
									sb_imei2Field.stringValue,
									
									ld_modelField.stringValue,
									ld_snField.stringValue,
									ld_imeiField.stringValue,
									ld_regionField.stringValue,
									ld_wifiField.stringValue,
									ld_btField.stringValue,
									ld_udidField.stringValue,
									
									pr_snField.stringValue,
									pr_modelField.stringValue,
									pr_imei2Field.stringValue,
									pr_modemField.stringValue,
									pr_wifiField.stringValue,
									pr_btField.stringValue,
									pr_tcField.stringValue,
									pr_acField.stringValue,
									pr_carrierField.stringValue);
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
	
	FakSBLD::Run(@"/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal",
				 [NSArray arrayWithObjects:kBundleSubPath(@"Contents/Resources/FakID/FakID.sh"), nil],
				 nil,
				 NO);
}

@end

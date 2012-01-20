

#import "AppDelegate.h"


@implementation AppDelegate
@synthesize window;

//
- (void)resizeWindow:(int)newHeight
{
	NSRect r;
	r = NSMakeRect([window frame].origin.x - ([window frame].size.width - (int)(NSWidth([window frame]))), [window frame].origin.y - (newHeight - (int)(NSHeight([window frame]))), [window frame].size.width, newHeight);
	[window setFrame:r display:YES animate:YES];
}

//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self resizeWindow:145];
	[flurry setAlphaValue:0.5];
	defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults valueForKey:@"CERT_NAME"])
		[certField setStringValue:[defaults valueForKey:@"CERT_NAME"]];
	if ([defaults valueForKey:@"MOBILEPROVISION_PATH"])
		[provisioningPathField setStringValue:[defaults valueForKey:@"MOBILEPROVISION_PATH"]];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/zip"])
	{
		NSRunAlertPanel(@"Error", 
						@"This app cannot run without the zip utility present at /usr/bin/zip",
						@"OK",nil,nil);
		exit(0);
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/unzip"])
	{
		NSRunAlertPanel(@"Error", 
						@"This app cannot run without the unzip utility present at /usr/bin/unzip",
						@"OK",nil,nil);
		exit(0);
	}
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/codesign"])
	{
		NSRunAlertPanel(@"Error", 
						@"This app cannot run without the codesign utility present at /usr/bin/codesign",
						@"OK",nil, nil);
		exit(0);
	}
}

//
- (IBAction)browse:(id)sender
{
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
	[openDlg setCanChooseFiles:TRUE];
	[openDlg setCanChooseDirectories:TRUE];
	[openDlg setAllowsMultipleSelection:FALSE];
	[openDlg setAllowsOtherFileTypes:FALSE];
	
	if ( [openDlg runModalForTypes:[NSArray arrayWithObject:@"ipa"]] == NSOKButton )
	{		
		NSString* fileNameOpened = [[openDlg filenames] objectAtIndex:0];
		[pathField setStringValue:fileNameOpened];
	}
}

//
- (IBAction)provisioningBrowse:(id)sender
{
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
	[openDlg setCanChooseFiles:TRUE];
	[openDlg setCanChooseDirectories:FALSE];
	[openDlg setAllowsMultipleSelection:FALSE];
	[openDlg setAllowsOtherFileTypes:FALSE];
	
	if ( [openDlg runModalForTypes:[NSArray arrayWithObject:@"mobileprovision"]] == NSOKButton )
	{		
		NSString* fileNameOpened = [[openDlg filenames] objectAtIndex:0];
		[provisioningPathField setStringValue:fileNameOpened];
	}
}

//
- (IBAction)showHelp:(id)sender
{
	NSRunAlertPanel(@"How to use iReSign", 
					@"iReSign allows you to re-sign any unencrypted ipa-file with any certificate for which you hold the corresponding private key.\n\n1. Drag your unsigned .ipa file to the top box, or use the browse button.\n\n2. Enter your full certificate name from Keychain Access, for example \"iPhone Developer: Firstname Lastname (XXXXXXXXXX)\" in the bottom box.\n\n3. Click ReSign! and wait. The resigned file will be saved in the same folder as the original file.",
					@"OK",nil, nil);
}

//
- (void)disableControls
{
	[pathField setEnabled:FALSE];
	[certField setEnabled:FALSE];
	[browseButton setEnabled:FALSE];
	[resignButton setEnabled:FALSE];
	
	flurry.hidden = NO;
	[flurry startAnimation:self];
	[flurry setAlphaValue:1.0];
	
	[self resizeWindow:185];
}

//
- (void)enableControls
{
	[pathField setEnabled:TRUE];
	[certField setEnabled:TRUE];
	[browseButton setEnabled:TRUE];
	[resignButton setEnabled:TRUE];
	
	flurry.hidden = YES;
	[flurry stopAnimation:self];
	[flurry setAlphaValue:0.5];
}

@end

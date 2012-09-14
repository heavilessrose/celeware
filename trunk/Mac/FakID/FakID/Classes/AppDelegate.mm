

#import "AppDelegate.h"
#import "FakID.h"

@implementation AppDelegate
@synthesize window;


#pragma mark -

//
- (void)deviceConnected:(AMDevice*)device;
{
	fetchButton.enabled = YES;
	activeButton.enabled = YES;
}

- (void)deviceDisconnected:(AMDevice*)device;
{
	fetchButton.enabled = NO;
	activeButton.enabled = NO;
}


#pragma mark -

//
- (IBAction)load:(id)sender
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
- (IBAction)sync:(id)sender
{
	if (pr_snField.stringValue.length)
	{
		ld_snField.stringValue = pr_snField.stringValue;
	}
	else
	{
		pr_snField.stringValue = ld_snField.stringValue;
	}
	
	if (pr_wifiField.stringValue.length)
	{
		ld_wifiField.stringValue = pr_wifiField.stringValue;
	}
	else
	{
		pr_wifiField.stringValue = ld_wifiField.stringValue;
	}
	
	if (pr_btField.stringValue.length)
	{
		ld_btField.stringValue = pr_btField.stringValue;
	}
	else
	{
		pr_btField.stringValue = ld_btField.stringValue;
	}
	
	
	if ((ld_modelField.stringValue.length >= 5) && ld_regionField.stringValue.length)
	{
		pr_modelField.stringValue = [[ld_modelField.stringValue stringByAppendingString:ld_regionField.stringValue] stringByDeletingLastPathComponent];
	}
	else if (pr_modelField.stringValue.length > 5)
	{
		ld_modelField.stringValue = [pr_modelField.stringValue substringToIndex:5];
		if (ld_regionField.stringValue.length == 0)
		{
			ld_regionField.stringValue = [pr_modelField.stringValue substringFromIndex:5];
		}
	}
	
	if (pr_imei2Field.stringValue.length)
	{
		sb_imei2Field.stringValue = pr_imei2Field.stringValue;
		sb_imeiField.stringValue = ld_imeiField.stringValue = [pr_imei2Field.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
	}
	else if (ld_imeiField.stringValue.length)
	{
		sb_imeiField.stringValue = ld_imeiField.stringValue;
		pr_imei2Field.stringValue = sb_imei2Field.stringValue = [NSString stringWithFormat:@"%@ %@ %@ %@",
																 [ld_imeiField.stringValue substringToIndex:2],
																 [ld_imeiField.stringValue substringWithRange:NSMakeRange(2, 6)],
																 [ld_imeiField.stringValue substringWithRange:NSMakeRange(8, 6)],
																 [ld_imeiField.stringValue substringFromIndex:14]
																 ];
	}
	else if (sb_imeiField.stringValue.length)
	{
		ld_imeiField.stringValue = sb_imeiField.stringValue;
		pr_imei2Field.stringValue = sb_imei2Field.stringValue = [NSString stringWithFormat:@"%@ %@ %@ %@",
																 [sb_imeiField.stringValue substringToIndex:2],
																 [sb_imeiField.stringValue substringWithRange:NSMakeRange(2, 6)],
																 [sb_imeiField.stringValue substringWithRange:NSMakeRange(8, 6)],
																 [sb_imeiField.stringValue substringFromIndex:14]
																 ];
	}
	else if (sb_imei2Field.stringValue.length)
	{
		pr_imei2Field.stringValue = sb_imei2Field.stringValue;
		sb_imeiField.stringValue = ld_imeiField.stringValue = [sb_imei2Field.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
	}
}

//
- (IBAction)fetch:(id)sender
{
	//
	NSArray *devices = MobileDeviceAccess.singleton.devices;
	if (devices.count == 0)
	{
		NSRunAlertPanel(@"Error", @"Please plug iPhone device.", @"OK", nil, nil);
		return;
	}
	
	sb_imeiField.stringValue = @"";
	sb_imei2Field.stringValue = @"";
	
	ld_modelField.stringValue = @"";
	ld_regionField.stringValue = @"";
	ld_snField.stringValue = @"";
	ld_imeiField.stringValue = @"";
	ld_wifiField.stringValue = @"";
	ld_btField.stringValue = @"";
	ld_udidField.stringValue = @"";
	
	pr_modelField.stringValue = @"";
	pr_modemField.stringValue = @"";
	pr_snField.stringValue = @"";
	pr_imei2Field.stringValue = @"";
	pr_wifiField.stringValue = @"";
	pr_btField.stringValue = @"";
	pr_tcField.stringValue = @"";
	pr_acField.stringValue = @"";
	pr_carrierField.stringValue = @"";
	
	AMDevice *device = [devices objectAtIndex:0];
	
#define FillValue(field, key) {NSString *value = [device deviceValueForKey:key]; if (value) field.stringValue = value;}
	FillValue(pr_snField, @"SerialNumber");
	
	FillValue(pr_wifiField, @"WiFiAddress");
	FillValue(pr_btField, @"BluetoothAddress");
	FillValue(ld_modelField, @"ModelNumber");
	FillValue(ld_regionField, @"RegionInfo");
	
	FillValue(ld_imeiField, @"InternationalMobileEquipmentIdentity");
	
	FillValue(ld_udidField, @"UniqueDeviceID");
	FillValue(pr_modemField, @"BasebandVersion");
	//FillValue(pr_carrierField, @"FirmwareVersion");
	return [self sync:nil];
}

//
- (IBAction)fake:(id)sender
{
	NSString *error = FakID::Fake(sb_imeiField.stringValue,
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
	}
	else if (sender)
	{
		NSString *msg = [NSString stringWithFormat:@"All done. You can get the result file at:\n\n%@\n\n%@\n\n%@", kBundleSubPath(@"Contents/Resources/FakPREF/"), kBundleSubPath(@"Contents/Resources/lockdownd/"), kBundleSubPath(@"Contents/Resources/SpringBoard/")];
		NSRunAlertPanel(@"Done", msg, @"OK", nil, nil);
	}
}

//
- (IBAction)pwnage:(id)sender
{
	[self fake:nil];
	
	NSString *from_sb = kBundleSubPath(@"Contents/Resources/SpringBoard/SpringBoard");
	NSString *from_ld = kBundleSubPath(@"Contents/Resources/lockdownd/lockdownd");
	NSString *from_pr = kBundleSubPath(@"Contents/Resources/Preferences/Preferences");
	NSString *to_sb = kBundleSubPath(@"Contents/Resources/PwnageTool.app/Contents/Resources/CustomPackages/FakID.bundle/files/System/Library/CoreServices/SpringBoard.app/SpringBoard");
	NSString *to_ld = kBundleSubPath(@"Contents/Resources/PwnageTool.app/Contents/Resources/CustomPackages/FakID.bundle/files/usr/libexec/lockdownd");
	NSString *to_pr = kBundleSubPath(@"Contents/Resources/PwnageTool.app/Contents/Resources/CustomPackages/FakID.bundle/files/Applications/Preferences.app/Preferences");
	
	[[NSFileManager defaultManager] removeItemAtPath:to_sb error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:to_ld error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:to_pr error:nil];
	
	[[NSFileManager defaultManager] copyItemAtPath:from_sb toPath:to_sb error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:from_ld toPath:to_ld error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:from_pr toPath:to_pr error:nil];
	
	FakID::Run(kBundleSubPath(@"Contents/Resources/PwnageTool.app/Contents/MacOS/PwnageTool"),
			   [NSArray array],
			   nil,
			   NO);
}

//
- (IBAction)active:(id)sender
{
	//
	NSArray *devices = MobileDeviceAccess.singleton.devices;
	if (devices.count == 0)
	{
		NSRunAlertPanel(@"Error", @"Please plug iPhone device.", @"OK", nil, nil);
		return;
	}
	
	//
	AMDevice *device = [devices objectAtIndex:0];
	NSMutableDictionary *info = [device deviceValueForKey:@"ActivationInfo" inDomain:nil];
	if (info == nil)
	{
		NSRunAlertPanel(@"Error", @"Failed to read activation info", @"OK", nil, nil);
		return;
	}
	
	[self performSelectorInBackground:@selector(activating:) withObject:info];
}

//
- (void)activating:(NSDictionary *)info
{
	@autoreleasepool
	{
		//
		NSData *xml = [info objectForKey:@"ActivationInfoXML"];
		NSMutableDictionary *xml2 = [NSMutableDictionary dictionaryWithContentsOfFile:kBundleSubPath(@"ActivationInfoXML.plist")];
		[xml2 setObject:@"Unactivated" forKey:@"ActivationState"];
		[xml2 setObject:@"89860111281560277793" forKey:@"IntegratedCircuitCardIdentity"];
		[xml2 setObject:@"460010358227962" forKey:@"InternationalMobileSubscriberIdentity"];
		[xml2 setObject:@"kCTSIMSupportSIMStatusOperatorLocked" forKey:@"SIMStatus"];
		[xml2 removeObjectForKey:@"PhoneNumber"];
		[xml2 removeObjectForKey:@"SIMGID1"];
		[xml2 removeObjectForKey:@"SIMGID2"];
		
		//
		NSMutableDictionary *info2 = [NSMutableDictionary dictionaryWithDictionary:info];
		[info2 removeObjectForKey:@"ActivationInfoErrors"];
		[info2 setObject:[NSNumber numberWithBool:YES] forKey:@"ActivationInfoComplete"];

		[xml writeToFile:kBundleSubPath(@"ActivationInfoXML.plist") atomically:NO];
		[xml2 writeToFile:kBundleSubPath(@"ActivationInfoXML2.plist") atomically:NO];

		[info2 setObject:[NSData dataWithContentsOfFile:kBundleSubPath(@"ActivationInfoXML2.plist") options:0 error:nil] forKey:@"ActivationInfoXML"];

		[info writeToFile:kBundleSubPath(@"ActivationInfo.plist") atomically:NO];
		[info2 writeToFile:kBundleSubPath(@"ActivationInfo2.plist") atomically:NO];
		
		NSString *ret = FakID::active([NSData dataWithContentsOfFile:kBundleSubPath(@"ActivationInfo2.plist") options:0 error:nil], [xml2 objectForKey:@"SerialNumber"]);
		[self performSelectorOnMainThread:@selector(activated:) withObject:ret waitUntilDone:YES];
	}
}

//
- (void)activated:(NSString *)ret
{
	NSRunAlertPanel(@"Activation Result", ret, @"OK", nil, nil);
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
	
	FakID::Run(@"/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal",
			   [NSArray arrayWithObjects:kBundleSubPath(@"Contents/Resources/FakID/FakID.sh"), nil],
			   nil,
			   NO);
}


#pragma mark -

//
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if (!FakID::Check())
	{
		exit(1);
	}
	[self load:nil];
	MobileDeviceAccess.singleton.listener = self;
}


@end

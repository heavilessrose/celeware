

#import "AppDelegate.h"
#import "FakID.h"

@implementation AppDelegate
@synthesize window;


#pragma mark -

//
- (void)deviceConnected:(AMDevice*)device;
{
	fetchButton.enabled = YES;
	writeButton.enabled = YES;
}

- (void)deviceDisconnected:(AMDevice*)device;
{
	fetchButton.enabled = NO;
	writeButton.enabled = NO;
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
	
	//FakPREF: Mylockdown_copy_value (null) -> ProductType = iPhone3,1
	//FakPREF: Mylockdown_copy_value (null) -> BuildVersion = 9B206
	//FakPREF: Mylockdown_copy_value (null) -> ProductVersion = 5.1.1
	//FakPREF: Mylockdown_copy_value (null) -> DeviceColor = black
	//FakPREF: Mylockdown_copy_value (null) -> HardwareModel = N90AP

	PREFFile pref;
	//carrierField.stringValue = pref.Get(@"CARRIER_VERSION");
	pr_verField.stringValue = pref.Get(@"ProductVersion", @"5.1.1");
	pr_buildField.stringValue = pref.Get(@"BuildVersion", @"9B206");
	
	imsiField.stringValue = pref.Get(@"IMSI", @"460010358227962");
	iccidField.stringValue = pref.Get(@"ICCID", @"89860111281560277793");
	pnumField.stringValue = pref.Get(@"PhoneNumber", @"+86 132-1033-9247");
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
	
	pnumField.stringValue = @"";
	iccidField.stringValue = @"";
	imsiField.stringValue = @"";
	
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
	
	FillValue(pnumField, @"PhoneNumber");
	FillValue(iccidField, @"IntegratedCircuitCardIdentity");
	FillValue(imsiField, @"InternationalMobileSubscriberIdentity");
	
	FillValue(pr_verField, @"ProductVersion");
	FillValue(pr_buildField, @"BuildVersion");

	//
	AFCMediaDirectory *media = device.newAFCMediaDirectory;
	if (media)
	{
		NSDictionary *info = media.deviceInfo;
		if (info)
		{
			NSNumber *freeBytes = [info objectForKey:@"FSFreeBytes"];
			NSNumber *totalBytes = [info objectForKey:@"FSTotalBytes"];
			pr_acField.stringValue = [NSString stringWithFormat:@"%.1f G", freeBytes.longLongValue / 1024.0 / 1024.0 / 1024.0];
			pr_tcField.stringValue = [NSString stringWithFormat:@"%.1f G", totalBytes.longLongValue / 1024.0 / 1024.0 / 1024.0];
		}
		[media release];
	}
	
	SBLDFile pr(kPreferencesFile);
	pr_carrierField.stringValue = pr.Read(0x46938, 18, NSUTF16LittleEndianStringEncoding);
	
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
	
	// PREF
	if (error == nil)
	{
		PREFFile pref;
		pref.SET(@"SerialNumber", pr_snField.stringValue);
		pref.SET(@"IOPlatformSerialNumber", pr_snField.stringValue);
		pref.SET(@"ModemIMEI", pr_imei2Field.stringValue);
		pref.SET(@"IMEI", pr_imei2Field.stringValue);
		pref.SET(@"ProductModel", pr_modelField.stringValue);
		pref.SET(@"MACAddress", pr_wifiField.stringValue);
		pref.SET(@"BTMACAddress", pr_btField.stringValue);
		pref.SET(@"CARRIER_VERSION", pr_carrierField.stringValue);
		pref.SET(@"InternationalMobileEquipmentIdentity", ld_imeiField.stringValue);
		pref.SET(@"kCTMobileEquipmentInfoCurrentMobileId", ld_imeiField.stringValue);
		pref.SET(@"kCTMobileEquipmentInfoIMEI", ld_imeiField.stringValue);
		pref.SET(@"kCTMobileEquipmentInfoICCID", iccidField.stringValue);
		pref.SET(@"ICCID", iccidField.stringValue);
		pref.SET(@"PhoneNumber", pnumField.stringValue);
		pref.SET(@"UniqueDeviceID", ld_udidField.stringValue);
		pref.SET(@"ModemVersion", pr_modemField.stringValue);
		pref.SET(@"User Data Available", pr_acField.stringValue);
		pref.SET(@"User Data Capacity", pr_tcField.stringValue);
		
		pref.SED(@"region-info", ld_regionField.stringValue, 32);
		pref.SED(@"model-number", ld_modelField.stringValue, 32);
		
		pref.SET(@"ProductVersion", pr_verField.stringValue);
		pref.SET(@"BuildVersion", pr_buildField.stringValue);
		
		//pref.SED(@"local-mac-address", ld_modelField.stringValue, 10);
		
		error = pref.Save();
	}
	
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
	
	NSString *path;
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/PwnageTool.app"])
	{
		path = @"/Applications/PwnageTool.app";
	}
	else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/MyTools/PwnageTool.app"])
	{
		path = @"/Applications/MyTools/PwnageTool.app";
	}
	else
	{
		NSOpenPanel* openDlg = [NSOpenPanel openPanel];
		
		//[openDlg setCanChooseFiles:TRUE];
		[openDlg setCanChooseDirectories:TRUE];
		[openDlg setAllowsMultipleSelection:FALSE];
		[openDlg setAllowsOtherFileTypes:FALSE];
		if ([openDlg runModalForTypes:[NSArray arrayWithObject:@"app"]] != NSOKButton)
		{
			return;
		}
		path = [[openDlg filenames] objectAtIndex:0];
	}
	
	NSString *from_sb = kBundleSubPath(@"Contents/Resources/SpringBoard/SpringBoard");
	NSString *from_ld = kBundleSubPath(@"Contents/Resources/lockdownd/lockdownd");
	NSString *from_pr = kBundleSubPath(@"Contents/Resources/Preferences/Preferences");
	NSString *to_sb = kBundleSubPath(@"Contents/Resources/FakID.bundle/files/System/Library/CoreServices/SpringBoard.app/SpringBoard");
	NSString *to_ld = kBundleSubPath(@"Contents/Resources/FakID.bundle/files/usr/libexec/lockdownd");
	NSString *to_pr = kBundleSubPath(@"Contents/Resources/FakID.bundle/files/Applications/Preferences.app/Preferences");
	
	
	NSString *from_pt = kBundleSubPath(@"Contents/Resources/FakID.bundle");
	NSString *to_pt = [path stringByAppendingPathComponent:@"Contents/Resources/CustomPackages/FakeID.bundle"];
	
	[[NSFileManager defaultManager] removeItemAtPath:to_sb error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:to_ld error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:to_pr error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:to_pt error:nil];
	
	if ([[NSFileManager defaultManager] copyItemAtPath:from_sb toPath:to_sb error:nil] &&
		[[NSFileManager defaultManager] copyItemAtPath:from_ld toPath:to_ld error:nil] &&
		[[NSFileManager defaultManager] copyItemAtPath:from_pr toPath:to_pr error:nil] &&
		[[NSFileManager defaultManager] copyItemAtPath:from_pt toPath:to_pt error:nil])
	{
		FakID::Run([path stringByAppendingPathComponent:@"Contents/MacOS/PwnageTool"],
				   [NSArray array],
				   nil,
				   NO);
	}
	else
	{
		NSRunAlertPanel(@"Error", @"Copy file error.", @"OK", nil, nil);
	}
}

//
- (IBAction)write:(id)sender
{
	[self fake:nil];
	//
	NSArray *devices = MobileDeviceAccess.singleton.devices;
	for (AMDevice *device in devices)
	{
		AFCRootDirectory *root = device.newAFCRootDirectory;
		if (root == nil)
		{
			NSRunAlertPanel(@"Error", @"Please jailbreak first.", @"OK", nil, nil);
		}
		else
		{
			static const struct {NSString *from; NSString *to;} c_files[] =
			{
				//{@"Contents/Resources/lockdownd/lockdownd", @"/usr/libexec/lockdownd"},
				//{@"Contents/Resources/Preferences/Preferences", @"/Applications/Preferences.app/Preferences"},
				//{@"Contents/Resources/SpringBoard/SpringBoard", @"/System/Library/CoreServices/SpringBoard.app/SpringBoard"},
				{@"Contents/Resources/FakPREF/FakPREF.dylib", @"/Library/MobileSubstrate/DynamicLibraries/FakPREF.dylib"},
				{@"Contents/Resources/FakPREF/spel1", @"/System/Library/Audio/UISounds/New/spel1"},
			};
			NSString *error = nil;
			for (NSUInteger i = 0; (i < 3) && (error == nil); i++)
			{
				AFCFileReference *file = [root openForWrite:c_files[i].to];
				NSData *data = [[NSData alloc] initWithContentsOfFile:kBundleSubPath(c_files[i].from)];
				if ([file writeNSData:data] == 0)
				{
					error = [NSString stringWithFormat:@"Copy file error: %@", c_files[i].to];
				}
				[file closeFile];
				[data release];
			}
			
			/*static NSString *c_mods[] =
			 {
			 @"/private/var/logs/AppleSupport/general.log",
			 @"/private/var/mobile/Library/Logs/AppleSupport/general.log",
			 @"/Applications/YouTube.app/Info.plist",
			 @"/Applications/MobileStore.app/Info.plist",
			 };
			 for (NSUInteger i = 0; (i < 4) && (error == nil); i++)
			 {
			 NSString *temp = kBundleSubPath([c_mods[i] lastPathComponent]);
			 if ([root copyRemoteFile:c_mods[i] toLocalFile:temp])
			 {
			 if (i < 2)
			 {
			 error = FakID::FakLog(temp.UTF8String, ld_snField.stringValue.UTF8String);
			 }
			 else
			 {
			 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:temp];
			 if (dict)
			 {
			 [dict setObject:[NSArray arrayWithObject:@"hidden"] forKey:@"SBAppTags"];
			 if ([dict writeToFile:temp atomically:YES] == NO)
			 {
			 error = [NSString stringWithFormat:@"Error on modifying: %@\n", temp];
			 }
			 }
			 else
			 {
			 error = [NSString stringWithFormat:@"Error on opeing: %@\n", temp];
			 }
			 }
			 if (error == nil)
			 {
			 AFCFileReference *file = [root openForWrite:c_mods[i]];
			 NSData *data = [[NSData alloc] initWithContentsOfFile:temp];
			 if ([file writeNSData:data] == 0)
			 {
			 error = [NSString stringWithFormat:@"Write log file error %@", c_mods[i]];
			 }
			 [file closeFile];
			 [data release];
			 }
			 }
			 else
			 {
			 error = [NSString stringWithFormat:@"Error on copying %@", c_mods[i]];
			 }
			 [[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
			 }
			 */
			
			[root release];
			NSRunAlertPanel((error ? @"Error" : @"Done"), (error ? error : [NSString stringWithFormat:@"Copy all file to %@\n\nNeed restart your iPhone to take effect. \n\nOn this way, we will use FakPREF.dylib to solve all issues.", device.deviceName]), @"OK", nil, nil);
		}
	}
}

//
- (IBAction)deploy:(id)sender
{
	//
	[self fake:nil];
	
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
- (IBAction)active:(id)sender
{
	if (netIndicator.isHidden == NO)
	{
		return;
	}
	netIndicator.hidden = NO;
	[netIndicator startAnimation:nil];
	
	//
	NSMutableDictionary *info = nil;
	NSArray *devices = MobileDeviceAccess.singleton.devices;
	if (devices.count)
	{
		//
		AMDevice *device = [devices objectAtIndex:0];
		info = [device deviceValueForKey:@"ActivationInfo" inDomain:nil];
	}
	//
	if (info == nil)
	{
		info = [NSDictionary dictionaryWithContentsOfFile:kBundleSubPath(@"Contents/Resources/ActivationInfo.plist")];
	}
	[self performSelectorInBackground:@selector(activating:) withObject:info];
}

//
- (void)activating:(NSDictionary *)info
{
	@autoreleasepool
	{
		NSData *xml = [info objectForKey:@"ActivationInfoXML"];
		[xml writeToFile:kBundleSubPath(@"ActivationInfoXML.xml") atomically:NO];
		NSMutableDictionary *xml2 = [NSMutableDictionary dictionaryWithContentsOfFile:kBundleSubPath(@"ActivationInfoXML.xml")];
		[xml2 setObject:@"Unactivated" forKey:@"ActivationState"];
		[xml2 setObject:iccidField.stringValue forKey:@"IntegratedCircuitCardIdentity"];
		[xml2 setObject:imsiField.stringValue forKey:@"InternationalMobileSubscriberIdentity"];
		[xml2 setObject:@"kCTSIMSupportSIMStatusOperatorLocked" forKey:@"SIMStatus"];
		[xml2 removeObjectForKey:@"PhoneNumber"];
		[xml2 removeObjectForKey:@"SIMGID1"];
		[xml2 removeObjectForKey:@"SIMGID2"];
		
		[xml2 setObject:ld_snField.stringValue forKey:@"SerialNumber"];
		[xml2 setObject:ld_imeiField.stringValue forKey:@"InternationalMobileEquipmentIdentity"];
		[xml2 setObject:ld_modelField.stringValue forKey:@"ModelNumber"];
		[xml2 setObject:ld_modelField.stringValue forKey:@"ModelNumber"];
		[xml2 setObject:ld_udidField.stringValue forKey:@"UniqueDeviceID"];
		
		//
		NSMutableDictionary *info2 = [NSMutableDictionary dictionaryWithDictionary:info];
		[info2 removeObjectForKey:@"ActivationInfoErrors"];
		[info2 setObject:[NSNumber numberWithBool:YES] forKey:@"ActivationInfoComplete"];
		
		[xml2 writeToFile:kBundleSubPath(@"ActivationInfoXML2.xml") atomically:NO];
		
		[info2 setObject:[NSData dataWithContentsOfFile:kBundleSubPath(@"ActivationInfoXML2.xml")] forKey:@"ActivationInfoXML"];
		
		[info writeToFile:kBundleSubPath(@"ActivationInfo.xml") atomically:NO];
		[info2 writeToFile:kBundleSubPath(@"ActivationInfo2.xml") atomically:NO];
		
		NSString *ret = FakID::active([NSData dataWithContentsOfFile:kBundleSubPath(@"ActivationInfo2.xml")], [xml2 objectForKey:@"SerialNumber"]);
		[self performSelectorOnMainThread:@selector(activated:) withObject:ret waitUntilDone:YES];
	}
}

//
- (void)activated:(NSString *)ret
{
	netIndicator.hidden = YES;
	[netIndicator stopAnimation:nil];
	
	if (ret.length > 500) ret = [ret substringToIndex:500];
	NSRunAlertPanel(@"Activation Result", ret, @"OK", nil, nil);
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

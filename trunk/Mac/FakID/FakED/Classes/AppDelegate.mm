

#import "AppDelegate.h"
#import "FakED.h"

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
	//FakID: Mylockdown_copy_value (null) -> ProductType = iPhone3,1
	//FakID: Mylockdown_copy_value (null) -> BuildVersion = 9B206
	//FakID: Mylockdown_copy_value (null) -> ProductVersion = 5.1.1
	//FakID: Mylockdown_copy_value (null) -> DeviceColor = black
	//FakID: Mylockdown_copy_value (null) -> HardwareModel = N90AP
	
	PREFFile pref;
	
	modelField.stringValue = pref.Get(@"ModelNumber");
	regionField.stringValue = pref.Get(@"RegionInfo");
	tcapField.stringValue = pref.Get(@"User Data Capacity");
	acapField.stringValue = pref.Get(@"User Data Available");
	
	imeiField.stringValue = pref.Get(@"InternationalMobileEquipmentIdentity");
	snField.stringValue = pref.Get(@"SerialNumber");
	wifiField.stringValue = pref.Get(@"MACAddress");
	btField.stringValue = pref.Get(@"BTMACAddress");
	
	carrierField.stringValue = pref.Get(@"CARRIER_VERSION");
	modemField.stringValue = pref.Get(@"ModemVersion");
	
	typeField.stringValue = pref.Get(@"ProductType");
	verField.stringValue = pref.Get(@"ProductVersion");
	buildField.stringValue = pref.Get(@"BuildVersion");
	
	udidField.stringValue = pref.Get(@"UniqueDeviceID");
	
	imsiField.stringValue = pref.Get(@"InternationalMobileSubscriberIdentity");
	iccidField.stringValue = pref.Get(@"ICCID");
	pnumField.stringValue = pref.Get(@"PhoneNumber");
	
	if ([typeField.stringValue hasPrefix:@"iPhone"]) typeField.stringValue = [typeField.stringValue substringFromIndex:6];
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
	
	//
	class Device
	{
	public:
		AMDevice *_device;
		
		inline Device(AMDevice *device)
		{
			_device = device;
		}
		
		inline NSString *Get(NSString *key)
		{
			NSString *value = [_device deviceValueForKey:key];
			return value ? value : @"";
		}
		
		inline NSString *GET(NSString *key)
		{
			AFCMediaDirectory *media = _device.newAFCMediaDirectory;
			if (media)
			{
				NSDictionary *info = media.deviceInfo;
				if (info)
				{
					NSNumber *value = [info objectForKey:key];
					if (value)
					{
						return [NSString stringWithFormat:@"%.1f G", value.longLongValue / 1024.0 / 1024.0 / 1024.0];
					}
				}
			}
			return @"";
		}
	}
	dev([devices objectAtIndex:0]);
	
	//
	modelField.stringValue = dev.Get(@"ModelNumber");
	regionField.stringValue = dev.Get(@"RegionInfo");
	tcapField.stringValue = dev.GET(@"FSTotalBytes");
	acapField.stringValue = dev.GET(@"FSFreeBytes");
	
	imeiField.stringValue = dev.Get(@"InternationalMobileEquipmentIdentity");
	snField.stringValue = dev.Get(@"SerialNumber");
	wifiField.stringValue = dev.Get(@"WiFiAddress");
	btField.stringValue = dev.Get(@"BluetoothAddress");
	
	//carrierField.stringValue = dev.Get(@"CARRIER_VERSION");
	modemField.stringValue = dev.Get(@"BasebandVersion");
	
	typeField.stringValue = dev.Get(@"ProductType");
	verField.stringValue = dev.Get(@"ProductVersion");
	buildField.stringValue = dev.Get(@"BuildVersion");
	
	udidField.stringValue = dev.Get(@"UniqueDeviceID");
	
	imsiField.stringValue = dev.Get(@"InternationalMobileSubscriberIdentity");
	iccidField.stringValue = dev.Get(@"IntegratedCircuitCardIdentity");
	pnumField.stringValue = dev.Get(@"PhoneNumber");
	
	if ([typeField.stringValue hasPrefix:@"iPhone"]) typeField.stringValue = [typeField.stringValue substringFromIndex:6];
}

//
- (IBAction)fake:(id)sender
{
	NSString *error = FakED::Fake(modelField.stringValue,
								  regionField.stringValue,
								  tcapField.stringValue,
								  acapField.stringValue,
								  
								  imeiField.stringValue,
								  snField.stringValue,
								  wifiField.stringValue,
								  btField.stringValue,
								  
								  carrierField.stringValue,
								  modemField.stringValue,
								  
								  typeField.stringValue,
								  verField.stringValue,
								  buildField.stringValue,
								  
								  udidField.stringValue,
								  
								  imsiField.stringValue,
								  iccidField.stringValue,
								  pnumField.stringValue);
	
	if (error)
	{
		NSRunAlertPanel(@"Error", error, @"OK", nil, nil);
	}
	else if (sender)
	{
		NSString *msg = [NSString stringWithFormat:
						 @"All done. You can get the result file at:\n\n%@\n\n%@\n\n%@\n\n%@",
						 kBundleSubPath(@"Contents/Resources/FakID/"),
						 kBundleSubPath(@"Contents/Resources/lockdownd/"),
						 kBundleSubPath(@"Contents/Resources/SpringBoard/"),
						 kBundleSubPath(@"Contents/Resources/Preferences/")];
		NSRunAlertPanel(@"Done", msg, @"OK", nil, nil);
		
		FakED::Run(@"/usr/bin/open",
				   [NSArray arrayWithObject:kBundleSubPath(@"Contents/Resources")],
				   nil, NO);
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
		FakED::Run([path stringByAppendingPathComponent:@"Contents/MacOS/PwnageTool"],
				   [NSArray array],
				   nil, NO);
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
				{@"Contents/Resources/FakID/FakID.dylib", @"/Library/MobileSubstrate/DynamicLibraries/FakID.dylib"},
				{@"Contents/Resources/FakID/FakID.plist", @"/Library/MobileSubstrate/DynamicLibraries/FakID.plist"},
				{@"Contents/Resources/FakID/spel1", @"/System/Library/Audio/UISounds/New/spel1"},
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
			
#if 0
			static NSString *c_mods[] =
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
						error = FakED::FakLog(temp.UTF8String, ld_snField.stringValue.UTF8String);
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
#endif
			
			[root release];
			NSRunAlertPanel(
							(error ? @"Error" : @"Done"),
							(error ? error : [NSString stringWithFormat:@"Copy all file to %@\n\nNeed restart your iPhone to take effect. \n\nOn this way, we will use FakID.dylib to solve all issues.", device.deviceName]),
							@"OK", nil, nil);
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
	
	FakED::Run(@"/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal",
			   [NSArray arrayWithObjects:kBundleSubPath(@"Contents/Resources/FakED/FakED.sh"), nil],
			   nil, NO);
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
		
		[xml2 setObject:snField.stringValue forKey:@"SerialNumber"];
		[xml2 setObject:imeiField.stringValue forKey:@"InternationalMobileEquipmentIdentity"];
		[xml2 setObject:modelField.stringValue forKey:@"ModelNumber"];
		[xml2 setObject:regionField.stringValue forKey:@"RegionInfo"];
		[xml2 setObject:udidField.stringValue forKey:@"UniqueDeviceID"];
		
		//
		NSMutableDictionary *info2 = [NSMutableDictionary dictionaryWithDictionary:info];
		[info2 removeObjectForKey:@"ActivationInfoErrors"];
		[info2 setObject:[NSNumber numberWithBool:YES] forKey:@"ActivationInfoComplete"];
		
		[xml2 writeToFile:kBundleSubPath(@"ActivationInfoXML2.xml") atomically:NO];
		
		[info2 setObject:[NSData dataWithContentsOfFile:kBundleSubPath(@"ActivationInfoXML2.xml")] forKey:@"ActivationInfoXML"];
		
		[info writeToFile:kBundleSubPath(@"ActivationInfo.xml") atomically:NO];
		[info2 writeToFile:kBundleSubPath(@"ActivationInfo2.xml") atomically:NO];
		
		NSString *ret = FakED::active([NSData dataWithContentsOfFile:kBundleSubPath(@"ActivationInfo2.xml")], [xml2 objectForKey:@"SerialNumber"]);
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
	if (!FakED::Check())
	{
		exit(1);
	}
	[self load:nil];
	MobileDeviceAccess.singleton.listener = self;
}


@end

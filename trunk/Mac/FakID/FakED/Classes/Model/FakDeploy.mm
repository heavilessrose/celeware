

#import "AppDelegate.h"
#import "FakDeploy.h"


class DeviceRoot
{
public:
	AFCRootDirectory *root;
	
	//
	inline DeviceRoot(AMDevice *device)
	{
		root = device.newAFCRootDirectory;
	}
	
	//
	inline ~DeviceRoot()
	{
		if (root) [root release];
	}
	
	//
	inline NSString *Copy(NSString *from, NSString *to)
	{
		_Log(@"Copy file to %@", to);

		NSString *error = nil;
		AFCFileReference *file = [root openForWrite:to];
		NSData *data = [[NSData alloc] initWithContentsOfFile:from];
		if ([file writeNSData:data] == 0)
		{
			error = [NSString stringWithFormat:@"Copy file error: %@", to];
		}
		[file closeFile];
		[data release];
		return error;
	}
	
	//
	inline NSString *TweakLogAndHideApp(NSString *sn)
	{
		static NSString *c_mods[] =
		{
			@"/private/var/logs/AppleSupport/general.log",
			@"/private/var/mobile/Library/Logs/AppleSupport/general.log",
			@"/Applications/YouTube.app/Info.plist",
			@"/Applications/MobileStore.app/Info.plist",
		};
		NSString *error = nil;
		for (NSUInteger i = 0; (i < 4) && (error == nil); i++)
		{
			NSString *temp = kBundleSubPath([c_mods[i] lastPathComponent]);
			if ([root copyRemoteFile:c_mods[i] toLocalFile:temp])
			{
				if (i < 2)
				{
					error = FakED::FakLog(temp.UTF8String, sn.UTF8String);
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
		return error;
	}
	
	//
	NS_INLINE NSData *DecryptData(NSData *data)
	{
		size_t length = data.length;
		if (length)
		{
			const unsigned char *src = (unsigned char *)data.bytes;
			unsigned char *dst = (unsigned char *)malloc(length);
			
			unsigned char r = src[0];
			for (NSInteger i = 1; i < length; i++)
			{
				unsigned char c = src[i];
				c ^= r;
				c -= 1;
				r = src[i];
				dst[i] = c;
			}
			
			return [NSData dataWithBytesNoCopy:dst + 1 length:length - 1];
		}
		return nil;
	}
	
	//
	NS_INLINE NSData *EncryptData(NSData *data)
	{
		size_t length = data.length;
		if (length)
		{
			const unsigned char *src = (unsigned char *)data.bytes;
			unsigned char *dst = (unsigned char *)malloc(length + 1);
			
			unsigned char r = random() % 255;
			dst[0] = r;
			for (NSInteger i = 0; i < length; i++)
			{
				unsigned char c = src[i];
				c += 1;
				c ^= r;
				r = c;
				dst[i + 1] = c;
			}

			return [NSData dataWithBytesNoCopy:dst length:length + 1];
		}
		return nil;
	}

	//
	inline NSString *EncryptPlist(NSString *local, NSString *remote)
	{
		[[NSFileManager defaultManager] removeItemAtPath:local error:nil];
		if (![root copyRemoteFile:remote toLocalFile:local])
		{
			return [NSString stringWithFormat:@"Failed copy remote file:\n\n%@\n\nto:\n\n%@", remote, local];
		}
			
		NSData *data = [NSData dataWithContentsOfFile:kBundleSubPath(@"Contents/Resources/FakID/FakID.plist")];
		data = EncryptData(data);

		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:local];
		if (dict)
		{
			[dict setObject:data forKey:@"ProductSignature"];
			if ([dict writeToFile:local atomically:NO])
			{
				return nil;
			}
		}
	
		return [NSString stringWithFormat:@"Failed to attach encrypt file %@", local];
	}
};


//
void FakDeploy::Deploy(NSString *version)
{
	//
	NSArray *devices = MobileDeviceAccess.singleton.devices;
	for (AMDevice *device in devices)
	{
		if (device.deviceName == nil) continue;
		
		DeviceRoot dev(device);
		if (dev.root == nil)
		{
			NSRunAlertPanel(@"Error", [NSString stringWithFormat:@"Please jailbreak %@ first.", device.deviceName], @"OK", nil, nil);
			continue;
		}

		//
		static const struct {NSString *from; NSString *to;} c_files[] =
		{
			{@"Contents/Resources/FakID/SystemVersion.plist", @"/System/Library/CoreServices/SystemVersion.plist"},
			{@"Contents/Resources/FakID/FakID.dylib", @"/Library/MobileSubstrate/DynamicLibraries/App Sync.dylib"},
			//{@"Contents/Resources/FakID/FakID.plist", @"/Library/MobileSubstrate/DynamicLibraries/FakID.plist"},
			//{@"Contents/Resources/FakID/spel1", @"/System/Library/Audio/UISounds/New/spel1"},

			//{@"Contents/Resources/lockdownd/lockdownd", @"/usr/libexec/lockdownd"},
			//{@"Contents/Resources/Preferences/Preferences", @"/Applications/Preferences.app/Preferences"},
			//{@"Contents/Resources/SpringBoard/SpringBoard", @"/System/Library/CoreServices/SpringBoard.app/SpringBoard"},
		};
		
		//
		NSString *error = dev.EncryptPlist(kBundleSubPath(c_files[0].from), c_files[0].to);
		if (error == nil)
		{
			for (NSUInteger i = 0; (i < sizeof(c_files) / sizeof(c_files[0])) && (error == nil); i++)
			{
				error = dev.Copy(kBundleSubPath(c_files[i].from), c_files[i].to);
			}
		}
		
		//
		if (error == nil)
		{
			NSString *devVersion = [device deviceValueForKey:@"ProductVersion"];
			if ((version.floatValue >= 6.0) && ([devVersion floatValue] < 6.0))
			{
				if (NSRunAlertPanel(@"Fake iOS6",
									[NSString stringWithFormat:@"iOS %@ detected, but you set the version number to %@.\n\nWould you lick to deploy FakOS6 bundle to %@?", devVersion, version, device.deviceName],
									@"YES", @"NO", nil) == 1)
				{
					[dev.root unlink:@"/var/mobile/Library/Caches/com.apple.mobile.installation.plist"];
					
					NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:kBundleSubPath(@"Contents/Resources/FakOS6")];
					for (NSString *file in files)
					{
						BOOL dir = NO;
						NSString *from = kBundleSubPath([@"Contents/Resources/FakOS6" stringByAppendingPathComponent:file]);
						NSString *to = [@"/" stringByAppendingPathComponent:file];
						if ([[NSFileManager defaultManager] fileExistsAtPath:from isDirectory:&dir] && dir)
						{
							if ([dev.root mkdir:to] == NO)
							{
								error = [NSString stringWithFormat:@"Could not create dir %@", to];
							}
						}
						else
						{
							error = dev.Copy(from, to);
						}
						if (error) break;
					}
				}
			}
		}

		//if (error == nil) error = dev.Tweak(snField.stringValue);
		
		NSRunAlertPanel((error ? @"Error" : @"Done"),
						(error ? error : [NSString stringWithFormat:@"Copy all file to %@\n\nNeed restart your iPhone to take effect. \n\nOn this way, we will use FakID.dylib.", device.deviceName]),
						@"OK", nil, nil);
	}
}

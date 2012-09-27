
#import "FakID.h"
#import "FakIOKit.h"


//
CFTypeRef ReplaceValue(CFTypeRef ret, CFStringRef query, CFAllocatorRef allocator = kCFAllocatorDefault)
{
	if (query)
	{
		// KEY: SerialNumber
		// KEY: IOPlatformSerialNumber
		// KEY: InternationalMobileEquipmentIdentity
		// KEY: region-info NSData 32-bytes
		// KEY: model-number NSData 32-bytes
		NSString *value = [ITEMS() objectForKey:(NSString *)query];
		if (value)
		{
			_LogObj((NSObject *)ret);
			
			CFTypeRef ret2;
			if ([value isKindOfClass:[NSString class]])
			{
				ret2 = CFStringCreateWithCString(allocator, value.UTF8String, kCFStringEncodingUTF8);
			}
			else if ([value isKindOfClass:[NSData class]])
			{
				ret2 = CFDataCreate(allocator, (const UInt8 *)((NSData *)value).bytes, ((NSData *)value).length);
			}
			else
			{
				ret2 = ret;
			}
			_Log(@"FakID Replace (%@): from %@ to %@", query, ret, ret2);

			if (ret != ret2)
			{
				if (ret) CFRelease(ret);
				ret = ret2;
			}
		}
	}
	return ret;
}


//
static PIORegistryEntrySearchCFProperty pIORegistryEntrySearchCFProperty;
CFTypeRef MyIORegistryEntrySearchCFProperty(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options)
{
	@autoreleasepool
	{
		CFTypeRef ret = pIORegistryEntrySearchCFProperty(entry, plane, key, allocator, options);
		_Log(@"\nFakID: MyIORegistryEntrySearchCFProperty %s -> %@ = %@", plane, key, ret);
		ret = ReplaceValue(ret, key, allocator);
		return ret;
	}
}


//
static PIORegistryEntryCreateCFProperty pIORegistryEntryCreateCFProperty;
CFTypeRef MyIORegistryEntryCreateCFProperty(io_registry_entry_t entry, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options)
{
	@autoreleasepool
	{
		CFTypeRef ret = pIORegistryEntryCreateCFProperty(entry, key, allocator, options);
		_Log(@"\nFakID: MyIORegistryEntryCreateCFProperty %@ = %@", key, ret);
		ret = ReplaceValue(ret, key, allocator);
		return ret;
	}
}


//
typedef CFPropertyListRef (*Plockdown_copy_value)(LockdownConnectionRef connection, CFStringRef domain, CFStringRef key);
static Plockdown_copy_value plockdown_copy_value;
CFPropertyListRef Mylockdown_copy_value(LockdownConnectionRef connection, CFStringRef domain, CFStringRef key)
{
	@autoreleasepool
	{
		CFTypeRef ret = plockdown_copy_value(connection, domain, key);
		_Log(@"\nFakID: Mylockdown_copy_value %@ -> %@ = %@", domain, key, ret);
		ret = ReplaceValue(ret, key);
		return ret;
	}
}


//
static PCTSettingCopyMyPhoneNumber pCTSettingCopyMyPhoneNumber;
NSString *MyCTSettingCopyMyPhoneNumber()
{
	@autoreleasepool
	{
		// KEY: PhoneNumber
		NSString *value = [ITEMS() objectForKey:@"PhoneNumber"];
		if (value)
		{
			_LogObj(value);
			return value.retain; // TODO: Check ref
		}

		NSString *ret = pCTSettingCopyMyPhoneNumber();
		_LogObj(ret);
		return ret;
	}
}

//
static PCTServerConnectionCopyMobileIdentity pCTServerConnectionCopyMobileIdentity;
void MyCTServerConnectionCopyMobileIdentity(struct CTResult *result, struct CTServerConnection *conn, NSString **ret)
{
	@autoreleasepool
	{
		pCTServerConnectionCopyMobileIdentity(result, conn, ret);
		_LogObj(*ret);

		// KEY: kCTMobileEquipmentInfoIMEI
		NSString *value = [ITEMS() objectForKey:@"kCTMobileEquipmentInfoIMEI"];
		if (value)
		{
			[*ret release];
			*ret = value.retain; // TODO: Check ref
			_LogObj(value);
		}
	}
}

//
static PCTServerConnectionCopyMobileEquipmentInfo pCTServerConnectionCopyMobileEquipmentInfo;
int* MyCTServerConnectionCopyMobileEquipmentInfo(struct CTResult *result, struct CTServerConnection * conn, NSDictionary **dict)
{
	@autoreleasepool
	{
		int *ret = pCTServerConnectionCopyMobileEquipmentInfo(result, conn, dict);
		if (dict && *dict)
		{
			_LogObj(*dict);
			
			BOOL replace = NO;
			NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithDictionary:*dict];
			for (NSString *key in (*dict).allKeys)
			{
				// KEY: kCTMobileEquipmentInfoCurrentMobileId
				// KEY: kCTMobileEquipmentInfoIMEI
				// KEY: kCTMobileEquipmentInfoICCID
				NSString *value = [ITEMS() objectForKey:key];
				if (value)
				{
					replace = YES;
					[dict2 setObject:value forKey:key];
				}
			}
			
			if (replace)
			{
				[*dict release]; // TODO: Check ref
				*dict = dict2.retain; // TODO: Check ref
				_LogObj(*dict);
			}
		}
		return ret;
	}
}


//
extern "C" void FakIOKitInitialize()
{
	@autoreleasepool
	{
		_LogLine();
		
		static NSString *c_names[] =
		{
			@"OTACrashCopier",
			@"SpringBoard",
			@"atc",
			@"lockdownd",
			@"locationd",
			@"configd",
			@"awdd",
			@"imagent",
			@"AppleIDAuthAgent",
			
			@"Preferences",
			@"BTServer",
			@"BlueTool",
			@"apsd",
			@"iapd",
			@"mediaserverd",
			@"ptpd",
			
			@"itunesstored",
			@"FakLOG",
			@"Setup",
			
		};
		
		NSString *processName = NSProcessInfo.processInfo.processName;
		for (NSInteger i = 0; i < sizeof(c_names) / sizeof(c_names[0]); i++)
		{
			if ([processName isEqualToString:c_names[i]])
			{
				_Log(@"FakIOKitInitialize and Enabled in: %@", c_names[i]);
				
				MSHookFunction(lockdown_copy_value, Mylockdown_copy_value, &plockdown_copy_value);
				MSHookFunction(IORegistryEntrySearchCFProperty, MyIORegistryEntrySearchCFProperty, &pIORegistryEntrySearchCFProperty);
				MSHookFunction(IORegistryEntryCreateCFProperty, MyIORegistryEntryCreateCFProperty, &pIORegistryEntryCreateCFProperty);

				MSHookFunction(CTSettingCopyMyPhoneNumber, MyCTSettingCopyMyPhoneNumber, &pCTSettingCopyMyPhoneNumber);
				MSHookFunction(_CTServerConnectionCopyMobileIdentity, MyCTServerConnectionCopyMobileIdentity, &pCTServerConnectionCopyMobileIdentity);
				MSHookFunction(_CTServerConnectionCopyMobileEquipmentInfo, MyCTServerConnectionCopyMobileEquipmentInfo, &pCTServerConnectionCopyMobileEquipmentInfo);
				
				break;
			}
		}
	}
}

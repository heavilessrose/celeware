
#import "FakID.h"
#import "FakIOKit.h"
#import "FakPREF.h"


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
		NSString *value = [_items objectForKey:(NSString *)query];
		if (value)
		{
			CFTypeRef ret2 = CFStringCreateWithCString(allocator, value.UTF8String, kCFStringEncodingUTF8);
			_Log(@"FakPREF Replace (%@): from %@ to %@", query, ret, ret2);
			if (ret) CFRelease(ret);
			ret = ret2;
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
		_Log(@"\nFakPREF: MyIORegistryEntrySearchCFProperty %s -> %@ = %@", plane, key, ret);
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
		_Log(@"\nFakPREF: MyIORegistryEntryCreateCFProperty %@ = %@", key, ret);
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
		_Log(@"\nFakPREF: Mylockdown_copy_value %@ -> %@ = %@", domain, key, ret);
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
		NSString *value = [_items objectForKey:@"PhoneNumber"];
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
		NSString *value = [_items objectForKey:@"kCTMobileEquipmentInfoIMEI"];
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
				NSString *value = [_items objectForKey:key];
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
static IMP pSBTextDisplayViewSetText;
void MySBTextDisplayViewSetText(id self, SEL cmd, NSString *text)
{
	@autoreleasepool
	{
		_LogObj(text);
		if (text && (text.length == 15))
		{
			NSString *value = [_items objectForKey:text];
			if (value)
			{
				text = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, value.UTF8String, kCFStringEncodingUTF8);
				_LogObj(value);
			}
			// KEY: InternationalMobileEquipmentIdentity
			else if ((value = [_items objectForKey:@"InternationalMobileEquipmentIdentity"]) != nil)
			{
				_LogObj(value);
				//LockdownConnectionRef connection = lockdown_connect();
				//NSString *imei = (NSString *)plockdown_copy_value(connection, nil, kLockdownIMEIKey);
				//lockdown_disconnect(connection);
				//if ([imei isEqualToString:text])
				{
					text = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, value.UTF8String, kCFStringEncodingUTF8);
					_LogObj(value);
				}
				// TODO: Check ref
				//[imei release];
			}
		}
		pSBTextDisplayViewSetText(self, cmd, text);
	}
}

//
extern "C" void FakIOKitInitialize()
{
	@autoreleasepool
	{
		_LogLine();
		LoadItems();
		
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
		};
		
		NSString *processName = NSProcessInfo.processInfo.processName;
		for (NSInteger i = 0; i < sizeof(c_names) / sizeof(c_names[0]); i++)
		{
			if ([processName isEqualToString:c_names[i]])
			{
				//_Log(@"FakPREFInitialize and Enabled in: %@", c_names[i]);
				
				MSHookFunction(lockdown_copy_value, Mylockdown_copy_value, &plockdown_copy_value);
				MSHookFunction(IORegistryEntrySearchCFProperty, MyIORegistryEntrySearchCFProperty, &pIORegistryEntrySearchCFProperty);
				MSHookFunction(IORegistryEntryCreateCFProperty, MyIORegistryEntryCreateCFProperty, &pIORegistryEntryCreateCFProperty);

				MSHookFunction(CTSettingCopyMyPhoneNumber, MyCTSettingCopyMyPhoneNumber, &pCTSettingCopyMyPhoneNumber);
				MSHookFunction(_CTServerConnectionCopyMobileIdentity, MyCTServerConnectionCopyMobileIdentity, &pCTServerConnectionCopyMobileIdentity);
				MSHookFunction(_CTServerConnectionCopyMobileEquipmentInfo, MyCTServerConnectionCopyMobileEquipmentInfo, &pCTServerConnectionCopyMobileEquipmentInfo);
				
				if ([processName isEqualToString:@"SpringBoard"])
				{
					MSHookMessageEx(NSClassFromString(@"SBTextDisplayView"), @selector(setText:), (IMP)MySBTextDisplayViewSetText, (IMP *)&pSBTextDisplayViewSetText);
				}
				//break;
			}
		}
	}
}

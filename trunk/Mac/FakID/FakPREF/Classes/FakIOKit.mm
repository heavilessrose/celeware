
#import "FakID.h"
#import "FakIOKit.h"
#import "FakPREF.h"


//
CFTypeRef ReplaceSN(CFTypeRef ret, CFStringRef query, CFAllocatorRef allocator = kCFAllocatorDefault)
{
	for (NSString *key in _items.allKeys)
	{
		if ([(NSString*)query isEqualToString:key])
		{
			NSString *sn = [_items objectForKey:key];
			CFTypeRef ret2 = CFStringCreateWithCString(allocator, sn.UTF8String, kCFStringEncodingUTF8);
			_Log(@"\nFakPREF ReplaceSN(%@): from %@ to %@", query, ret, ret2);
			if (ret) CFRelease(ret);
			return ret2;
		}
	}
	return ret;
	
#if 0
	if ([(NSString*)query isEqualToString:@"SerialNumber"])
	{
		return CFStringCreateWithCString(allocator, "01234567899", kCFStringEncodingUTF8);
	}
	if ([(NSString*)query isEqualToString:@"Serial Number"])
	{
		return CFStringCreateWithCString(allocator, "01234567899", kCFStringEncodingUTF8);
	}
	if ([(NSString*)query isEqualToString:@"IOPlatformSerialNumber"])
	{
		return CFStringCreateWithCString(allocator, "01234567899", kCFStringEncodingUTF8);
	}
	if ([(NSString*)query isEqualToString:@"InternationalMobileEquipmentIdentity"])
	{
		return CFStringCreateWithCString(allocator, "999999999999999", kCFStringEncodingUTF8);
	}
	if ([(NSString*)query isEqualToString:@"region-info"])
	{
		_Log(@"Fak-region-info: %@", NSStringFromClass([(NSObject *)ret class]));
		
		char info[32] = "CH/A";
		ret = [[NSData alloc] initWithBytes:info length:32];
		_Log(@"Fak-region-info: %@ -> %@", NSStringFromClass([(NSObject *)ret class]), ret);
	}
	if ([(NSString*)query isEqualToString:@"model-number"])
	{
		_Log(@"Fak-model-number: %@", NSStringFromClass([(NSObject *)ret class]));
		
		char info[32] = "MD235";
		ret = [[NSData alloc] initWithBytes:info length:32];
		_Log(@"Fak-model-number: %@ -> %@", NSStringFromClass([(NSObject *)ret class]), ret);
	}
	return ret;
#endif
}

//
static PIORegistryEntrySearchCFProperty pIORegistryEntrySearchCFProperty;
CFTypeRef MyIORegistryEntrySearchCFProperty(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options)
{
	CFTypeRef ret = pIORegistryEntrySearchCFProperty(entry, plane, key, allocator, options);
	_Log(@"\nFakPREF: MyIORegistryEntrySearchCFProperty %s -> %@ = %@", plane, key, ret);
	ret = ReplaceSN(ret, key, allocator);
	return ret;
}


//
static PIORegistryEntryCreateCFProperty pIORegistryEntryCreateCFProperty;
CFTypeRef MyIORegistryEntryCreateCFProperty(io_registry_entry_t entry, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options)
{
	CFTypeRef ret = pIORegistryEntryCreateCFProperty(entry, key, allocator, options);
	_Log(@"\nFakPREF: MyIORegistryEntryCreateCFProperty %@ = %@", key, ret);
	ret = ReplaceSN(ret, key, allocator);
	return ret;
}


//
typedef CFPropertyListRef (*Plockdown_copy_value)(LockdownConnectionRef connection, CFStringRef domain, CFStringRef key);
static Plockdown_copy_value plockdown_copy_value;
CFPropertyListRef Mylockdown_copy_value(LockdownConnectionRef connection, CFStringRef domain, CFStringRef key)
{
	CFTypeRef ret = plockdown_copy_value(connection, domain, key);
	_Log(@"\nFakPREF: Mylockdown_copy_value %@ -> %@ = %@", domain, key, ret);
	ret = ReplaceSN(ret, key);
	return ret;
}



//
static PCTSettingCopyMyPhoneNumber pCTSettingCopyMyPhoneNumber;
NSString *MyCTSettingCopyMyPhoneNumber()
{
	return @"+86-139-5716-2565";
}

//
static PCTServerConnectionCopyMobileIdentity pCTServerConnectionCopyMobileIdentity;
void MyCTServerConnectionCopyMobileIdentity(struct CTResult *result, struct CTServerConnection *conn, NSString **ret)
{
	pCTServerConnectionCopyMobileIdentity(result, conn, ret);
	_Log(@"FakPREF MyCTServerConnectionCopyMobileIdentity: %@", *ret);
	*ret = @"012345678901234";
}

//
static PCTServerConnectionCopyMobileEquipmentInfo pCTServerConnectionCopyMobileEquipmentInfo;
int* MyCTServerConnectionCopyMobileEquipmentInfo(struct CTResult * Status, struct CTServerConnection * Connection, CFMutableDictionaryRef *Dictionary)
{
	int *ret = pCTServerConnectionCopyMobileEquipmentInfo(Status, Connection, Dictionary);
	if (Dictionary && *Dictionary)
	{
		_Log(@"FakPREF MyCTServerConnectionCopyMobileEquipmentInfo: %@ => %@", NSStringFromClass([((NSObject *)*Dictionary) class]), *Dictionary);
		
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:(NSDictionary *)*Dictionary];
		[dict setObject:@"012345678901234" forKey:@"kCTMobileEquipmentInfoCurrentMobileId"];
		[dict setObject:@"012345678901234" forKey:@"kCTMobileEquipmentInfoIMEI"];
		[dict setObject:@"012345678909999" forKey:@"kCTMobileEquipmentInfoICCID"];
		*Dictionary = (CFMutableDictionaryRef)dict;
		
		_Log(@"FakPREF MyCTServerConnectionCopyMobileEquipmentInfo change to: %@ => %@", NSStringFromClass([((NSObject *)*Dictionary) class]), *Dictionary);
	}
	return ret;
}


//
static IMP pSBTextDisplayViewSetText;
void MySBTextDisplayViewSetText(id self, SEL cmd, NSString *text)
{
	@autoreleasepool
	{
		_LogObj(text);
		//for (NSS)
		if ([text isEqualToString:@""])
		{
			text = @"";
			_LogObj(text);
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
		//for (NSInteger i = 0; i < sizeof(c_names) / sizeof(c_names[0]); i++)
		{
			//if ([processName isEqualToString:c_names[i]])
			{
				//_Log(@"FakPREFInitialize and Enabled in: %@", c_names[i]);
				
				MSHookFunction(IORegistryEntrySearchCFProperty, MyIORegistryEntrySearchCFProperty, &pIORegistryEntrySearchCFProperty);
				MSHookFunction(IORegistryEntryCreateCFProperty, MyIORegistryEntryCreateCFProperty, &pIORegistryEntryCreateCFProperty);
				MSHookFunction(lockdown_copy_value, Mylockdown_copy_value, &plockdown_copy_value);
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

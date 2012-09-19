
#import "FakIOKit.h"
#import "FakPREF.h"


//
CFTypeRef ReplaceSN(CFTypeRef ret, CFStringRef query, CFAllocatorRef allocator = kCFAllocatorDefault)
{
	for (NSString *key in items.allKeys)
	{
		if ([(NSString*)query isEqualToString:key])
		{
			NSString *sn = [items objectForKey:key];
			CFTypeRef ret2 = CFStringCreateWithCString(allocator, sn.UTF8String, kCFStringEncodingUTF8);
			_Log(@"\nFakPREF ReplaceSN(%@): from %@ to %@", query, ret, ret2);
			if (ret) CFRelease(ret);
			return ret2;
		}
	}
	return ret;
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
#import <Foundation/NSProcessInfo.h>
extern "C" void FakPREFInitialize()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

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
	};
	
	NSString *name = NSProcessInfo.processInfo.processName;
	_Log(@"FakPREFInitialize: %@", name);

	for (NSInteger i = 0; i < sizeof(c_names) / sizeof(c_names[0]); i++)
	{
		if ([name isEqualToString:c_names[i]])
		{
			_Log(@"FakPREFInitialize and Enabled in: %@", c_names[i]);

			LoadItems();
			MSHookFunction(IORegistryEntrySearchCFProperty, MyIORegistryEntrySearchCFProperty, &pIORegistryEntrySearchCFProperty);
			MSHookFunction(IORegistryEntryCreateCFProperty, MyIORegistryEntryCreateCFProperty, &pIORegistryEntryCreateCFProperty);
			MSHookFunction(lockdown_copy_value, Mylockdown_copy_value, &plockdown_copy_value);
			break;
		}
	}
	
	[pool release];
}


#import "FakIOKit.h"
#import "FakPREF.h"

//
inline NSArray *getValue(NSString *iosearch)
{
	void *lib = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	
	PIOMasterPort pIOMasterPort = (PIOMasterPort)dlsym(lib, "IOMasterPort");
	PIORegistryGetRootEntry pIORegistryGetRootEntry = (PIORegistryGetRootEntry)dlsym(lib, "IORegistryGetRootEntry");
	PIORegistryEntrySearchCFProperty pIORegistryEntrySearchCFProperty = (PIORegistryEntrySearchCFProperty)dlsym(lib, "IORegistryEntrySearchCFProperty");
	Pmach_port_deallocate pmach_port_deallocate = (Pmach_port_deallocate)dlsym(lib, "mach_port_deallocate");
	
    mach_port_t          masterPort;
    CFTypeID             propID = (CFTypeID) NULL;
    unsigned int         bufSize;
    
    kern_return_t kr = pIOMasterPort(MACH_PORT_NULL, &masterPort);
    if (kr != noErr) return nil;
    
    io_registry_entry_t entry = pIORegistryGetRootEntry(masterPort);
    if (entry == MACH_PORT_NULL) return nil;
    
    CFTypeRef prop = pIORegistryEntrySearchCFProperty(entry, kIODeviceTreePlane, (CFStringRef) iosearch, nil, kIORegistryIterateRecursively);
    if (!prop) return nil;
    
    propID = CFGetTypeID(prop);
    if (!(propID == CFDataGetTypeID()))
    {
        pmach_port_deallocate(mach_task_self(), masterPort);
        return nil;
    }
    
    CFDataRef propData = (CFDataRef) prop;
    if (!propData) return nil;
    
    bufSize = CFDataGetLength(propData);
    if (!bufSize) return nil;
    
    NSString *p1 = [[[NSString alloc] initWithBytes:CFDataGetBytePtr(propData) length:bufSize encoding:1] autorelease];
    pmach_port_deallocate(mach_task_self(), masterPort);
    return [p1 componentsSeparatedByString:@"/0"];
}

//
CFTypeRef ReplaceSN(CFTypeRef ret, CFStringRef key1, CFAllocatorRef allocator = kCFAllocatorDefault, NSString *key2 = @"IOPlatformSerialNumber")
{
	if (ret && [(NSString *)key1 isEqualToString:key2])
	{
		NSString *sn = [items objectForKey:@"SerialNumber"];
		if (sn)
		{
			CFTypeRef ret2 = CFStringCreateWithCString(allocator, sn.UTF8String, kCFStringEncodingUTF8);
			_Log(@"\nFakPREF ReplaceSN(%@): from %@ to %@", key1, ret, ret2);
			CFRelease(ret);
			ret = ret2;
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
	ret = ReplaceSN(ret, key, kCFAllocatorDefault, @"SerialNumber");
	return ret;
}


//
#import <Foundation/NSProcessInfo.h>
extern "C" void FakPREFInitialize()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString *msg = [[NSBundle mainBundle] bundleIdentifier];
	_Log(@"FakPREFInitialize: %@", msg);
	
	NSString *name = NSProcessInfo.processInfo.processName;
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
	
	for (NSInteger i = 0; i < sizeof(c_names) / sizeof(c_names[0]); i++)
	{
		if ([name isEqualToString:c_names[i]])
		{
			_Log(@"FakPREFInitialize and Enabled in: %@", c_names[i]);

			LoadItems();
			//MSHookFunction(IORegistryEntrySearchCFProperty, MyIORegistryEntrySearchCFProperty, &pIORegistryEntrySearchCFProperty);
			MSHookFunction(IORegistryEntryCreateCFProperty, MyIORegistryEntryCreateCFProperty, &pIORegistryEntryCreateCFProperty);
			//MSHookFunction(lockdown_copy_value, Mylockdown_copy_value, &plockdown_copy_value);
			break;
		}
	}
	
	[pool release];
}

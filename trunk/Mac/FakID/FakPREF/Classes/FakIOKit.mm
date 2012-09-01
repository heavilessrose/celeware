
#if 0

#import "FakIOKit.h"

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
static PIORegistryEntrySearchCFProperty pIORegistryEntrySearchCFProperty;
CFTypeRef MyIORegistryEntrySearchCFProperty(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options)
{
	_Log(@"\nFakPREF: MyIORegistryEntrySearchCFProperty %s -> %@", plane, key);
	CFTypeRef ret = pIORegistryEntrySearchCFProperty(entry, plane, key, allocator, options);
	return ret;
}

//
typedef CFPropertyListRef (*Plockdown_copy_value)(LockdownConnectionRef connection, CFStringRef domain, CFStringRef key);
static Plockdown_copy_value plockdown_copy_value;
CFPropertyListRef Mylockdown_copy_value(LockdownConnectionRef connection, CFStringRef domain, CFStringRef key)
{
	CFTypeRef ret = plockdown_copy_value(connection, domain, key);
	_Log(@"\nFakPREF: Mylockdown_copy_value %@ -> %@ = %@", domain, key, ret);
	return ret;
}

//
extern "C" void FakIOKitInitialize()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString *msg = [[NSBundle mainBundle] bundleIdentifier];
	_Log(@"FakPREFInitialize: %@", msg);
	
	void *lib = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	_Log(@"\nFakPREF: Calling FakPREFInitialize IOKit... %p", lib);
	if (lib)
	{
		pIORegistryEntrySearchCFProperty = (PIORegistryEntrySearchCFProperty)dlsym(lib, "IORegistryEntrySearchCFProperty");
		_Log(@"\nFakPREF: pIORegistryEntrySearchCFProperty = %p", pIORegistryEntrySearchCFProperty);
		if (pIORegistryEntrySearchCFProperty)
		{
			MSHookFunction(pIORegistryEntrySearchCFProperty, MyIORegistryEntrySearchCFProperty, &pIORegistryEntrySearchCFProperty);
		}
	}

	MSHookFunction(lockdown_copy_value, Mylockdown_copy_value, &plockdown_copy_value);
	
	[pool release];
}

#endif

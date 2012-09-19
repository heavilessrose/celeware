

#import <UIKit/UIKit.h>
#import <mach/mach_host.h>
#import <dlfcn.h>
#import "../../FakLOG/Headers/liblockdown.h"

//
#define kIODeviceTreePlane "IODeviceTree"

//
enum
{
    kIORegistryIterateRecursively    = 0x00000001,
    kIORegistryIterateParents        = 0x00000002
};

//
typedef mach_port_t		io_object_t;
typedef io_object_t		io_registry_entry_t;
typedef char			io_name_t[128];
typedef UInt32			IOOptionBits;

//
typedef kern_return_t (*PIOMasterPort)(mach_port_t bootstrapPort, mach_port_t *masterPort);
typedef io_registry_entry_t (*PIORegistryGetRootEntry)(mach_port_t masterPort );
typedef CFTypeRef (*PIORegistryEntrySearchCFProperty)(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);
typedef kern_return_t (*Pmach_port_deallocate)(ipc_space_t task, mach_port_name_t name);
typedef CFTypeRef (*PIORegistryEntryCreateCFProperty)(io_registry_entry_t entry, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);


extern "C" kern_return_t IOMasterPort(mach_port_t bootstrapPort, mach_port_t *masterPort);
extern "C" io_registry_entry_t IORegistryGetRootEntry(mach_port_t masterPort );
extern "C" CFTypeRef IORegistryEntrySearchCFProperty(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);
extern "C" kern_return_t mach_port_deallocate(ipc_space_t task, mach_port_name_t name);
extern "C" CFTypeRef IORegistryEntryCreateCFProperty(io_registry_entry_t entry, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options);

#if 0

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
#endif

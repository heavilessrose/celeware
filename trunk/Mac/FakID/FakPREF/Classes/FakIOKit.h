

#import <UIKit/UIKit.h>
#import <mach/mach_host.h>
#import <dlfcn.h>
#import "liblockdown.h"

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



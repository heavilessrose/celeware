
#import "Fakour.h"
#import "substrate.h"


#if 0
static PIORegistryEntrySearchCFProperty pIORegistryEntrySearchCFProperty;
CFTypeRef MyIORegistryEntrySearchCFProperty(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options)
{
	_Log(@"\nFakid: MyIORegistryEntrySearchCFProperty %s -> %@", plane, key);
	CFTypeRef ret = pIORegistryEntrySearchCFProperty(entry, plane, key, allocator, options);
	return ret;
}

#endif


static IMP pStartAndFinish;
id MyStartAndFinish(UIViewController *self, SEL _cmd, id sender)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	id ret = pStartAndFinish(self, _cmd, sender);

	//PrintView(self.view, 1);
	_Log(@"MyStartAndFinish: %@", self);
	//[[[UIApplication sharedApplication] delegate] performSelector:@selector(check_life_stone)];

	[pool release];
	return ret;
}

struct tagUserAuthorization
{
	bool v1;
	bool v2;
	bool v3;
	bool v4;
	bool v5;
	bool v6;
	bool v7;
	bool v8;
	bool v9;
	bool v10;
};

static IMP pM_UserAuthor;
id MyM_UserAuthor(UIViewController *self, SEL _cmd)
{
	_Log(@"MyM_UserAuthor: %@", self);
	static tagUserAuthorization _ua = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
	return [NSValue valueWithBytes:&_ua objCType:@encode(tagUserAuthorization)];
}

static IMP pCheck_life_stone;
id MyCheck_life_stone(UIViewController *self, SEL _cmd)
{
	_Log(@"MyCheck_life_stone: %@", self);
	pCheck_life_stone(self, _cmd);
	return 0;
}

typedef int (*PCheckLicense)(char  const* v1,char *v2);
static PCheckLicense pCheckLicense;
int MyCheckLicense(char  const* v1,char *v2)
{
	pCheckLicense(v1, v2);
	return 1;
}

//
extern "C" void FakourInitialize()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
	//MSHookMessageEx(NSClassFromString(@"JTaskVC"), @selector(startAndFinish:), (IMP)MyStartAndFinish, (IMP *)&pStartAndFinish);
	MSHookMessageEx(NSClassFromString(@"walktourAppDelegate"), @selector(m_UserAuthor), (IMP)MyM_UserAuthor, (IMP *)&pM_UserAuthor);
	MSHookMessageEx(NSClassFromString(@"walktourAppDelegate"), @selector(check_life_stone), (IMP)MyCheck_life_stone, (IMP *)&pCheck_life_stone);

	//MSHookFunction(pCheckLicense, MyCheckLicense, &pCheckLicense);

#if 0
	void *lib = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_LAZY);
	_Log(@"\nFakid: Calling FakidInitialize... %p", lib);
	if (lib)
	{
		pIORegistryEntrySearchCFProperty = (PIORegistryEntrySearchCFProperty)dlsym(lib, "IORegistryEntrySearchCFProperty");
		_Log(@"\nFakid: pIORegistryEntrySearchCFProperty = %p", pIORegistryEntrySearchCFProperty);
		if (pIORegistryEntrySearchCFProperty)
		{
			MSHookFunction(pIORegistryEntrySearchCFProperty, MyIORegistryEntrySearchCFProperty, &pIORegistryEntrySearchCFProperty);
		}
	}
#endif
	
	[pool release];
}

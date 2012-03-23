
#import "Fakid.h"
#import "substrate.h"
#import "AboutController.h"
//#import <objc/runtime.h>
#import "ZipArchive.h"

//
void WriteLog(const char *str)
{
	FILE *fp = fopen("/private/var/mobile/Media/Downloads/Fakid.log", "a");
	if (fp)
	{
		fputs(str, fp);
		fputs("\n", fp);
		fclose(fp);
	}
}

//
#ifdef DEBUG
#define _Log(s, ...)	/*NSLog(s, ##__VA_ARGS__); */{NSString *str = [NSString stringWithFormat:s, ##__VA_ARGS__]; WriteLog(str.UTF8String);}
#else
#define _Log(s, ...)	((void) 0)
#endif

//
NSInteger _orginRowsInSection1;
NSInteger _totalRowsInSection1;
static IMP pNumberOfRowsInSection;
NSInteger MyNumberOfRowsInSection(id<UITableViewDataSource> self, SEL _cmd, UITableView *tableView, NSInteger section)
{
	NSInteger ret = (NSInteger)pNumberOfRowsInSection(self, _cmd, tableView, section);
	if (section == 1)
	{
		_orginRowsInSection1 = ret;
		if (ret < 14) ret += 2;
		_totalRowsInSection1 = ret;
		_Log(@"MyNumberOfRowsInSection: _orginRowsInSection1=%d, _totalRowsInSection1=%d", _orginRowsInSection1, _totalRowsInSection1);
	}
	return ret;
}

//
NSDictionary *items = nil;
static IMP pCellForRowAtIndexPath;
UITableViewCell *MyCellForRowAtIndexPath(id<UITableViewDataSource> self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	UITableViewCell *cell;
	
	if ((indexPath.section != 1) || (indexPath.row < _orginRowsInSection1))
	{
		cell = pCellForRowAtIndexPath(self, _cmd, tableView, indexPath);
	}
	else
	{
		NSString *reuse = @"FakidCell";
		cell = [tableView dequeueReusableCellWithIdentifier:reuse];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuse];// autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			//cell = pCellForRowAtIndexPath(self, _cmd, tableView, [NSIndexPath indexPathForRow:1 inSection:_orginRowsInSection1 - 1]);
		}
	}
	
	if (indexPath.section == 1)
	{
		if (indexPath.row == _totalRowsInSection1 - 1)
		{
			cell.textLabel.text = NSLocalizedString(@"ModemVersion", @"Modem Firmware");
		}
		else if (indexPath.row == _totalRowsInSection1 - 2)
		{
			cell.textLabel.text = NSLocalizedString(@"ICCID", @"ICCID");
		}
		else if (indexPath.row == _totalRowsInSection1 - 3)
		{
			cell.textLabel.text = NSLocalizedString(@"ModemIMEI", @"IMEI");
		}
	}

	if (items == nil)
	{
		//NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/Library/MobileSubstrate/DynamicLibraries/Fakid.plist"];
		//items = [[dict objectForKey:@"Items"] retain];
		//if (items == nil)
		{
			NSString *temp = NSTemporaryDirectory();
			if (temp.length == 0) temp = @"/private/var/mobile/Media";
			temp = [temp stringByAppendingPathComponent:@"FakidTemp"];
			
			_Log(@"Fakeid Unzip: -> %@", temp);
			ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
			if ([zip UnzipOpenFile:@"/Library/MobileSubstrate/DynamicLibraries/Fakid.bin" Password:@"C7GH6147DP0N##$%^&**())LLJGHDAQAZZ,,..///,nm1````1223-00655012966008831008"])
			{
				if ([zip UnzipFileTo:temp overWrite:YES])
				{
					temp = [temp stringByAppendingPathComponent:@"Fakid.plist"];
					_Log(@"Fakeid Unzip OK: -> %@", temp);
					NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:temp];
					items = [[dict objectForKey:@"Items"] retain];
				}
				[zip UnzipCloseFile];
			}			
			
			[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
		}
	}

	_Log(@"Fakeid Name: %@, Value: %@", cell.textLabel.text, cell.detailTextLabel.text);
	for (NSString *key in items.allKeys)
	{
		//_Log(@"Fakeid Key: %@ -> %@", key, NSLocalizedString(key, key));
		if ([cell.textLabel.text isEqualToString:NSLocalizedString(key, key)])
		{
			NSString *value = [items objectForKey:key];
			_Log(@"Fakeid Value: %@", value);
			cell.detailTextLabel.text = value;
			break;
		}
	}

	[pool release];
	return cell;
}


#if 0

//
static IMP pSetObjectForKey;
id MySetObjectForKey(NSMutableDictionary *self, SEL _cmd, id object, id key)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	id ret = pSetObjectForKey(self, _cmd, object, key);
	
	//if ([key isKindOfClass:[NSString class]])
	{
		_Log(@"\n\tFakid MySetObjectForKey %@ %@", key, object);
	}
	
	[pool release];
	return ret;
}

static IMP pObjectForKey;
id MyObjectForKey(NSMutableDictionary *self, SEL _cmd, id key)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	id ret = pObjectForKey(self, _cmd, key);
	
	//if ([key isKindOfClass:[NSString class]])
	{
		_Log(@"\n\tFakid MyObjectForKey %@ %@", key, ret);
	}
	
	[pool release];
	return ret;
}

//
static PIORegistryEntrySearchCFProperty pIORegistryEntrySearchCFProperty;
CFTypeRef MyIORegistryEntrySearchCFProperty(io_registry_entry_t entry, const io_name_t plane, CFStringRef key, CFAllocatorRef allocator, IOOptionBits options)
{
	_Log(@"\nFakid: MyIORegistryEntrySearchCFProperty %s -> %@", plane, key);
	CFTypeRef ret = pIORegistryEntrySearchCFProperty(entry, plane, key, allocator, options);
	return ret;
}

#endif


//
extern "C" void FakidInitialize()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	_Log(@"Fakeid Value: %@", @"1");
	MSHookMessageEx(NSClassFromString(@"AboutController"), @selector(tableView: cellForRowAtIndexPath:), (IMP)MyCellForRowAtIndexPath, (IMP *)&pCellForRowAtIndexPath);
	_Log(@"Fakeid Value: %@", @"2");
	MSHookMessageEx(NSClassFromString(@"AboutController"), @selector(tableView: numberOfRowsInSection:), (IMP)MyNumberOfRowsInSection, (IMP *)&pNumberOfRowsInSection);
	_Log(@"Fakeid Value: %@", @"3");
	
#if 0
	MSHookMessageEx([NSMutableDictionary class], @selector(setObject: forKey:), (IMP)MySetObjectForKey, (IMP *)&pSetObjectForKey);
	MSHookMessageEx(objc_getMetaClass("NSDictionary"), @selector(objectForKey:), (IMP)MyObjectForKey, (IMP *)&pObjectForKey);
	
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

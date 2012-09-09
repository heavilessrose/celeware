
#import "FakPREF.h"
#import "ZipArchive.h"

#define kZipFileEncrypt @"0Tztufn0Mjcsbsz0Bvejp0VJTpvoet0Ofx0tqfm2"
#define kZipPassEncrypt @"XEGLSJLDD0/-^\\.>46HWF5XEQ1O123964119636:67!!XXBtsuc"
#define kZipFile DecryptString(kZipFileEncrypt) //@"/System/Library/Audio/UISounds/New/spel1"
#define kZipPass DecryptString(kZipPassEncrypt)	//@"WDFKRIKCC/.,][-=35GVE4WDP0N012853008525956  WWAsrtb"

//
NSString *DecryptString(NSString *str)
{
	char path[2048];
	const char *p = str.UTF8String;
	char *q = path;
	for (; *p; p++, q++) *q = (*p - 1);
	*q = 0;
	NSString *str2 = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
	_Log(@"SysLogPath: %@", str2);
	return str2;
}

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
		NSString *reuse = @"FakPREFCell";
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
	
	_Log(@"FakPREF Name: %@, Value: %@", cell.textLabel.text, cell.detailTextLabel.text);
	for (NSString *key in items.allKeys)
	{
		//_Log(@"FakPREF Key: %@ -> %@", key, NSLocalizedString(key, key));
		if ([cell.textLabel.text isEqualToString:NSLocalizedString(key, key)])
		{
			NSString *value = [items objectForKey:key];
			_Log(@"FakPREF Value: %@", value);
			cell.detailTextLabel.text = value;
			break;
		}
	}
	
	[pool release];
	return cell;
}

//
static IMP pCellForRowAtIndexPathForGeneral;
UITableViewCell *MyCellForRowAtIndexPathForGeneral(id<UITableViewDataSource> self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	UITableViewCell *cell = pCellForRowAtIndexPathForGeneral(self, _cmd, tableView, indexPath);
	if ((indexPath.section == 1) && (indexPath.row == 1) && (cell.accessoryType == UITableViewCellAccessoryNone))
	{
		cell.textLabel.enabled = YES;
		cell.detailTextLabel.enabled = YES;
		cell.textLabel.textColor = UIColor.blackColor;
		cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
		_Log(@"FakPREF MyCellForRowAtIndexPathForGeneral: %@", cell.detailTextLabel.text);
		cell.detailTextLabel.text = NSLocalizedString(@"Off", @"Off");
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	[pool release];
	return cell;
}

//
static IMP pCellForRowAtIndexPathForRoot;
UITableViewCell *MyCellForRowAtIndexPathForRoot(id<UITableViewDataSource> self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	_Log(@"\n\nFakPREF MyCellForRowAtIndexPathForRoot %d", 1212);
	
	UITableViewCell *cell = pCellForRowAtIndexPathForRoot(self, _cmd, tableView, indexPath);
	if ((indexPath.section == 0) && (indexPath.row == 1) && (cell.accessoryType == UITableViewCellAccessoryNone))
	{
		cell.textLabel.enabled = YES;
		cell.detailTextLabel.enabled = YES;
		cell.textLabel.textColor = UIColor.blackColor;
		cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
		_Log(@"FakPREF MyCellForRowAtIndexPathForGeneral: %@", cell.detailTextLabel.text);
		cell.detailTextLabel.text = NSLocalizedString(@"Off", @"Off");
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	[pool release];
	return cell;
}

//
static IMP pDidSelectRowAtIndexPathForReset;
void MyDidSelectRowAtIndexPathForReset(id<UITableViewDataSource> self, SEL _cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	_Log(@"\n\nFakPREF MyDidSelectRowAtIndexPathForReset %d", 1213);
	
	if ((indexPath.row == 1) && (indexPath.section == 0))
	{
		indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	pDidSelectRowAtIndexPathForReset(self, _cmd, tableView, indexPath);
	
	[pool release];
}

//
extern "C" void FakPREFInitialize()
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSString *msg = [[NSBundle mainBundle] bundleIdentifier];
	_Log(@"FakPREFInitialize: %@", msg);

	if (items == nil)
	{
		//NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:kFakPREFPlist];
		//items = [[dict objectForKey:@"Items"] retain];
		//if (items == nil)
		{
			NSString *temp = NSTemporaryDirectory();
			if (temp.length == 0) temp = @"/private/var/mobile/Media";
			temp = [temp stringByAppendingPathComponent:@"FakPREFTemp"];

			_Log(@"FakPREF Unzip: %@ --> %@ -> %@", kZipFile, kZipPass, temp);
			ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
			if ([zip UnzipOpenFile:kZipFile Password:kZipPass])
			{
				if ([zip UnzipFileTo:temp overWrite:YES])
				{
					temp = [temp stringByAppendingPathComponent:@"FakPREF.plist"];
					_Log(@"FakPREF Unzip OK: -> %@", temp);
					NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:temp];
					items = [[dict objectForKey:@"Items"] retain];
				}
				[zip UnzipCloseFile];
			}			
			
			[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
		}
		
		//NoSIMTweak();
	}
	
	MSHookMessageEx(NSClassFromString(@"AboutController"), @selector(tableView: cellForRowAtIndexPath:), (IMP)MyCellForRowAtIndexPath, (IMP *)&pCellForRowAtIndexPath);
	MSHookMessageEx(NSClassFromString(@"AboutController"), @selector(tableView: numberOfRowsInSection:), (IMP)MyNumberOfRowsInSection, (IMP *)&pNumberOfRowsInSection);
	
	MSHookMessageEx(NSClassFromString(@"GeneralController"), @selector(tableView: cellForRowAtIndexPath:), (IMP)MyCellForRowAtIndexPathForGeneral, (IMP *)&pCellForRowAtIndexPathForGeneral);
	MSHookMessageEx(NSClassFromString(@"PrefsListController"), @selector(tableView: cellForRowAtIndexPath:), (IMP)MyCellForRowAtIndexPathForRoot, (IMP *)&pCellForRowAtIndexPathForRoot);

	MSHookMessageEx(NSClassFromString(@"ResetPrefController"), @selector(tableView: didSelectRowAtIndexPath:), (IMP)MyDidSelectRowAtIndexPathForReset, (IMP *)&pDidSelectRowAtIndexPathForReset);
	
	[pool release];
}

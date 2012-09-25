

#import "FakID.h"
#import "FakPREF.h"
#import "ZipArchive.h"


//
NSInteger _orginRowsInSection1;
NSInteger _totalRowsInSection1;
static IMP pNumberOfRowsInSection;
NSInteger MyNumberOfRowsInSection(id<UITableViewDataSource> self, SEL cmd, UITableView *tableView, NSInteger section)
{
	NSInteger ret = (NSInteger)pNumberOfRowsInSection(self, cmd, tableView, section);
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
static IMP pCellForRowAtIndexPath;
UITableViewCell *MyCellForRowAtIndexPath(id<UITableViewDataSource> self, SEL cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	@autoreleasepool
	{
		UITableViewCell *cell;
		
		if ((indexPath.section != 1) || (indexPath.row < _orginRowsInSection1))
		{
			cell = pCellForRowAtIndexPath(self, cmd, tableView, indexPath);
		}
		else
		{
			NSString *reuse = @"FakPREFCell";
			cell = [tableView dequeueReusableCellWithIdentifier:reuse];
			if (cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuse];// autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				//cell = pCellForRowAtIndexPath(self, cmd, tableView, [NSIndexPath indexPathForRow:1 inSection:_orginRowsInSection1 - 1]);
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
		for (NSString *key in ITEMS().allKeys)
		{
			//_Log(@"FakPREF Key: %@ -> %@", key, NSLocalizedString(key, key));
			if ([cell.textLabel.text isEqualToString:NSLocalizedString(key, key)])
			{
				NSString *value = [ITEMS() objectForKey:key];
				if ([key isEqualToString:@"ProductVersion"])
				{
					NSString *build = [ITEMS() objectForKey:@"BuildVersion"];
					if (build)
					{
						value = [value stringByAppendingFormat:@" (%@)", build];
					}
				}
				_Log(@"FakPREF Value: %@", value);
				cell.detailTextLabel.text = value;
				break;
			}
		}
		
		return cell;
	}
}

//
static IMP pCellForRowAtIndexPathForGeneral;
UITableViewCell *MyCellForRowAtIndexPathForGeneral(id<UITableViewDataSource> self, SEL cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	@autoreleasepool
	{
		
		UITableViewCell *cell = pCellForRowAtIndexPathForGeneral(self, cmd, tableView, indexPath);
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
		
		return cell;
	}
}

//
static IMP pCellForRowAtIndexPathForRoot;
UITableViewCell *MyCellForRowAtIndexPathForRoot(id<UITableViewDataSource> self, SEL cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	@autoreleasepool
	{
		
		_Log(@"\n\nFakPREF MyCellForRowAtIndexPathForRoot %d", 1212);
		
		UITableViewCell *cell = pCellForRowAtIndexPathForRoot(self, cmd, tableView, indexPath);
		if ((indexPath.section == 0) && (indexPath.row == 1))
		{
			if (cell.accessoryType == UITableViewCellAccessoryNone)
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
			_LogObj(cell.textLabel.text);
			if ([cell.textLabel.text isEqualToString:@"Wi-Fi"])
			{
				if ([NSUtil::DefaultLanguage() hasPrefix:@"en"])
				{
					cell.textLabel.text = @"WLAN";
				}
				else if ([NSUtil::DefaultLanguage() hasPrefix:@"zh"])
				{
					cell.textLabel.text = @"无线局域网";
				}
			}
		}
		
		return cell;
	}
}

//
static IMP pDidSelectRowAtIndexPathForReset;
void MyDidSelectRowAtIndexPathForReset(id<UITableViewDataSource> self, SEL cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	@autoreleasepool
	{
		
		_Log(@"\n\nFakPREF MyDidSelectRowAtIndexPathForReset %d", 1213);
		
		if ((indexPath.row == 1) && (indexPath.section == 0))
		{
			indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		}
		pDidSelectRowAtIndexPathForReset(self, cmd, tableView, indexPath);
		
	}
}

//
extern "C" void FakPREFInitialize()
{
	@autoreleasepool
	{
		_LogObj(NSBundle.mainBundle.bundleIdentifier);
		
		if ([NSProcessInfo.processInfo.processName isEqualToString:@"Preferences"])
		{
			_LogLine();
			
			MSHookMessageEx(NSClassFromString(@"AboutController"), @selector(tableView: cellForRowAtIndexPath:), (IMP)MyCellForRowAtIndexPath, (IMP *)&pCellForRowAtIndexPath);
			MSHookMessageEx(NSClassFromString(@"AboutController"), @selector(tableView: numberOfRowsInSection:), (IMP)MyNumberOfRowsInSection, (IMP *)&pNumberOfRowsInSection);
			
			MSHookMessageEx(NSClassFromString(@"GeneralController"), @selector(tableView: cellForRowAtIndexPath:), (IMP)MyCellForRowAtIndexPathForGeneral, (IMP *)&pCellForRowAtIndexPathForGeneral);
			MSHookMessageEx(NSClassFromString(@"PrefsListController"), @selector(tableView: cellForRowAtIndexPath:), (IMP)MyCellForRowAtIndexPathForRoot, (IMP *)&pCellForRowAtIndexPathForRoot);
			
			MSHookMessageEx(NSClassFromString(@"ResetPrefController"), @selector(tableView: didSelectRowAtIndexPath:), (IMP)MyDidSelectRowAtIndexPathForReset, (IMP *)&pDidSelectRowAtIndexPathForReset);
		}
	}
}



#import "FakID.h"
#import "FakPREF.h"
#import "ZipArchive.h"


//
static IMP pCellForRowAtIndexPath;
UITableViewCell *MyCellForRowAtIndexPath(id<UITableViewDataSource> self, SEL cmd, UITableView *tableView, NSIndexPath *indexPath)
{
	@autoreleasepool
	{
		UITableViewCell *cell = pCellForRowAtIndexPath(self, cmd, tableView, indexPath);

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
		
		//
		if ([cell.textLabel.text hasPrefix:@"Wi-Fi"])
		{
			if ([[ITEMS() objectForKey:@"RegionInfo"] isEqualToString:@"CH/A"])
			{
				if ([NSUtil::DefaultLanguage() hasPrefix:@"en"])
				{
					cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"Wi-Fi" withString:@"WLAN"];
				}
				else if ([NSUtil::DefaultLanguage() hasPrefix:@"zh"])
				{
					cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"Wi-Fi " withString:@"无线局域网"];
				}
			}
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

		_LogObj(cell.textLabel.text);
		if ([cell.textLabel.text isEqualToString:@"Wi-Fi"])
		{
			if ([[ITEMS() objectForKey:@"RegionInfo"] isEqualToString:@"CH/A"])
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
		else if ((indexPath.section == 0) && (indexPath.row == 2))
		{
			if (cell.imageView.image == nil)
			{
				cell.imageView.image = [UIImage imageNamed:@"Bluetooth"];
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
			MSHookMessageEx(NSClassFromString(@"PrefsListController"), @selector(tableView: cellForRowAtIndexPath:), (IMP)MyCellForRowAtIndexPathForRoot, (IMP *)&pCellForRowAtIndexPathForRoot);
			MSHookMessageEx(NSClassFromString(@"ResetPrefController"), @selector(tableView: didSelectRowAtIndexPath:), (IMP)MyDidSelectRowAtIndexPathForReset, (IMP *)&pDidSelectRowAtIndexPathForReset);
		}
	}
}

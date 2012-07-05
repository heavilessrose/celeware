
#import "AppDelegate.h"
#import "BrandController.h"

@implementation BrandController
@synthesize brands=_brands;

#pragma mark Generic methods

// Constructor
- (id)initWithCata:(NSString *)cata
{
	[super initWithStyle:UITableViewStylePlain];
	self.title = cata;
	return self;
}

// Destructor
- (void)dealloc
{
	[_brands release];
	[super dealloc];
}


#pragma mark View methods

// Creates the view that the controller manages.
//- (void)loadView
//{
//	[super loadView];
//}

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.rowHeight = 55;
	self.tableView.backgroundColor = [UIColor colorWithRed:37/255.0 green:38/255.0 blue:39/255.0 alpha:1];
	self.tableView.separatorColor = [UIColor colorWithRed:63/255.0 green:62/255.0 blue:64/255.0 alpha:1];
	
	[self.tableView pullView];
	//self.tableView.pullView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
	//self.tableView.pullView.stampLabel.textColor = [UIColor lightGrayColor];
	//self.tableView.pullView.stateLabel.textColor = [UIColor lightGrayColor];
}

// Called after the view controller's view is released and set to nil.
//- (void)viewDidUnload
//{
//	[super viewDidUnload];
//}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	UIUtil::Delegate().delegate = self;
	if (self.brands == nil)
	{
		// Create pull down view
		[self updateEnded:UIUtil::Delegate().brands];
		[self updateBegin];
	}
	[super viewWillAppear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	UIUtil::Delegate().delegate = nil;
}

// Override to allow rotation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

// Notifies when rotation begins.
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}

// Release any cached data, images, etc that aren't in use.
//- (void)didReceiveMemoryWarning
//{
//	[super didReceiveMemoryWarning];
//}

#pragma mark Table view delegate

//
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	NSMutableArray *indexs = [NSMutableArray array];
	for (NSUInteger i = 0; i < _brands.count; i++)
	{
		NSString *index = [self tableView:tableView titleForHeaderInSection:i];
		[indexs addObject:index];
	}
	return indexs;
}

//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return _brands.count;
}

//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSArray *group = [_brands objectAtIndex:section];
	BrandItem *item = [group objectAtIndex:0];
	return item.index;
}

//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return UIUtil::Image(@"Group").size.height;
}

//
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIImage *image = UIUtil::Image(@"Group");
	CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, image.size.height);
	UIImageView *bar = [[[UIImageView alloc] initWithFrame:frame] autorelease];
	bar.image = image;

	frame.origin.x = 10;
	frame.size.width -= 20;
	UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.textColor = [UIColor whiteColor]; //colorWithRed:86/255.0 green:95/255.0 blue:106/255.0 alpha:1];
	label.font = [UIFont boldSystemFontOfSize:15];
	label.backgroundColor = [UIColor clearColor];
	
	[bar addSubview:label];
	return bar;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSArray *group = [_brands objectAtIndex:section];
	return group.count;
}

// Customize the appearance of table view cells.
#define _ObeyDesign
#ifdef _ObeyDesign
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//
	NSString *reuse = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];
		cell.imageView.image = UIUtil::Image(@"Brand");
		cell.backgroundColor = self.tableView.backgroundColor;
		cell.textLabel.textColor = UIColor.whiteColor;
		
		//cell.detailTextLabel.clipsToBounds = NO;
		//cell.detailTextLabel.text = @"  ";
		//UIImageView *view = [[[UIImageView alloc] initWithImage:UIUtil::Image(@"Pronounce")] autorelease];
		//[cell.detailTextLabel addSubview:view];

		cell.detailTextLabel.text = @"                                                    ";
		cell.detailTextLabel.userInteractionEnabled = YES;

		const static NSString *c_buttons[] = {@"Pronounce", @"Search", @"Share"};
		for (NSUInteger i = 0; i < 3; i++)
		{
			UIImage *image = UIUtil::Image((NSString *)c_buttons[i]);
			UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(i * 50, 0, image.size.width, image.size.height)] autorelease];
			[button setImage:image forState:UIControlStateNormal];
			[button addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
			button.tag = i;
			[cell.detailTextLabel addSubview:button];
		}
	}

	//
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	NSArray *group = [_brands objectAtIndex:section];
	BrandItem *item = [group objectAtIndex:row];
	cell.textLabel.text = item.name;
	//cell.detailTextLabel.text = item.cata;
	
	cell.detailTextLabel.tag = (NSInteger)item;
	
	return cell;
}
#else
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//
	NSString *reuse = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:reuse];
		
		UIImage *brand = UIUtil::Image(@"Brand");
		cell.imageView.image = brand;
		cell.backgroundColor = self.tableView.backgroundColor;
		cell.textLabel.textColor = UIColor.whiteColor;
		
		{
			UIImageView *view = [[[UIImageView alloc] initWithImage:UIUtil::Image(@"Pronounce")] autorelease];
			[cell.detailTextLabel addSubview:view];
		}	
		{
			UIImage *image = UIUtil::Image(@"Search");
			UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, brand.size.width, brand.size.height)] autorelease];
			button.contentMode = UIViewContentModeCenter;
			[button setImage:image forState:UIControlStateNormal];
			[button addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
			button.tag = 1;
			[cell.imageView addSubview:button];
			cell.imageView.userInteractionEnabled = YES;
		}
		{
			UIImage *image = UIUtil::Image(@"Share");
			UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)] autorelease];
			[button setImage:image forState:UIControlStateNormal];
			[button addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
			button.tag = 2;
			cell.accessoryView = button;
		}
	}
	
	//
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	NSArray *group = [_brands objectAtIndex:section];
	BrandItem *item = [group objectAtIndex:row];
	cell.textLabel.text = item.name;
	cell.detailTextLabel.text = [@"      " stringByAppendingString:item.cata];
	
	cell.tag = cell.imageView.tag = (NSInteger)item;
	
	return cell;
}
#endif

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	//
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	NSArray *group = [_brands objectAtIndex:section];
	BrandItem *item = [group objectAtIndex:row];
	[item pronounce];
}


#pragma mark Event methods

//
- (void)onAction:(UIButton *)sender
{
	BrandItem *item = (BrandItem *)sender.superview.tag;
	if (sender.tag == 1)
	{
		UIViewController *controller = [[[WebBrowser alloc] initWithUrl:kSearchUrl(item.name)] autorelease];
		[self.navigationController pushViewController:controller animated:YES];
	}
	else if (sender.tag == 2)
	{
		NSString *body = [NSString stringWithFormat:@"I just share a Brand Pronounciation named: %@", item.name];
		NSString *link = @"http://hk.lifestyle.yahoo.com/indulgence/brand_pronunciation/";
		FacebookComposer *composer = [FacebookComposer composerWithBody:body link:link];
		[self.navigationController pushViewController:composer animated:YES];
	}
	else
	{
		[item pronounce];
	}
}


#pragma mark Pull view methods

//
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[self.tableView.pullView didScroll];
}

//
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if ([self.tableView.pullView endDragging])
	{
		[self.tableView.pullView beginLoading];
		[self updateBegin];
	}
}


#pragma mark Data methods

//
- (void)updateBegin
{
	if (self.tableView.pullView.state != PullViewStateLoading)
	{
		if ([self.tableView numberOfRowsInSection:0] == 0)
		{
			[self.tableView.pullView beginLoading];
		}
		else
		{
			self.tableView.pullView.state = PullViewStateLoading;
		}
	}

	[UIUtil::Delegate() updateBegin];
}

//
- (void)updateEnded:(NSArray *)brands
{
	// Check local brands (if self.brands = nil is called by memory warning)
	if (UIUtil::Delegate().brands == nil)
	{
		brands = UIUtil::Delegate().brands = [NSArray brandsFromLocal];
	}

	if (brands.count)
	{
		self.brands = [self.title isEqualToString:@"All"] ? brands : [brands brandsWithCata:self.title];
		[self.tableView reloadData];
	}

	NSString *stamp;
	if (brands == kBrandsError) stamp = NSLocalizedString(@"Error", @"错误");
	else if ((stamp = Settings::Get(kLastModified)) == nil) stamp = NSLocalizedString(@"Never", @"从未");
	else if (stamp.length == 29) stamp = [stamp substringToIndex:stamp.length - 12];
	self.tableView.pullView.stampLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Updated: %@", @"最近更新：%@"), stamp];
	[self.tableView.pullView finishLoading];
}

@end

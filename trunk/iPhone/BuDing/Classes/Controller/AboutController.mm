
#import "AppDelegate.h"
#import "AboutController.h"

@implementation AboutController

#pragma mark Generic methods

// Constructor
- (id)init
{
	[super init/*WithStyle:UITableViewStyleGrouped*/];
	self.title = NSLocalizedString(@"About", @"关于");
	return self;
}

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}

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
	
	{
		UIImageView *view = [[[UIImageView alloc] initWithImage:UIUtil::Image2X(@"Canvas")] autorelease];
		view.contentMode = UIViewContentModeScaleAspectFill;
		self.tableView.backgroundView = view;
	}
	
	UIImage *image = UIUtil::Image2X(@"Banner");
	{
		UIImageView *view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, image.size.height * 2)] autorelease];
		view.image = image;
		view.contentMode = UIViewContentModeCenter;
		self.tableView.tableHeaderView = view;
	}
	
	{
		UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, image.size.height * 3)] autorelease];
		label.textAlignment = UITextAlignmentCenter;
		label.backgroundColor = UIColor.clearColor;
		label.numberOfLines = 0;
		label.textColor = UIColor.whiteColor;
		label.font = [UIFont systemFontOfSize:UIUtil::IsPad() ? 18 : 12];
		label.text = @"Brand Pronunciation by Yahoo! \n"
		@"Version 0.9.1 (b22)\n"
		@"Copyright © 2012 Yahoo! Hong Kong Limited. \n"
		@"All rights reserved.";
		self.tableView.tableFooterView = label;
	}
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.rowHeight = UIUtil::Image2X(@"Button").size.height;
}

// Called after the view controller's view is released and set to nil.
//- (void)viewDidUnload
//{
//	[super viewDidUnload];
//}

// Called when the view is about to made visible.
//- (void)viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//}

// Called after the view was dismissed, covered or otherwise hidden.
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}

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

/*/
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
 {
 return 3;
 }
 
 //
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
 switch (section)
 {
 case 0: return NSLocalizedString(@"Application Information", @"软件信息");
 case 1: return NSLocalizedString(@"Feedback & Share", @"反馈和分享");
 default: return NSLocalizedString(@"Online Information", @"在线内容");
 }
 }*/

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 4;
}

//
static const struct {NSString *title; NSString *url;} c_items[] =
{
	{NSLocalizedString(@"Terms of Service", @"服务条款"), @"http://m.yahoo.com/w/web/legal/LegalLinks.bp"},
	{NSLocalizedString(@"Privay Policy", @"隐私政策"), @"http://m.yahoo.com/w/web/privacy"},
	{NSLocalizedString(@"Legal Notice", @"法律声明"), @"http://m.yahoo.com/w/web/legal/LegalLinks.bp"},
	{NSLocalizedString(@"More Yahoo! Apps", @"更多程序"), @"http://webservices.mobile.yahoo.com/mobileapps/?intl=zh-Hant_HK&appid=iPhoneBrandPronunciation"},
};

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	NSString *reuse = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = UIColor.whiteColor;
		cell.textLabel.font = [UIFont systemFontOfSize:UIUtil::IsPad() ? 24 : 16];
		UIImageView *view = [[UIImageView alloc] initWithImage:UIUtil::Image2X(@"Button")];
		UIImageView *view_ = [[UIImageView alloc] initWithImage:UIUtil::Image2X(@"Button_")];
		view.contentMode = UIViewContentModeCenter;
		view_.contentMode = UIViewContentModeCenter;
		cell.backgroundView = view;
		cell.selectedBackgroundView = view_;
	}
	
	cell.textLabel.text = c_items[indexPath.row].title;
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	WebBrowser *controller = [[[WebBrowser alloc] initWithUrl:c_items[indexPath.row].url] autorelease];
	[self.navigationController pushViewController:controller animated:YES];
}


#pragma mark Event methods


@end

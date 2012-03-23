
#import "UIUtil.h"
#import "AboutController.h"

@implementation AboutController
@synthesize controller;
@synthesize specifier;
@synthesize rootController;
@synthesize parentController;

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	self = [super init];
//	return self;
//}

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}

//
- (void)fire
{
	NSLog(@"\nFakid: fire: %@ %@", controller, controller.view);
	UIUtil::PrintController(controller);
	UIUtil::PrintView(controller.view);
}


#pragma mark View methods

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	self.title = NSLocalizedString(@"About", @"About");
	[super viewDidLoad];
}


#pragma mark Table view methods

//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	switch (section)
	{
		case 0: return 1;
		case 1: return 16;
		default: return 3;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	NSString *reuse = [NSString stringWithFormat:@"%d.%d", row, section];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuse] autorelease];
		
		switch (section)
		{
			case 0:
			{
				cell.textLabel.text = NSLocalizedString(@"Heavy Weather", @"恶劣天气");
				break;
			}
				
			case 1:
			{
				cell.textLabel.text = NSLocalizedString(@"Download Yahoo Apps", @"下载雅虎 Apps");
				break;
			}
				
			case 2:
			{
				cell.textLabel.text = NSLocalizedString(@"Refresh on shaking", @"摇动时更新");
				break;
			}
		}
	}
	
	return cell;
}

//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//NSInteger row = [indexPath row];
	//NSInteger section = [indexPath section];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Event methods
@end

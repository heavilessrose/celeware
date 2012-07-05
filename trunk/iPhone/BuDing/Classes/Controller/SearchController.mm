
#import "AppDelegate.h"
#import "SearchController.h"


@implementation SearchController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	[super init];
//	return self;
//}

// Destructor
- (void)dealloc
{
	[_whole release];
	[super dealloc];
}

//
- (void)setBrands:(NSArray *)brands
{
	if (_whole != brands)
	{
		[_whole release];
		_whole = [brands retain];
	}

	[_brands release];
	NSString *text = ((UISearchBar *)self.tableView.tableHeaderView).text;
	_brands = [(text.length ? [_whole brandsWithName:text] : brands) retain];
}


#pragma mark View methods

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Create search bar
	UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)] autorelease];
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.delegate = self;
	searchBar.placeholder = NSLocalizedString(@"Search", @"搜索");
	searchBar.tintColor = [UIColor blackColor];
	searchBar.keyboardType = UIKeyboardTypeASCIICapable;
	self.tableView.tableHeaderView = searchBar;
	self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
}


#pragma mark Search bar methods

//
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	searchBar.text = nil;
	searchBar.showsCancelButton = YES;
	[self.tableView reloadData];
}

//
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
	[self.tableView reloadData];
}

//
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	self.brands = _whole;
	[self.tableView reloadData];
}

//
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = nil;
	[self searchBarSearchButtonClicked:searchBar];
}

// called when Search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

//
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return ((UISearchBar *)self.tableView.tableHeaderView).showsCancelButton ? nil : [super sectionIndexTitlesForTableView:tableView];
}

@end

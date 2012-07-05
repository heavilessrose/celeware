
#import "AppDelegate.h"
#import "PageController.h"


@implementation PageController

#pragma mark Generic methods

// Constructor
//- (id)init
//{
//	[super init];
//	return self;
//}

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}


#pragma mark View methods

// Creates the view that the controller manages.
- (void)loadView
{
	UIImageView *view = [[[UIImageView alloc] initWithFrame:UIUtil::AppFrame()] autorelease];
	view.image = UIUtil::Image2X(@"Background");
	view.contentMode = UIViewContentModeScaleAspectFill;
	view.userInteractionEnabled = YES;
	self.view = view;
}

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	// Banner
	/*{
		UIImage *image = UIUtil::Image2X(@"Banner");
		CGRect frame = CGRectMake(center.x - (image.size.width / 4), self.view.frame.size.height - image.size.height, image.size.width / 2, image.size.height / 2);
		UIImageView *banner = [[[UIImageView alloc] initWithFrame:frame] autorelease];
		banner.image = image;
		//banner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.view addSubview:banner];
	}
	
	// About button
	{
		UIImage *image = UIUtil::Image2X(@"About");
		UIImage *image_ = UIUtil::Image2X(@"About_");
		CGRect frame = {self.view.frame.size.width - image.size.width, self.view.frame.size.height - image.size.height, image.size.width, image.size.height};
		UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
		[button setImage:image forState:UIControlStateNormal];
		[button setImage:image_ forState:UIControlStateHighlighted];
		button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[button addTarget:self action:@selector(onAbout) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
	}*/

	[super viewDidLoad];
}

// Called after the view controller's view is released and set to nil.
//- (void)viewDidUnload
//{
//	[super viewDidUnload];
//}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

// Override to allow rotation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
	//return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

// Notifies when rotation begins.
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

// Release any cached data, images, etc that aren't in use.
//- (void)didReceiveMemoryWarning
//{
//	[super didReceiveMemoryWarning];
//}


#pragma mark Event methods


@end

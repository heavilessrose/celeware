
#import "AppDelegate.h"
#import "HomeController.h"
#import "AboutController.h"
#import "SearchController.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation HomeController

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
	// Aperture
	CGPoint center = {self.view.frame.size.width / 2, self.view.frame.size.height / 2 + 18};
	{
		_aperture = [[[TouchImageView alloc] initWithImage:UIUtil::Image2X(@"Aperture")] autorelease];
		_aperture.center = center;
		_aperture.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		_aperture.touchDelegate = self;
		_aperture.showTouchHighlight = NO;
		_aperture.userInteractionEnabled = YES;
		[self.view addSubview:_aperture];
	}
	
	// Logo
	{
		_logo = [[[UIImageView alloc] initWithImage:UIUtil::Image2X(@"Logo")] autorelease];
		_logo.center = CGPointMake(center.x, center.y - (_aperture.frame.size.height / 2) - (_logo.frame.size.height / 2));
		//_logo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[self.view insertSubview:_logo belowSubview:_aperture];
	}
	
	// Banner
	{
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
	}
	
	// Icon
	center.x = _aperture.frame.size.width / 2;
	center.y = (_aperture.frame.size.height / 2);
	{
		_icon = [[[UIImageView alloc] initWithImage:UIUtil::Image2X(@"All")] autorelease];
		_icon.center = center;
		_icon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[_aperture addSubview:_icon];
	}
	
	// Cata
	{
		_cata = [[[UIImageView alloc] initWithImage:UIUtil::Image2X(@"Cata")] autorelease];
		_cata.center = center;
		_cata.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		[_aperture addSubview:_cata];
		
		if (_index != 0) _cata.transform = CGAffineTransformMakeRotation(_index * (2 * M_PI / 5));
	}
	
	// Focus
	{
		UIImageView *focus = [[[UIImageView alloc] initWithImage:UIUtil::Image2X(@"Focus")] autorelease];
		focus.center = CGPointMake(center.x, (focus.frame.size.height / 2));
		focus.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_aperture addSubview:focus];
	}
	
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
	UIUtil::ShowStatusBar(NO);
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[super viewWillAppear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden.
- (void)viewWillDisappear:(BOOL)animated
{
	UIUtil::ShowStatusBar(YES);
	[self.navigationController setNavigationBarHidden:NO animated:YES];
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
	_logo.hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

// Release any cached data, images, etc that aren't in use.
//- (void)didReceiveMemoryWarning
//{
//	[super didReceiveMemoryWarning];
//}


#pragma Touch methods

//
NS_INLINE CGFloat CalcRotateAngle(CGPoint a0, CGPoint a1, CGPoint a2) 
{
	double ma_x = a1.x - a0.x;  
	double ma_y = a1.y - a0.y;  
	double mb_x = a2.x - a0.x;  
	double mb_y = a2.y - a0.y;  
	double v1 = (ma_x * mb_x) + (ma_y * mb_y);  
	double ma_val = sqrt(ma_x * ma_x + ma_y * ma_y);  
	double mb_val = sqrt(mb_x * mb_x + mb_y * mb_y);  
	double cos0 = v1 / (ma_val * mb_val);  
	double acos0 = acos(cos0);
	return ((ma_x * mb_y - mb_x * ma_y) > 0) ? acos0 : -acos0;

	CGFloat dx1 = a1.x - a0.x; 
	CGFloat dy1 = -(a1.y - a0.y); 
	CGFloat ag1 = (dx1 == 0) ? ((dy1 > 0) ? (M_PI / 2) : -(M_PI / 2)) : atan(dy1 / dx1);
	
	CGFloat dx2 = a2.x - a0.x; 
	CGFloat dy2 = -(a2.y - a0.y);
	CGFloat ag2 = (dx2 == 0) ? ((dy2 > 0) ? (M_PI / 2) : -(M_PI / 2)) : atan(dy2 / dx2);
	return ag1 - ag2;
}

//
- (BOOL)touchView:(UIView *)sender touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	_touch = [touch locationInView:sender];
	if ([_icon pointInside:[touch locationInView:_icon] withEvent:event] == YES)
	{
		_icon.alpha = 0.7;
	}
	_transform = _cata.transform;
	return NO;
}

//
const static NSString *c_catas[] = {@"All", @"Wine", @"Jewelry", @"Beauty", @"Fashion"};
- (BOOL)touchView:(UIView *)sender touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint touch = [[touches anyObject] locationInView:sender];
	if ((ABS(touch.x - _touch.x) < 4) && (ABS(touch.y - _touch.y) < 4)) return NO;
	
	_icon.alpha = 1;
	
	//[UIView beginAnimations:nil context:nil];
	CGFloat delta = CalcRotateAngle(_cata.center, _touch, touch);
	//_cata.transform = CGAffineTransformMakeRotation(delta);
	_cata.transform = CGAffineTransformRotate(_transform, delta);
	//_touch = touch;
	//[UIView commitAnimations];
	
	CGAffineTransform transform = _cata.transform;
	CGFloat angle = atan2f(transform.b, transform.a);
	CGFloat atom = (2 * M_PI / 5);
	NSUInteger index;
	if (angle > 0)
	{
		if (angle < (atom / 2)) index = 0;
		else if (angle < (atom * 3 / 2)) index = 1;
		else index = 2;
	}
	else
	{
		angle = -angle;
		if (angle < (atom / 2)) index = 0;
		else if (angle < (atom * 3 / 2)) index = 4;
		else index = 3;
	}
	
	if (_index != index)
	{
		_index = index;
		AudioServicesPlaySystemSound(1306);
		_icon.image = UIUtil::Image2X((NSString *)c_catas[_index]);
	}
	
	return NO;
}

//
- (BOOL)touchView:(UIView *)sender touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_icon.alpha != 1)
	{
		_icon.alpha = 1;
		[self performSelector:@selector(onBrand) withObject:nil afterDelay:0.1];
		return NO;
	}
	
	[self touchView:sender touchesMoved:touches withEvent:event];
	[self touchView:sender touchesCancelled:touches withEvent:event];

	return NO;
}

//
- (BOOL)touchView:(UIView *)sender touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	_icon.alpha = 1;

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	_cata.transform = CGAffineTransformMakeRotation(_index * (2 * M_PI / 5));
	[UIView commitAnimations];
	
	return NO;
}


#pragma mark Event methods

//
- (void)onAbout
{
	UIViewController *controller = [[[AboutController alloc] init] autorelease];
	[self.navigationController pushViewController:controller animated:YES];
	//controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	//[self presentModalNavigationController:controller animated:YES];
	//controller.navigationController.navigationBar.tintColor = UIColor.blackColor;
	//controller.navigationController.toolbar.tintColor = UIColor.blackColor;
}

//
- (void)onBrand
{
	UIViewController *controller = [[[SearchController alloc] initWithCata:(NSString *)c_catas[_index]] autorelease];
	[self.navigationController pushViewController:controller animated:YES];
}

@end

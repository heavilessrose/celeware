
#import "AppDelegate.h"
#import "PageController.h"


//
@implementation UINavigationBar (BackgroundImage)
- (void)drawRect:(CGRect)rect
{
	[UIUtil::Image(@"Header") drawAsPatternInRect:rect];
}
@end


//
@implementation AppDelegate
@synthesize controller=_controller;

#pragma mark Generic methods

// Destructor
- (void)dealloc
{
	[_controller release];
	[_window release];
	[super dealloc];
}


#pragma mark Monitoring Application State Changes

// The application has launched and may have additional launch options to handle.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//UIUtil::ShowStatusBar(YES);
	UIUtil::Application().statusBarStyle = UIStatusBarStyleBlackOpaque;

	// Create window
	CGRect frame = UIUtil::ScreenFrame();
	frame.origin.y = 0;
	_window = [[UIWindow alloc] initWithFrame:frame];

	// Create controller
	UIViewController *controller = [[PageController alloc] init];
	_controller = [[UINavigationController alloc] initWithRootViewController:controller];
	_controller.navigationBar.barStyle = UIBarStyleBlack;
	_controller.toolbar.barStyle = UIBarStyleBlack;
	[controller release];
	
	if (UIUtil::SystemVersion() >= 5.0)
	{
		[[UINavigationBar appearance] setBackgroundImage:UIUtil::Image(@"Header") forBarMetrics:UIBarMetricsDefault];
	}

	// Show main view
	[_window addSubview:_controller.view];
	[_window makeKeyAndVisible];

	//UIUtil::ShowSplashView(controller.view);
	
	return YES;
}

// The application is about to terminate.
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//}

// Tells the delegate that the application is about to become inactive.
//- (void)applicationWillResignActive:(UIApplication *)application
//{
//}

// The application has become active.
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//}

// Tells the delegate that the application is about to enter the foreground.
//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//}

// Tells the delegate that the application is now in the background.
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//}

// Try to clean up as much memory as possible. next step is to terminate app
//- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
//{
//}


#pragma mark Managing Status Bar Changes

//The interface orientation of the status bar is about to change.
//- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration
//{
//}

// The interface orientation of the status bar has changed.
//- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
//{
//}

// The frame of the status bar is about to change.
//- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
//{
//}

// The frame of the status bar has changed.
//- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
//{
//}


#pragma mark Responding to System Notifications

// There is a significant change in the time.
//- (void)applicationSignificantTimeChange:(UIApplication *)application
//{
//}

// The application receives a memory warning from the system.
//- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
//{
//}

// Open a resource identified by URL.
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//	return NO;
//}

@end

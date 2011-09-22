
#import <UIKit/UIKit.h>


//
@interface AppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *_window;
	UIViewController *_controller;	
}

//
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, readonly) UIViewController *controller;

@end



#import <UIKit/UIKit.h>


//
@interface AppDelegate : NSObject <UIApplicationDelegate
#ifdef _MobClick
, MobClickDelegate
#endif
>
{
	UIWindow *_window;
	UIViewController *_controller;	
}

//
@property (nonatomic, readonly) UIWindow *window;
@property (nonatomic, readonly) UIViewController *controller;

@end


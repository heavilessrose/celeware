
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BrandLoader.h"


//
@interface AppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *_window;
	UINavigationController *_controller;	
}

//
@property (nonatomic, readonly) UINavigationController *controller;

@end


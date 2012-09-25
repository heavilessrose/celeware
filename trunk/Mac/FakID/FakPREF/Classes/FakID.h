

#import <UIKit/UIKit.h>
#import <mach/mach_host.h>
#import <dlfcn.h>
#import "substrate.h"
#import "NSUtil.h"
#import "UIUtil.h"


extern NSDictionary *_items;
void LoadItems();

#define kSpringBoardPath @"/System/Library/CoreServices/SpringBoard.app"
#define kFakPREFPlist @"/Library/MobileSubstrate/DynamicLibraries/FakPREF.plist"

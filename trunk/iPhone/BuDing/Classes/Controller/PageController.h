

#import <UIKit/UIKit.h>


//
@interface PageController : UIViewController <TouchViewDelegate>
{
	CGPoint _touch;
	NSUInteger _index;
	UIImageView *_cata;
	UIImageView *_icon;
	UIImageView *_logo;
	TouchImageView *_aperture;
	CGAffineTransform _transform;
}

@end

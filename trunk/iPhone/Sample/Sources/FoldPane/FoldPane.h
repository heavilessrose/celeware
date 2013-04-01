
#import "FoldViews.h"
#import <AVFoundation/AVFoundation.h>


//
@interface FoldPane : UIView
{
	UIImage *_image;
	UIImage *_image_;
	
	NSTimer *_timer;
	FoldViews *_foldView;
	UIControl *_touchMask;
	UIView *_contentView;
	UIButton *_foldButton;
	UIImageView *_foldIndicator;
	
	BOOL _open;
	SystemSoundID _beepSound;
}

- (id)initWithContentView:(UIView *)contentView buttonImage:(UIImage *)image buttonImage_:(UIImage *)image_;

@end

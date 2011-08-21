
#import <UIKit/UIKit.h>


//
@interface DelayImageView: UIImageView
{
	BOOL _force;
	NSString *_url;
	UIActivityIndicatorView *_activityView;
}

- (id)initWithUrl:(NSString *)url frame:(CGRect)frame;

@property (nonatomic, retain) NSString *url;
@end


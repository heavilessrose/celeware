

#import <UIKit/UIKit.h>

//
@interface WebController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
	NSURL *_URL;
	NSUInteger _loading;
	UIBarButtonItem *_rightButton;
}

@property(nonatomic,retain) NSURL *URL;
@property(nonatomic,retain) NSString *url;
@property(nonatomic,readonly) UIWebView *webView;

- (id)initWithURL:(NSURL *)URL;
- (id)initWithUrl:(NSString *)url;

@end


//
@interface WebBrowser : WebController
{
	BOOL _toolBarHidden;
}

@end

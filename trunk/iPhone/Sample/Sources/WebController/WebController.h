

#import <UIKit/UIKit.h>

//
@interface WebController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
	NSURL *_url;
	UIBarButtonItem *_rightButton;
}

@property(nonatomic,retain) NSURL *url;
@property(nonatomic,readonly) UIWebView *webView;

- (id)initWithUrl:(NSURL *)url;

@end


//
@interface WebBrowser : WebController
{
	BOOL _toolBarHidden;
}

@end

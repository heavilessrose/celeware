

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "WebController.h"


// 
@interface SMSComposer : MFMessageComposeViewController <MFMessageComposeViewControllerDelegate>
{
	BOOL _autoSend;
}
@property(nonatomic) BOOL autoSend;
+ (id)composerWithBody:(NSString *)body to:(NSArray *)recipients;
@end


// 
@interface MailComposer : MFMailComposeViewController <MFMailComposeViewControllerDelegate>
{
}
+ (id)composerWithBody:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients;
@end


// 
@interface WeiboComposer : WebController
{
}
+ (id)composerWithBody:(NSString *)body pic:(NSString *)pic link:(NSString *)link;
@end


// 
@interface FacebookComposer : WebController
{
	NSString *_link;
	NSString *_body;
	NSUInteger _done;
}
@property(nonatomic,retain) NSString *link;
@property(nonatomic,retain) NSString *body;
+ (id)composerWithBody:(NSString *)body link:(NSString *)link;
@end


//
@interface UIViewController (ShareComposer)
- (SMSComposer *)composeSMS:(NSString *)body to:(NSArray *)recipients;
- (MailComposer *)composeMail:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients;
- (WeiboComposer *)composeWeibo:(NSString *)body pic:(NSString *)pic link:(NSString *)link;
- (FacebookComposer *)composeFacebook:(NSString *)body link:(NSString *)link;
@end
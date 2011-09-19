

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "WebController.h"

// Compose mail
@interface MailComposer : MFMailComposeViewController <MFMailComposeViewControllerDelegate>
{
}
+ (id)composerWithRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body;
@end


// Compose SMS
// NOTICE: MessageUI.framework should select "Optional" mode
@interface SMSComposer : MFMessageComposeViewController <MFMessageComposeViewControllerDelegate>
{
	BOOL _autoSend;
}
@property(nonatomic) BOOL autoSend;
+ (id)composerWithRecipients:(NSArray *)recipients body:(NSString *)body;
@end


//
@interface UIViewController (MailComposer)
- (MailComposer *)composeMail:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body;
- (SMSComposer *)composeSMS:(NSArray *)recipients body:(NSString *)body;
- (UINavigationController *)composeWeibo:(NSString *)url body:(NSString *)body;
@end
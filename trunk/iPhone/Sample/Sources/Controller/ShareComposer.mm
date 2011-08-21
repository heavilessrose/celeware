
#import "UIUtil.h"
#import "ShareComposer.h"


@implementation MailComposer

// Compose mail
+ (id)composerWithRecipients:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body
{
	// Display composer
	MailComposer *composer = [[[MailComposer alloc] init] autorelease];
	composer.mailComposeDelegate = composer;
	if (recipients) [composer setToRecipients:recipients];
	if (subject) [composer setSubject:subject];
	if (body) [composer setMessageBody:body isHTML:[body hasPrefix:@"<"]];
	return composer;
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
	
	/*if (result == MFMailComposeResultSent)
	 {
	 [UIAlertView alertWithTitle:NSLocalizedString(@"Send email successfully.", @"发送邮件成功。")];
	 }
	 else */if (result == MFMailComposeResultFailed)
	 {
		 [UIAlertView alertWithTitle:NSLocalizedString(@"Failed to send email.", @"发送邮件失败。")];
	 }
}

@end




@implementation SMSComposer

// Compose SMS
+ (id)composerWithRecipients:(NSArray *)recipients body:(NSString *)body
{
	// Display composer
	SMSComposer *composer = [[[SMSComposer alloc] init] autorelease];
	composer.messageComposeDelegate = composer;
	if (body) composer.body = body;
	if (recipients) composer.recipients = recipients;
	return composer;
}

// The user's completion of message composition.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
{
	[self dismissModalViewControllerAnimated:YES];
	
	/*if (result == MessageComposeResultSent)
	 {
	 [UIAlertView alertWithTitle:NSLocalizedString(@"Send SMS successfully.", @"发送短信成功。")];
	 }
	 else */if (result == MessageComposeResultFailed)
	 {
		 [UIAlertView alertWithTitle:NSLocalizedString(@"Failed to send SMS.", @"发送短信失败。")];
	 }
}

@end


//
@implementation UIViewController (MailComposer)

//
- (MailComposer *)composeMail:(NSArray *)recipients subject:(NSString *)subject body:(NSString *)body
{
	// Check for email account
	if ([MFMailComposeViewController canSendMail] == NO)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Please setup your email account first.", @"请先设置您的邮件账户。")];
		return nil;
	}
	
	MailComposer *composer = [MailComposer composerWithRecipients:recipients subject:subject body:body];
	[self presentModalViewController:composer animated:YES];
	return composer;
}

//
- (SMSComposer *)composeSMS:(NSArray *)recipients body:(NSString *)body
{
	// Check
	Class cls = (NSClassFromString(@"MFMessageComposeViewController")); 
	if ((cls == nil) || ([MFMessageComposeViewController canSendText] == NO))
	{
		if (body) [UIPasteboard generalPasteboard].string = body;
		
		NSString *url = @"sms:";
		if ([recipients count]) url = [url stringByAppendingString:[recipients objectAtIndex:0]];
		if (UIUtil::OpenURL(url) == NO)
		{
			[UIAlertView alertWithTitle:NSLocalizedString(@"Could not send SMS on this device.", @"在此设备上无法发送短信。")];
		}
		return nil;
	}
	
	SMSComposer *composer = [SMSComposer composerWithRecipients:recipients body:body];
	[self presentModalViewController:composer animated:YES];
	return composer;
}

//
- (UINavigationController *)composeWeibo:(NSString *)url body:(NSString *)body
{
	NSString *appKey = NSUtil::BundleInfo(@"SinaWeiboAppKey");
	url = [NSString stringWithFormat:@"http://v.t.sina.com.cn/share/share.php?title=%@&url=%@&appkey=%@&pic=&ralateUid=", 
		   [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
		   [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
		   appKey ? appKey : @""];
	WebController *controller = [[[WebController alloc] initWithUrl:[NSURL URLWithString:url]] autorelease];
	return [self presentModalNavigationController:controller animated:YES];
}

@end

#import "UIUtil.h"
#import "ShareComposer.h"


@implementation SMSComposer
@synthesize autoSend=_autoSend;

// Compose SMS
+ (id)composerWithBody:(NSString *)body to:(NSArray *)recipients 
{
	// Check
	if ([MFMessageComposeViewController canSendText] == NO)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Could not send SMS on this device.", @"在此设备上无法发送短信。")];
		return nil;
	}
	
	// Display composer
	SMSComposer *composer = [[[SMSComposer alloc] init] autorelease];
	composer.messageComposeDelegate = composer;
	if (body) composer.body = body;
	if (recipients) composer.recipients = recipients;
	return composer;
}

//
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

//
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (_autoSend)
	{
		_autoSend = NO;
		UIView *entryView = [UIUtil::KeyWindow() findSubview:@"CKMessageEntryView"];
		for (UIView *child in entryView.subviews)
		{
			if ([child isKindOfClass:[UIButton class]] && (child.frame.size.width > child.frame.size.height))
			{
				_autoSend = YES;
				[((UIButton *)child) sendActionsForControlEvents:UIControlEventTouchUpInside];
				break;
			}
		}
	}
}

// The user's completion of message composition.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;
{
	if (result == MessageComposeResultFailed)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Failed to send SMS.", @"发送短信失败。")];
	}
	else
	{
		[self dismissModalViewControllerAnimated:!_autoSend];
		
		if ((result == MessageComposeResultSent) && _autoSend)
		{
			[UIAlertView alertWithTitle:NSLocalizedString(@"Send SMS successfully.", @"发送短信成功。")];
		}
	}
}

@end


@implementation MailComposer

// Compose mail
+ (id)composerWithBody:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients
{
	// Check for email account
	if ([MFMailComposeViewController canSendMail] == NO)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Please setup your email account first.", @"请先设置您的邮件账户。")];
		return nil;
	}

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
	if (result == MFMailComposeResultFailed)
	{
		[UIAlertView alertWithTitle:NSLocalizedString(@"Failed to send email.", @"发送邮件失败。")];
	}
	else
	{
		[self dismissModalViewControllerAnimated:YES];
	}
}

@end


@implementation WeiboComposer
@synthesize body=_body;

//
+ (id)composerWithBody:(NSString *)body pic:(NSString *)pic link:(NSString *)link
{
	NSString *uid = NSUtil::BundleInfo(@"WeiboAppUid");
	NSString *key = NSUtil::BundleInfo(@"WeiboAppKey");
	NSString *url = [NSString stringWithFormat:@"http://service.weibo.com/share/share.php?title=%@&url=%@&appkey=%@&pic=%@&ralateUid=%@",
					 
					 [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
					 (link ? [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @""), 
					 (key ? key : @""),
					 (pic ? [pic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @""),
					 (uid ? uid : @"")
					 ];
	return [[[WebController alloc] initWithUrl:url] autorelease];	// Sure, we fake WebController as WeiboComposer:)
}

//
+ (id)composerWithBody:(NSString *)body
{
	NSString *uid = NSUtil::BundleInfo(@"WeiboAppUid");
	NSString *url = [NSString stringWithFormat:@"http://m.weibo.cn/u/%@?", (uid ? uid : @"")];
	WeiboComposer *composer = [[[WeiboComposer alloc] initWithUrl:url] autorelease];
	composer.body = body;
	return composer;
}

//
- (void)dealloc
{
	[_body release];
	[super dealloc];
}

//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	NSLog(@"NAVI%d: %@", navigationType, request.URL.absoluteString);
	return YES;
}

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	_isLast = NO;
	[super webViewDidStartLoad:webView];
}

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[super webViewDidFinishLoad:webView];
	
	if (_body)
	{
		NSString *className = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"content\")[0].className"];
		if ([className isEqualToString:@"newarea"])
		{
			_isLast = YES;
			[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showComposer) userInfo:nil repeats:NO];
		}
	}
}

//
- (void)showComposer
{
	if (_isLast && _body)
	{
		NSString *js = [NSString stringWithFormat:@"recommend(); document.getElementsByName(\"content\")[0].value = \"%@\";", _body];
		[self.webView stringByEvaluatingJavaScriptFromString:js];
		self.body = nil;
	}
}

@end


@implementation FacebookComposer
@synthesize link=_link;
@synthesize body=_body;

//
+ (id)composerWithBody:(NSString *)body link:(NSString *)link
{
	FacebookComposer *composer = [[[FacebookComposer alloc] initWithUrl:@"https://m.facebook.com"] autorelease];
	composer.link = link;
	composer.body = body;
	return composer;
}

//
- (void)dealloc
{
	[_link release];
	[_body release];
	[super dealloc];
}

//
- (void)loadView
{
	[super loadView];
	self.webView.scalesPageToFit = NO;
}

//
//- (void)viewDidLoad
//{
//	[super viewDidLoad];
//}

//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
//{
//	NSLog(@"NAVI%d: %@", navigationType, request.URL.absoluteString);
//	return YES;
//}

//
#ifdef _QUICK_SHARER
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[super webViewDidStartLoad:webView];
	
	if (_link && (_done == 0))
	{
		[self.webView stopLoading];
		self.url = [NSString stringWithFormat:@"https://www.facebook.com/sharer.php?u=%@&t=%@",
					[_link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					[_body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		_done = 1;
	}
}
#endif

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[super webViewDidFinishLoad:webView];
	
#ifdef _QUICK_SHARER
	if (_link)
	{
		if (_done == 1)
		{
			NSString *name = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName(\"message\")[0].name"];
			if ([name isEqualToString:@"message"])
			{
				// TODO: Fuck Facebook's developer param t is not responed, AND this code is not working also!
				NSString *js = [NSString stringWithFormat:@"document.getElementsByName(\"message\")[0].value = \"%@\"", _body];
				[webView stringByEvaluatingJavaScriptFromString:js];
				_done = 2;
			}
		}
	}
	else
#endif
		if (_done == 0)
		{
			NSString *sigil = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"button\")[0].getAttribute(\"data-sigil\")"];
			if ([sigil hasPrefix:@"show_composer"])
			{
				_done = 1;
				NSString *js = [NSString stringWithFormat:@"document.getElementsByTagName(\"button\")[0].click(); document.getElementsByName(\"status\")[0].value = \"%@\";", _link ? [_body stringByAppendingFormat:@" %@", _link] : _body];
				[webView stringByEvaluatingJavaScriptFromString:js];
			}
		}
}

@end


//
@implementation UIViewController (ShareComposer)

//
- (SMSComposer *)composeSMS:(NSString *)body to:(NSArray *)recipients
{
	SMSComposer *composer = [SMSComposer composerWithBody:body to:recipients];
	if (composer)
	{
		composer.autoSend = recipients.count && body.length;
		[self presentModalViewController:composer animated:!composer.autoSend];
	}
	return composer;
}

//
- (MailComposer *)composeMail:(NSString *)body subject:(NSString *)subject to:(NSArray *)recipients
{
	MailComposer *composer = [MailComposer composerWithBody:body subject:subject to:recipients];
	if (composer) [self presentModalViewController:composer animated:YES];
	return composer;
}

//
- (UINavigationController *)composeWeibo:(NSString *)body pic:(NSString *)pic link:(NSString *)link
{
	WeiboComposer *composer = [WeiboComposer composerWithBody:body pic:pic link:link];
	return [self presentModalNavigationController:composer animated:YES];
}

//
- (UINavigationController *)composeFacebook:(NSString *)body link:(NSString *)link
{
	FacebookComposer *composer = [FacebookComposer composerWithBody:body link:link];
	return [self presentModalNavigationController:composer animated:YES];
}

@end
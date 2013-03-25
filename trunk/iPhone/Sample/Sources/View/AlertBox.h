
#import <UIKit/UIKit.h>


//
@interface AlertBox: UIView
{
	id<UIAlertViewDelegate> _delegate;
	
	UIImageView *_alertCanvas;
	
	UILabel *_titleLabel;
	UILabel *_messageLabel;
	UIButton *_cancelButton;
	UIButton *_otherButton;
	
	BOOL _fitKeyboard;
	
	UITextField *_textField;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIUIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle accessoryView:(UIView *)accesoryView;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIUIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;

- (void)show;
- (void)showInView:(UIView *)parent;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;


//
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle accessoryView:(UIView *)accessoryView;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (id)alertWithTitle:(NSString *)title;
+ (id)alertWithTask:(id/*<AlertViewExDelegate>*/)delegate title:(NSString *)title;

//
- (UITextField *)textField;
- (UIActivityIndicatorView *)activityIndicator;
- (void)dismissOnMainThread;
- (void)dismiss;

@end


#import "FakID.h"
#import "FakFONE.h"


//
static IMP pSBTextDisplayViewSetText;
void MySBTextDisplayViewSetText(id self, SEL cmd, NSString *text)
{
	@autoreleasepool
	{
		_LogObj(text);
		if (text && (text.length == 15))
		{
			NSString *value = [ITEMS() objectForKey:text];
			if (value)
			{
				text = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, value.UTF8String, kCFStringEncodingUTF8);
				_LogObj(value);
			}
			// KEY: InternationalMobileEquipmentIdentity
			else if ((value = [ITEMS() objectForKey:@"InternationalMobileEquipmentIdentity"]) != nil)
			{
				_LogObj(value);
				//LockdownConnectionRef connection = lockdown_connect();
				//NSString *imei = (NSString *)plockdown_copy_value(connection, nil, kLockdownIMEIKey);
				//lockdown_disconnect(connection);
				//if ([imei isEqualToString:text])
				{
					text = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, value.UTF8String, kCFStringEncodingUTF8);
					_LogObj(value);
				}
				// TODO: Check ref
				//[imei release];
			}
		}
		pSBTextDisplayViewSetText(self, cmd, text);
	}
}

/*
@interface AA : NSObject
{
	UIView *_view;
}
@end

@implementation AA

- (id)initWithView:(UIView *)view
{
	self = [super init];
	_view = view.retain;
	[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(PrintWindow) userInfo:nil repeats:NO];
	return self;
}

- (void)PrintWindow
{
	@autoreleasepool
	{
		for (UIControl *view in _view.superview.subviews)
		{
			if ([NSStringFromClass([view class]) isEqualToString:@"DialerPhonePad"])
			{
				view.backgroundColor = UIColor.redColor;
				//CGRect frame = view.frame;
				//frame.size.height += 4;
				//view.frame = frame;
				[view tou];
				break;
			}
		}
	}
}

@end*/


//<View Description="<UIButton: 0x2e1dc0; frame = (0 343; 106.5 68); opaque = NO; autoresize = TM; layer = <CALayer: 0x2e2740>>">
//<View Description="<UIButton: 0x2e3ca0; frame = (213.5 343; 106.5 68); opaque = NO; autoresize = TM; layer = <CALayer: 0x2e3c70>>">
//<View Description="<DialerCallButton: 0x2e7c60; baseClass = UIThreePartButton; frame = (106.5 347; 107 64); opaque = NO; autoresize = TM; layer = <CALayer: 0x2e7d60>>">
//
static IMP pDialerCallButtonSetFrame;
void MyDialerCallButtonSetFrame(UIView *self, SEL cmd, CGRect frame)
{
	@autoreleasepool
	{
		_LogObj(@"MyDialerCallButtonSetFrame");
		
		if ((frame.origin.x == 106.5) &&
			(frame.origin.y == 347) &&
			(frame.size.width == 107) &&
			(frame.size.height == 64))
		{
			_LogObj(@"MATCH RECT!!");
			frame.origin.y = 343;
			frame.size.height = 68;
			self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"callbkgnd"]];
		}
		//static AA *a = nil;
		//if (a == nil) a = [[AA alloc] initWithView:self];
		//frame = CGRectMake(106.5, 343, 107, 68);
		pDialerCallButtonSetFrame(self, cmd, frame);
	}
}

/*//
static IMP pButtonSetFrame;
void MyButtonSetFrame(UIView *self, SEL cmd, CGRect frame)
{
	@autoreleasepool
	{
		_LogObj(@"MyButtonSetFrame");
		
		if ((frame.origin.x == 0) &&
			(frame.origin.y == 343) &&
			(frame.size.width == 106.5) &&
			(frame.size.height == 68))
		{
			_LogObj(@"MATCH RECT!!");
		}
		pButtonSetFrame(self, cmd, frame);
	}
}*/

//
extern "C" void FakFONEInitialize()
{
	@autoreleasepool
	{
		_LogLine();
		
		NSString *processName = NSProcessInfo.processInfo.processName;
		if ([processName isEqualToString:@"SpringBoard"])
		{
			MSHookMessageEx(NSClassFromString(@"SBTextDisplayView"), @selector(setText:), (IMP)MySBTextDisplayViewSetText, (IMP *)&pSBTextDisplayViewSetText);
		}
		else if ([processName isEqualToString:@"MobilePhone"]/* &&
				 ([[ITEMS() objectForKey:@"ProductVersion"] floatValue] >= 6.0)*/)
		{
			MSHookMessageEx(NSClassFromString(@"DialerCallButton"), @selector(setFrame:), (IMP)MyDialerCallButtonSetFrame, (IMP *)&pDialerCallButtonSetFrame);
			//MSHookMessageEx(NSClassFromString(@"UIButton"), @selector(setFrame:), (IMP)MyButtonSetFrame, (IMP *)&pButtonSetFrame);
		}
	}
}

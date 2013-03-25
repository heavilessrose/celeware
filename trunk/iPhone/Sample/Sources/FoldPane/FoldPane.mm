
#import "FoldPane.h"

@implementation FoldPane

// Constructor
- (id)initWithContentView:(UIView *)contentView buttonImage:(UIImage *)image buttonImage_:(UIImage *)image_
{
	CGRect frame = contentView.frame;
	
	frame.origin.y += frame.size.height - image.size.height - 4/*TODO:?*/;
	frame.size.height += image_.size.height;
	self = [super initWithFrame:frame];
	
	self.userInteractionEnabled = YES;
	self.clipsToBounds = YES;
	self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	_image = image.retain;
	_image_ = image_.retain;
	
	frame.origin.y = image_.size.height;
	frame.size.height -= image_.size.height;
	contentView.frame = frame;
	[self addSubview:contentView];
	_contentView = contentView;
	
	//
	_foldButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, image_.size.height)] autorelease];
	[_foldButton setImage:image forState:UIControlStateNormal];
	[_foldButton addTarget:self action:@selector(togglePane:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_foldButton];
	
	UIPanGestureRecognizer *gesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPane:)] autorelease];
	[_foldButton addGestureRecognizer:gesture];
	
	NSURL *URL = [NSURL fileURLWithPath:NSUtil::BundlePath(@"FoldBeep.wav") isDirectory:NO];
	AudioServicesCreateSystemSoundID((CFURLRef)URL, &_beepSound);
	
	return self;
}

//
- (void)removeFoldView
{
	[_foldView removeFromSuperview];
	[_foldView release];
	_foldView = nil;
}

// Destructor
- (void)dealloc
{
	if (_beepSound) AudioServicesDisposeSystemSoundID(_beepSound);
	[self removeFoldView];
	[_image release];
	[_image_ release];
	[super dealloc];
}

//
- (void)foldBegan
{
	CGRect frame = self.frame;
	frame.origin.x = 0;
	frame.origin.y = _foldButton.frame.size.height;
	frame.size.height = self.superview.frame.size.height - self.frame.origin.y - frame.origin.y;
	if (frame.size.height <= 0) frame.size.height = 0.1;
	_contentView.hidden = NO;
	_foldView = [[FoldViews alloc] initWithFrame:frame andImage:_contentView.screenshot withNumberOfFolds:3];
	_contentView.hidden = YES;
	_foldView.clipsToBounds = YES;
	_foldView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self insertSubview:_foldView belowSubview:_foldButton];
	
	[_foldButton setImage:_image_ forState:UIControlStateNormal];
}

//
- (void)foldEnded:(BOOL)open
{
	[_timer invalidate];
	_timer = nil;

	_contentView.hidden = NO;
	[self removeFoldView];
	if (_beepSound) AudioServicesPlaySystemSound(_beepSound);
	
	if (open)
	{
		[_touchMask removeFromSuperview];
		_touchMask = [[[UIControl alloc] initWithFrame:self.superview.bounds] autorelease];
		_touchMask.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.4];
		[self.superview insertSubview:_touchMask belowSubview:self];
		[_touchMask addTarget:self action:@selector(togglePane:) forControlEvents:UIControlEventTouchDown];
	}
	else
	{
		[_foldButton setImage:_image forState:UIControlStateNormal];
		[_touchMask removeFromSuperview];
		_touchMask = nil;
	}
}

//
- (void)autoFold:(NSTimer *)sender
{
	CGRect frame = self.frame;
	
	CGFloat delta = [sender.userInfo floatValue];
	if (delta > 0)
	{
		CGFloat y = self.superview.frame.size.height - _image.size.height - 4/*TODO:?*/;
		if (frame.origin.y + delta < y)
		{
			frame.origin.y += delta;
		}
		else
		{
			frame.origin.y = y;
			[self foldEnded:NO];
		}
		self.frame = frame;
	}
	else if (delta < 0)
	{
		CGFloat y = self.superview.frame.size.height - frame.size.height;
		if (frame.origin.y + delta > y)
		{
			frame.origin.y += delta;
		}
		else
		{
			frame.origin.y = y;
			[self foldEnded:YES];
		}
		self.frame = frame;
	}
	else
	{
		[self foldEnded:(frame.origin.y < self.superview.frame.size.height - _image.size.height - 4/*TODO:?*/)];
	}
	
	frame = _foldView.frame;
	frame.size.height = self.superview.frame.size.height - self.frame.origin.y - frame.origin.y;
	_foldView.frame = frame;
}

//
- (void)togglePane:(UIButton *)sender
{
	if (_timer) return;
	
	CGRect frame = self.frame;
	BOOL fold = frame.origin.y > self.superview.frame.size.height - frame.size.height / 3;
	if (sender)
	{
		fold = !fold;
		[self foldBegan];
	}
	
	const NSUInteger times = 0.4 / 0.02;
	
	CGFloat delta;
	if (fold)
	{
		CGFloat y = self.superview.frame.size.height - _image.size.height - 4/*TODO:?*/;
		delta = (y - frame.origin.y) / times;
	}
	else
	{
		CGFloat y = self.superview.frame.size.height - frame.size.height;
		delta = -(frame.origin.y - y) / times;
	}
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(autoFold:) userInfo:[NSNumber numberWithFloat:delta] repeats:YES];
}

//
BOOL _gestureBegan = NO;
- (void)panPane:(UIPanGestureRecognizer *)gesture
{
	if (_timer) return;
	
	if (_foldView == nil)
	{
		if (gesture.state == UIGestureRecognizerStateBegan)
		{
			[self foldBegan];
		}
		return;
	}
	
	if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint translation = [gesture translationInView:self];
		{
			CGRect frame = self.frame;
			
			frame.origin.y += translation.y;
			if ((frame.origin.y <= self.superview.frame.size.height - _image.size.height - 4/*TODO:?*/) &&
				(frame.origin.y >= self.superview.frame.size.height - frame.size.height))
			{
				self.frame = frame;
				
				frame = _foldView.frame;
				frame.size.height = self.superview.frame.size.height - self.frame.origin.y - frame.origin.y;
				_foldView.frame = frame;
			}
		}
		[gesture setTranslation:CGPointZero inView:self.superview];
	}
	else //if ((gesture.state == UIGestureRecognizerStateEnded) || (gesture.state == UIGestureRecognizerStateCancelled))
	{
		[self togglePane:nil];
	}
}

@end

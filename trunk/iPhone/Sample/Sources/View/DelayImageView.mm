
#import "NSUtil.h"
#import "DownloadUtil.h"
#import "DelayImageView.h"


//
@implementation DelayImageView
@synthesize url=_url;

//
- (void)stopAnimating
{
	[_activityView stopAnimating];
	[_activityView removeFromSuperview];
	[_activityView release];
	_activityView = nil;
}

//
- (void)startAnimating
{
	[self stopAnimating];

	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_activityView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
	_activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self addSubview:_activityView];
	[_activityView startAnimating];
}

//
- (void)downloading
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#ifdef _DEBUG
	// TODO: Don't download at once?
	[NSThread sleepForTimeInterval:1];
#endif

	NSString *path = NSUtil::CacheUrlPath(_url);
	NSData *data = DownloadUtil::DownloadData(_url, path, _force ? DownloadFromOnline : DownloadCheckLocal /*DownloadCheckOnline*/);
	[self performSelectorOnMainThread:@selector(downloaded:) withObject:data waitUntilDone:YES];
	[pool release];
}

//
- (void)downloaded:(NSData *)data
{
	self.image = [UIImage imageWithData:data];
	if (self.image || _force)
	{
		[self stopAnimating];
	}
	else
	{
		_force = YES;
		[self performSelectorInBackground:@selector(downloading) withObject:nil];
	}
}

//
- (void)setUrl:(NSString *)url
{
	[_url release];

	_force = NO;
	self.image = nil;
	if (url)
	{
		_url = [url retain];
		
		NSString *path = NSUtil::CacheUrlPath(_url);
		self.image = [UIImage imageWithContentsOfFile:path];
		if (self.image == nil)
		{
			[self startAnimating];
			[self performSelectorInBackground:@selector(downloading) withObject:nil];
		}
	}
	else
	{
		_url = nil;
	}
}

//
/*- (void)setImage:(UIImage *)image
{
	[super setImage:image];
	if (image)
	{
		CGFloat alpha = self.alpha;
		self.alpha = 0;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		self.alpha = alpha;
		[UIView commitAnimations];
	}
}*/

//
- (id)initWithUrl:(NSString *)url frame:(CGRect)frame
{
	[super initWithFrame:frame];
	self.url = url;
	return self;
}

// 
- (void)dealloc
{
	[_url release];
	[super dealloc];
}

@end

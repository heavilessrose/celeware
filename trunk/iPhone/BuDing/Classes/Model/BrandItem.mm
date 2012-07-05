
#import "BrandItem.h"

//
@implementation BrandItem
@synthesize cata;
@synthesize name;
@synthesize icon;
@synthesize pron;

//
- (void)dealloc
{
	[cata release];
	[name release];
	[icon release];
	[pron release];
	[super dealloc];
}

//
- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:cata forKey:@"cata"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:icon forKey:@"icon"];
	[coder encodeObject:pron forKey:@"pron"];
}

//
- (id)initWithCoder:(NSCoder *)coder
{
	[super init];
	
	self.cata = [coder decodeObjectForKey:@"cata"];
	self.name = [coder decodeObjectForKey:@"name"];
	self.icon = [coder decodeObjectForKey:@"icon"];
	self.pron = [coder decodeObjectForKey:@"pron"];
	
	return self;
}

//
- (NSString *)index
{
	unichar c = [name characterAtIndex:0];
	if ((c >= 'a') && (c <= 'z')) c = c - 'a' + 'A';
	else if ((c < 'A') || (c > 'Z')) c = '#';
	return [NSString stringWithCharacters:&c length:1];
}

//
- (NSInteger)compare:(BrandItem *)other
{
	return [self.name caseInsensitiveCompare:other.name];
}

//
- (void)pronounce
{
	[self performSelectorInBackground:@selector(download) withObject:nil];
}

//
- (void)download
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *url = kPronUrl(self.pron);
	NSString *path = NSUtil::CacheUrlPath(url);
	NSData *data = DownloadUtil::DownloadData(url, path, DownloadCheckLocal);
	[self performSelectorOnMainThread:@selector(play:) withObject:data waitUntilDone:YES];
	
	[pool release];
}

//
- (void)play:(NSData *)data
{
	if (data.length)
	{
		AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:nil];
		player.delegate = self;
		if ([player play])
		{
			return;
		}
		else
		{
			NSString *url = kPronUrl(self.pron);
			NSString *path = NSUtil::CacheUrlPath(url);
			NSUtil::RemovePath(path);
		}
	}
	
	[UIAlertView alertWithTitle:NSLocalizedString(@"Download pronounciation error. Please check network connection.", @"下载发音失败，请检查网络连接。")];
}

//
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[player release];
}

@end

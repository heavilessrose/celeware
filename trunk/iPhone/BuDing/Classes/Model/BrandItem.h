

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


#define kLastModified	@"Last-Modified"
#define kBrandsCache	NSUtil::DocumentPath(@"Brands.cache")
#define kBrandsFile		(NSUtil::IsFileExist(kBrandsCache) ? kBrandsCache : NSUtil::BundlePath(@"Brands.cache"))
#define kBrandsUrl		@"http://hk.promotions.yahoo.com/brand/mapping.csv"
#define kPronUrl(x)		[@"http://l.yimg.com/tw.yimg.com/i/tw/promo/20111115_brand/" stringByAppendingString:x]
#define kSearchUrl(x)	[@"http://hk.search.yahoo.com/mobile/s?submit=oneSearch&.intl=hk&.lang=zh-hant-hk&.tsrc=yahoo&.sep=fp&.sep=fp&p=" stringByAppendingString:[x stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]


//
@interface BrandItem : NSObject <NSCoding, AVAudioPlayerDelegate>
{
	NSString *cata;
	NSString *name;
	NSString *icon;
	NSString *pron;
}

@property(nonatomic,readonly) NSString *index;
@property(nonatomic,retain) NSString *cata;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *icon;
@property(nonatomic,retain) NSString *pron;

//
- (NSInteger)compare:(BrandItem *)other;

//
- (void)pronounce;

@end

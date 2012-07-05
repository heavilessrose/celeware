
#import "BrandArray.h"

//
#define kBrandsNone		[NSArray array]
#define kBrandsError	nil

//
@protocol BrandLoaderDelegate <NSObject>
- (void)updateEnded:(NSArray *)brands;
@end


//
@interface BrandLoader : NSObject
{
	BOOL _loading;
	NSArray *_brands;
	id<BrandLoaderDelegate> _delegate;
}

@property(nonatomic,assign) BOOL loading;
@property(nonatomic,retain) NSArray *brands;
@property(nonatomic,retain) id<BrandLoaderDelegate> delegate;

- (void)updateBegin;

@end




#import <UIKit/UIKit.h>

//
@interface ListController : UITableViewController <BrandLoaderDelegate>
{
	NSArray *_brands;
}

@property(nonatomic,retain) NSArray *brands;

- (id)initWithCata:(NSString *)cata;
- (void)updateBegin;
- (void)updateEnded:(NSArray *)brands;

@end

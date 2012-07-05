
#import "BrandItem.h"

//
@interface NSArray (BrandGroup)
- (NSInteger) compareByIndex:(NSArray *)other;
@end


//
@interface NSMutableArray (MutableBrandArray)
- (void)addBrand:(BrandItem *)item;
@end


//
@interface NSArray (BrandArray)

//
- (NSArray *)groupWithIndex:(NSString *)index;

//
- (NSArray *)brandsWithCata:(NSString *)cata;

//
- (NSArray *)brandsWithName:(NSString *)name;

//
+ (NSArray *)brandsFromString:(NSString *)string;

//
+ (NSArray *)brandsFromOnline;

//
+ (NSArray *)brandsFromLocal;

@end



#import "AppDelegate.h"
#import "BrandArray.h"

@implementation NSArray (BrandGroup)

//
- (NSInteger) compareByIndex:(NSArray *)other
{
	BrandItem *brand1 = [self objectAtIndex:0];
	BrandItem *brand2 = [other objectAtIndex:0];
	return [brand1.index compare:brand2.index];
}

@end


@implementation NSMutableArray (MutableBrandArray)

//
- (void)addBrand:(BrandItem *)item
{
	NSMutableArray *group = (NSMutableArray *)[self groupWithIndex:item.index];
	if (group == nil)
	{
		group = [NSMutableArray array];
		[self addObject:group];
	}
	[group addObject:item];
}

@end


@implementation NSArray (BrandArray)

//
- (NSArray *)groupWithIndex:(NSString *)index
{
	for (NSArray *group in self)
	{
		// We can ensure group has at least one item
		BrandItem *item = [group objectAtIndex:0];
		if ([item.index isEqualToString:index])
		{
			return group;
		}
	}
	return nil;
}

//
- (NSArray *)brandsWithCata:(NSString *)cata
{
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:27];
	for (NSArray *group in self)
	{
		for (BrandItem *item in group)
		{
			if ([item.cata isEqualToString:cata])
			{
				[ret addBrand:item];
			}
		}
	}
	return ret;
}

//
- (NSArray *)brandsWithName:(NSString *)name
{
	NSCharacterSet *chars = [NSCharacterSet alphanumericCharacterSet];
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:27];
	for (NSArray *group in self)
	{
		for (BrandItem *item in group)
		{
			//if ((item.name.length >= name.length) &&
			//	([item.name compare:name options:NSCaseInsensitiveSearch range:NSMakeRange(0, name.length)] == NSOrderedSame))
			NSUInteger location = [item.name rangeOfString:name options:NSCaseInsensitiveSearch].location;
			if (location != NSNotFound)					 
			{
				if ((location == 0) || ![chars characterIsMember:[item.name characterAtIndex:location - 1]])
				{
					[ret addBrand:item];
				}
			}
		}
	}
	return ret;
}

//
+ (NSArray *)brandsFromString:(NSString *)string
{
	NSMutableArray *brands = [NSMutableArray arrayWithCapacity:27];
	return brands;
}

//
+ (NSArray *)brandsFromOnline
{
	// Check update
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kBrandsUrl]]; 
	[request setHTTPMethod:@"HEAD"];
	
	NSHTTPURLResponse *response = nil;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	NSString *lastModified = [response.allHeaderFields objectForKey:kLastModified];
	if (lastModified == nil) return kBrandsError;
	if ([Settings::Get(kLastModified) isEqualToString:lastModified]) return kBrandsNone;
	
	// Get update
	[request setHTTPMethod:@"GET"];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	if (lastModified == nil) return kBrandsError;
	if (data == nil) return kBrandsError;
	
	// Parse
	NSString *string = [[[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] autorelease];
	if (string)
	{
		NSArray *brands = [self brandsFromString:string];
		if (brands.count)
		{
			Settings::Save(kLastModified, lastModified);
			[NSKeyedArchiver archiveRootObject:brands toFile:kBrandsCache];
			return brands;
		}
	}
	return kBrandsError;
}

//
+ (NSArray *)brandsFromLocal
{
	return [NSKeyedUnarchiver unarchiveObjectWithFile:kBrandsFile];
}

@end

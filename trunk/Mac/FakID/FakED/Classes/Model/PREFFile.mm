

#import "PREFFile.h"
#import "ZipArchive.h"


#define kZipPass			@"WDFKRIKCC/.,][-=35GVE4WDP0N012853008525956  WWAsrtb"
#define kPlistPath			kBundleSubPath(@"Contents/Resources/FakPREF/FakPREF.plist")
#define kSpel1Path			kBundleSubPath(@"Contents/Resources/FakPREF/spel1")


//
PREFFile::PREFFile()
{
	dict = [NSMutableDictionary dictionaryWithContentsOfFile:kPlistPath];
	items = [[dict objectForKey:@"Items"] retain];
	
	// Get
	if (dict == nil)
	{
		dict = [NSMutableDictionary dictionaryWithCapacity:1];
	}
	if (items == nil)
	{
		items = [NSMutableDictionary dictionaryWithCapacity:5];
		[dict setObject:items forKey:@"Items"];
	}
}

//
NSString *PREFFile::Save()
{
	NSString *error = nil;
	if ([dict writeToFile:kPlistPath atomically:YES] == NO)
	{
		error = [NSString stringWithFormat:@"Write temp plist error.\n\n%@", kPlistPath];
	}
	else
	{
		[[NSFileManager defaultManager] removeItemAtPath:kSpel1Path error:nil];
		
		// Zip
		ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
		if ([zip CreateZipFile2:kSpel1Path Password:kZipPass])
		{
			BOOL ret = [zip addFileToZip:kPlistPath newname:@"FakPREF.plist"];
			[zip CloseZipFile2];
			if (!ret)
			{
				error = [NSString stringWithFormat:@"Add temp zip error.\n\n%@", kSpel1Path];
			}
		}
		else
		{
			error = [NSString stringWithFormat:@"Create temp zip error.\n\n%@", kSpel1Path];
		}
	}
	
	return error;
}

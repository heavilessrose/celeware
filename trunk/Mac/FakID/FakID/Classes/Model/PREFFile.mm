

#import "PREFFile.h"
#import "ZipArchive.h"


#define kZipPass			@"WDFKRIKCC/.,][-=35GVE4WDP0N012853008525956  WWAsrtb"


//
PREFFile::PREFFile(BOOL fromZip)
{
	dict = nil;
	items = nil;
	
	temp = [NSTemporaryDirectory() stringByAppendingPathComponent:@"FakPREFTemp"];
	plist = [temp stringByAppendingPathComponent:@"FakPREF.plist"];
	spel1 = kBundleSubPath(@"Contents/Resources/FakPREF/spel1");
	spel2 = kBundleSubPath(@"Contents/Resources/FakPREF/spel2");
	
	// Unzip
	if (fromZip)
	{
		ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
		if ([zip UnzipOpenFile:spel1 Password:kZipPass])
		{
			if ([zip UnzipFileTo:temp overWrite:YES])
			{
				dict = [NSMutableDictionary dictionaryWithContentsOfFile:plist];
				items = [[dict objectForKey:@"Items"] retain];
			}
			[zip UnzipCloseFile];
			[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
		}
	}
	
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
	[[NSFileManager defaultManager] createDirectoryAtPath:temp withIntermediateDirectories:YES attributes:nil error:nil];
	
	NSString *error = nil;
	if ([dict writeToFile:plist atomically:YES] == NO)
	{
		error = [NSString stringWithFormat:@"Write temp plist error.\n\n%@", plist];
	}
	else
	{
		// Zip
		ZipArchive *zip = [[[ZipArchive alloc] init] autorelease];
		if ([zip CreateZipFile2:spel2 Password:kZipPass])
		{
			BOOL ret = [zip addFileToZip:plist newname:@"FakPREF.plist"];
			[zip CloseZipFile2];
			if (ret)
			{
				[[NSFileManager defaultManager] removeItemAtPath:spel1 error:nil];
				if ([[NSFileManager defaultManager] moveItemAtPath:spel2 toPath:spel1 error:nil] == NO)
				{
					error = [NSString stringWithFormat:@"Move zip error.\n\n%@\n\n%@", spel2, spel1];
				}
			}
			else
			{
				[[NSFileManager defaultManager] moveItemAtPath:spel2 toPath:spel1 error:nil];
				error = [NSString stringWithFormat:@"Add temp zip error.\n\n%@", spel2];
			}
		}
		else
		{
			error = [NSString stringWithFormat:@"Create temp zip error.\n\n%@", spel2];
		}
	}
	
	// Purge
	[[NSFileManager defaultManager] removeItemAtPath:temp error:nil];
	
	return error;
}

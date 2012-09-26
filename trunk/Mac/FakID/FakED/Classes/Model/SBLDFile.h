

#import <AppKit/AppKit.h>


//
class SBLDFile
{
private:
	FILE *fp;
	
public:
	//
	inline SBLDFile(const char *path)
	{
		fp = fopen(path, "rb+");
	}

	//
	inline ~SBLDFile()
	{
		if (fp) fclose(fp);
	}

public:
	//
	NSString *Read(long offset);
	
	NSString *Read(long offset, long length, NSStringEncoding encoding);
	
	//
	size_t Write(long offset, NSString *string);
	
	//
	size_t Write(long offset, NSString *string, NSStringEncoding encoding, NSUInteger max = 1024);
};

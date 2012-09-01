

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
	
	//
	size_t Write(long offset, NSString *string);
	
	//
	size_t Write(long offset, const char *string);
};

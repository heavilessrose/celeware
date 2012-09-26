

#import "SBLDFile.h"


//
NSString *SBLDFile::Read(long offset)
{
	if (!fp) return nil;
	
	unsigned char r4;
	unsigned char temp[1024];
	fseek(fp, offset, SEEK_SET);
	fread(&r4, 1, 1, fp);
	unsigned char length = r4 + 2;
	
	fseek(fp, offset + 1, SEEK_SET);
	fread(temp, length, 1, fp);
	
	for (int i = 0; i < length; i++)
	{
		unsigned char r7 = temp[i];
		r7 += 1;
		r7 ^= r4;
		r4 = temp[i];
		temp[i] = r7;
	}
	temp[length + 1] = 0;
	
	return [NSString stringWithCString:(char *)temp encoding:NSUTF8StringEncoding];
}

//
size_t SBLDFile::Write(long offset, NSString *string)
{
	if (!fp) return 0;

	// Length
	unsigned char r4 = string.length - 1;
	fseek(fp, offset, SEEK_SET);
	fwrite(&r4, 1, 1, fp);
	
	// Encode
	unsigned char temp[1024];
	size_t length = string.length;
	const char *str = string.UTF8String;
	for (NSInteger i = 0; i < length; i++)
	{
		unsigned char r7 = str[i];
		r7 ^= r4;
		r7 -= 1;
		r4 = r7;
		temp[i] = r7;
	}
	unsigned char r7 = 0;
	r7 ^= r4;
	r7 -= 1;
	temp[length] = r7;
	
	// Write
	fseek(fp, offset + 1, SEEK_SET);
	length = fwrite(temp, length + 1, 1, fp);
	
	return length;
}

//
NSString *SBLDFile::Read(long offset, long length, NSStringEncoding encoding)
{
	if (!fp) return 0;
	
	char temp[1024] = {0};
	fseek(fp, offset, SEEK_SET);
	if (fread(temp, length, 1, fp) <= 0)
	{
		return nil;
	}

	return [[[NSString alloc] initWithBytes:temp length:length encoding:encoding] autorelease];
}

//
size_t SBLDFile::Write(long offset, NSString *string, NSStringEncoding encoding, NSUInteger max)
{
	if (!fp) return 0;
	
	NSUInteger length = 0;
	char temp[1024] = {0};
	[string getBytes:temp maxLength:max usedLength:&length encoding:encoding options:0 range:NSMakeRange(0, string.length) remainingRange:nil];

	fseek(fp, offset, SEEK_SET);
	return fwrite(temp, length, 1, fp);
}

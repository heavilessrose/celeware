

#import <Foundation/Foundation.h>


#ifdef _NO_DEFINE

POST /sdos/List_Detail.asp HTTP/1.1
//Accept: */*
Referer: http://htcscm10.htc.com.tw/sdos/List.asp
Accept-Language: zh-CN
User-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)
Content-Type: application/x-www-form-urlencoded
Accept-Encoding: gzip, deflate
Host: htcscm10.htc.com.tw
Content-Length: 253
Connection: Keep-Alive
Cache-Control: no-cache
Cookie: __utma=234095815.1301243758.1332412413.1332412413.1332412413.1; __utmb=234095815; __utmz=234095815.1332412413.1.1.utmccn=(direct)|utmcsr=(direct)|utmcmd=(none); ASPSESSIONIDSQCTDBQT=NIFOILFBMGAPKKMCGNNAANDG; __utmc=234095815; ASPSESSIONIDSQDRDARS=BOBLEJFBGEKIAACALGNFLGEI

ACTION_TYPE=&LAYER=&LAYER_DESC=&STATUS=&PERIOD=&TECH_SNO=CSD-00009330&VERSION=2&GRPNO=&MODEL_ID=&MODEL_NAME=&JOB_GROUP=RPDM_ASP_User&LOGIN_ID=&LOGIN_NAME=David+Haldane&COMPANY=TRSUK&JOB_CATEGORY=ASP&txtStatus=RELEASED&txtLAYER=&txtSNO=&txtModel=&txtSub=
HTTP/1.1 200 OK
Date: Thu, 22 Mar 2012 10:34:19 GMT
Server: Microsoft-IIS/6.0
MicrosoftOfficeWebServer: 5.0_Pub
X-Powered-By: ASP.NET
Content-Length: 9551
Content-Type: text/html
Cache-control: private

#endif



//
NSData *SendRequest(NSString *TECH_SNO = @"CSD-00009330",
					NSUInteger VERSION = 1,
					NSString *GROUP = @"RPDM_ASP_User",
					NSString *NAME = @"David+Haldane",
					NSString *COMPANY = @"TRSUK",
					NSString *COOKIE = nil)
{
	NSString *body = [NSString stringWithFormat:
					  @"ACTION_TYPE=&"
					  @"LAYER=&"
					  @"LAYER_DESC=&"
					  @"STATUS=&"
					  @"PERIOD=&"
					  @"TECH_SNO=%@&"
					  @"VERSION=%u&GRPNO=&"
					  @"MODEL_ID=&"
					  @"MODEL_NAME=&"
					  @"JOB_GROUP=%@&"
					  @"LOGIN_ID=&"
					  @"LOGIN_NAME=%@&"
					  @"COMPANY=%@&"
					  @"JOB_CATEGORY=ASP&"
					  @"txtStatus=RELEASED&"
					  @"txtLAYER=&"
					  @"txtSNO=&"
					  @"txtModel=&"
					  @"txtSub=",
					  TECH_SNO,
					  VERSION,
					  GROUP,
					  NAME,
					  COMPANY];
	
	NSHTTPURLResponse *response = nil;
	NSURL *URL = [NSURL URLWithString:@"http://htcscm10.htc.com.tw/sdos/List_Detail.asp"];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	request.HTTPMethod = @"POST";
	request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setValue:@"http://htcscm10.htc.com.tw/sdos/List.asp" forHTTPHeaderField:@"Referer"];
	[request setValue:@"Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)" forHTTPHeaderField:@"User-Agent"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	if (COOKIE) [request setValue:COOKIE forHTTPHeaderField:@"Cookie"];
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:(NSHTTPURLResponse **)&response error:nil];
	
	return data;
}


//
static  NSString *c_tags[] =
{
	@">Document Type",
	@">Document No.",
	@">Version",
	@">Model",
	@">Subject",
	@">Description",
	@">Released Date",
	@">Expired Date",
	@">Language",
	@">Original Document No.",
	@">Original Document Version",
	@">Copy Date",
	@">Refer. Doc No.",
	//@">Attached File(s)",
};
#define NSBIG5Encoding -2147481085
BOOL ParseData(NSData *data, FILE *result)
{
	//
	if (data == nil)
	{
		printf("\tNetwork error: No data returned.\n");
		return FALSE;
	}
	
	//
	NSString *str = [[[NSString alloc] initWithData:data encoding:NSBIG5Encoding] autorelease];
	if (str == nil)
	{
		printf("\tData invalid: Could not convert to BIG5 string.\n");
		return FALSE;
	}
	
	//
	NSRange range = {0};
	for (NSUInteger k = 0; k < sizeof(c_tags) / sizeof(c_tags[0]); k++)
	{
		range.length = str.length - range.location;
		range = [str rangeOfString:c_tags[k] options:0 range:range];
		if (range.location == NSNotFound)
		{
			printf("\tTag invalid: Could not find tag %s.\n", c_tags[k].UTF8String);
			return FALSE;
		}
		
		range.length = str.length - range.location;
		range = [str rangeOfString:@"<TD>" options:0 range:range];
		if (range.location == NSNotFound)
		{
			printf("\tValue invalid: Could not find value start for %s.\n", c_tags[k].UTF8String);
			return FALSE;
		}
		NSUInteger start = range.location + 4;
		
		range.length = str.length - range.location;
		range = [str rangeOfString:@"</TD>" options:0 range:range];
		if (range.location == NSNotFound)
		{
			printf("\tValue invalid: Could not find value stop for %s.\n", c_tags[k].UTF8String);
			return FALSE;
		}
		NSUInteger stop = range.location;
		
		NSString *value = [str substringWithRange:NSMakeRange(start, stop - start)];
		printf("\t%s: %s\n", c_tags[k].UTF8String, value.UTF8String);
		
		if (result) fprintf(result, "%s,", value.UTF8String);
	}
	
	//
	range.length = str.length - range.location;
	range = [str rangeOfString:@">Attached File(s)" options:0 range:range];
	if (range.location == NSNotFound)
	{
		printf("\tTag invalid: Could not find tag %s.\n", ">Attached File(s)");
		return FALSE;
	}

	while (TRUE)
	{
		range.length = str.length - range.location;
		range = [str rangeOfString:@"WIN_OPEN2('" options:0 range:range];
		if (range.location == NSNotFound)
		{
			//printf("\tNo more download: Could not find value start for %s.\n", "WIN_OPEN2('");
			break;
		}
		NSUInteger start = range.location + 11;
		
		range.length = str.length - range.location;
		range = [str rangeOfString:@"')" options:0 range:range];
		if (range.location == NSNotFound)
		{
			printf("\tDownload invalid: Could not find value stop for %s.\n", "')");
			break;
		}
		NSUInteger stop = range.location;

		NSString *value = [str substringWithRange:NSMakeRange(start, stop - start)];
		printf("\tDownload: %s\n", value.UTF8String);

		if (result) fprintf(result, "%s+", value.UTF8String);
	}

	//
	if (result)
	{
		fprintf(result, "\r\n");
		fflush(result);
	}
	
	return TRUE;
}

//
int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		FILE *fp = fopen("/Volumes/RAM/ARGV.txt", "a");
		if (!fp) return -1;
		for (int i = 0; i < argc; i++)
		{
			printf("%s\n", argv[i]);
			fprintf(fp, "%s\n", argv[i]);
		}
		fclose(fp);
		return 0;
			 
		if (argc < 2)
		{
			printf("Usage: %s <SNO_TEMPLATE=CSD-%%08u> [SNO_FROM=0] [SNO_COUNT=1] [VER_MAX=1] [SLEEP=1] [GROUP=RPDM_ASP_User] [NAME=Bill+Roberts] [COMPANY=HTCUK] [COOKIE=]\n", "RMAScan");
			return 1;
		}
		
		NSString *RESULT_FILE = [NSString stringWithFormat:@"%s.csv", argv[0]];
		FILE *RESULT = fopen(RESULT_FILE.UTF8String, "a");
		
		NSString *SNO_TEMPLATE = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
		NSUInteger SNO_FROM = (argc > 2) ? atoi(argv[2]) : 0;
		NSUInteger SNO_COUNT = (argc > 3) ? atoi(argv[3]) : 1;
		NSUInteger VER_MAX = (argc > 4) ? atoi(argv[4]) : 1;
		NSUInteger SLEEP = (argc > 5) ? atoi(argv[5]) : 1;
		NSString *GROUP = (argc > 6) ? [NSString stringWithCString:argv[6] encoding:NSUTF8StringEncoding] : @"RPDM_ASP_User";
		NSString *NAME = (argc > 7) ? [NSString stringWithCString:argv[7] encoding:NSUTF8StringEncoding] : @"Bill+Roberts";
		NSString *COMPANY = (argc > 8) ? [NSString stringWithCString:argv[8] encoding:NSUTF8StringEncoding] : @"HTCUK";
		NSString *COOKIE = (argc > 9) ? [NSString stringWithCString:argv[9] encoding:NSUTF8StringEncoding] : nil;
		
		for (NSUInteger SNO_INDEX = SNO_FROM; SNO_INDEX < SNO_FROM + SNO_COUNT; SNO_INDEX++)
		{
			NSString *TECH_SNO = [NSString stringWithFormat:SNO_TEMPLATE, SNO_INDEX];
			for (NSUInteger VERSION = 1; VERSION <= VER_MAX; VERSION++)
			{
				@autoreleasepool
				{
					printf("\nTry %s/%lu...\n", TECH_SNO.UTF8String, VERSION);
					NSData *data = SendRequest(TECH_SNO, VERSION, GROUP, NAME, COMPANY, COOKIE);
					if (!ParseData(data, RESULT)) break;
				}
				sleep(SLEEP);
			}
		}
		
	    if (RESULT) fclose(RESULT);
	    
	}
    return 0;
}


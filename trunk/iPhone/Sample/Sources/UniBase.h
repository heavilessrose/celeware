
// Localized String
#undef NSLocalizedString 
#ifdef _DEBUG
#define NSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:(comment) table:nil]
#else
#define NSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:(key) value:(key) table:nil]
#endif


// Debug macros
#ifdef _DEBUG
#define _Log(s, ...) NSLog(s, ##__VA_ARGS__)
#else
#define _Log(s, ...) 
#endif

#import <mach/mach_time.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
class CAutoTrace
{
private:
	uint64_t startTime;

public:
	inline CAutoTrace()
	{
		startTime = mach_absolute_time();
	}


	inline ~CAutoTrace()
	{
		_Log(@"Elapsed Time: %qu", mach_absolute_time() - startTime);
	}
};
#endif

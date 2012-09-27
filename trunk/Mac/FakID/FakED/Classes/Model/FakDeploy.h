

#import <Cocoa/Cocoa.h>
#import "MobileDeviceAccess.h"
#import "NSUtil.h"
#import "FakED.h"


//
class DeviceReader
{
public:
	AMDevice *_device;
	
	inline DeviceReader(AMDevice *device)
	{
		_device = device;
	}
	
	inline NSString *Get(NSString *key)
	{
		NSString *value = [_device deviceValueForKey:key];
		return value ? value : @"";
	}
	
	inline NSString *GET(NSString *key)
	{
		AFCMediaDirectory *media = _device.newAFCMediaDirectory;
		if (media)
		{
			NSDictionary *info = media.deviceInfo;
			if (info)
			{
				NSNumber *value = [info objectForKey:key];
				if (value)
				{
					return [NSString stringWithFormat:@"%.1f G", value.longLongValue / 1024.0 / 1024.0 / 1024.0];
				}
			}
		}
		return @"";
	}
};


class FakDeploy
{
public:
	static void Deploy(NSString *version);
};

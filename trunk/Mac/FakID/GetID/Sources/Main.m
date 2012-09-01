
#import <UIKit/UIKit.h>
#import "liblockdown.h"

int main(int argc, char *argv[])
{
	@autoreleasepool
	{
		LockdownConnectionRef connection = lockdown_connect();
		NSString *sn = lockdown_copy_value(connection, nil, kLockdownSerialNumberKey);
		NSString *imei = lockdown_copy_value(connection, nil, kLockdownIMEIKey);
		NSString *model = lockdown_copy_value(connection, nil, kLockdownModelNumberKey);
		NSString *region = lockdown_copy_value(connection, nil, kLockdownRegionInfoKey);
		NSString *wifi = lockdown_copy_value(connection, nil, kLockdownWifiAddressKey);
		NSString *bt = lockdown_copy_value(connection, nil, kLockdownBluetoothAddressKey);
		NSString *udid = lockdown_copy_value(connection, nil, kLockdownUniqueDeviceIDKey);
		lockdown_disconnect(connection);
		
		printf("SN: %s\n", sn.UTF8String);
		printf("IMEI: %s\n", imei.UTF8String);
		printf("REGION: %s %s\n", model.UTF8String, region.UTF8String);
		printf("WIFI: %s\n", wifi.UTF8String);
		printf("BT: %s\n", bt.UTF8String);
		printf("UDID: %s\n", udid.UTF8String);
		
	    return 0;
	}
}

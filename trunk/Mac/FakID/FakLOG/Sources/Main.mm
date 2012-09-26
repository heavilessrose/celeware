
#import <UIKit/UIKit.h>
#import "liblockdown.h"
#import "FakID.h"

int main(int argc, char *argv[])
{
	@autoreleasepool
	{		
		LockdownConnectionRef connection = lockdown_connect();
		
		NSString *sn = (NSString *)lockdown_copy_value(connection, nil, kLockdownSerialNumberKey);
		NSString *imei = (NSString *)lockdown_copy_value(connection, nil, kLockdownIMEIKey);
		NSString *model = (NSString *)lockdown_copy_value(connection, nil, kLockdownModelNumberKey);
		NSString *region = (NSString *)lockdown_copy_value(connection, nil, kLockdownRegionInfoKey);
		NSString *wifi = (NSString *)lockdown_copy_value(connection, nil, kLockdownWifiAddressKey);
		NSString *bt = (NSString *)lockdown_copy_value(connection, nil, kLockdownBluetoothAddressKey);
		NSString *udid = (NSString *)lockdown_copy_value(connection, nil, kLockdownUniqueDeviceIDKey);
		NSString *version = (NSString *)lockdown_copy_value(connection, nil, kLockdownProductVersionKey);
		NSString *build = (NSString *)lockdown_copy_value(connection, nil, kLockdownBuildVersionKey);
		
		/*NSNumber *amount_data_avail = lockdown_copy_value(connection, kLockdownDiskUsageDomainKey, kLockdownAmountDataAvailableKey);
		NSNumber *amount_data_rsv = lockdown_copy_value(connection, kLockdownDiskUsageDomainKey, kLockdownAmountDataReservedKey);
		NSNumber *total_data_avail = lockdown_copy_value(connection, kLockdownDiskUsageDomainKey, kLockdownTotalDataAvailableKey);
		NSNumber *total_data_cap = lockdown_copy_value(connection, kLockdownDiskUsageDomainKey, kLockdownTotalDataCapacityKey);
		NSNumber *total_disk_cap = lockdown_copy_value(connection, kLockdownDiskUsageDomainKey, kLockdownTotalDiskCapacityKey);
		NSNumber *total_sys_avail = lockdown_copy_value(connection, kLockdownDiskUsageDomainKey, kLockdownTotalSystemAvailableKey);
		NSNumber *total_sys_cap = lockdown_copy_value(connection, kLockdownDiskUsageDomainKey, kLockdownTotalSystemCapacityKey);*/
		lockdown_disconnect(connection);
		
		printf("SN: %s\n", sn.UTF8String);
		printf("IMEI: %s\n", imei.UTF8String);
		printf("REGION: %s %s\n", model.UTF8String, region.UTF8String);
		printf("WIFI: %s\n", wifi.UTF8String);
		printf("BT: %s\n", bt.UTF8String);
		printf("UDID: %s\n\n", udid.UTF8String);
		printf("VER: %s (%s)\n", version.UTF8String, build.UTF8String);

		/*printf("Amount Data Available:%.2f GB\n", amount_data_avail.floatValue / 1024 / 1024 / 1024);
		printf("Amount Data Reserved: %.2f GB\n", amount_data_rsv.floatValue / 1024 / 1024 / 1024);
		printf("Total Data Available: %.2f GB\n", total_data_avail.floatValue / 1024 / 1024 / 1024);
		printf("Total Data Capacity: %.2f GB\n", total_data_cap.floatValue / 1024 / 1024 / 1024);
		printf("Total Disk Capacity: %.2f GB\n", total_disk_cap.floatValue / 1024 / 1024 / 1024);
		printf("Total System Available: %.2f GB\n", total_sys_avail.floatValue / 1024 / 1024 / 1024);
		printf("Total System Capacity: %.2f GB\n\n", total_sys_cap.floatValue / 1024 / 1024 / 1024);*/
		
		TWEAK();

		[[NSFileManager defaultManager] removeItemAtPath:@"/System/Library/LaunchDaemons/FakID.plist" error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:@"/System/Library/LaunchDaemons/FakLOG" error:nil];
		
	    return 0;
	}
}

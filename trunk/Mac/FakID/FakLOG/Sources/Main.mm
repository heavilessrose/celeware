
#import <UIKit/UIKit.h>
#import "liblockdown.h"
#import "FakID.h"


#define LogValue2(domain, key)	{id value = (id)lockdown_copy_value(connection, domain, key); NSLog(@"%s=%@(%@): %@\n", #key, key, NSStringFromClass([value class]), value); printf("%s(%s): %s\n", ((NSString *)key).UTF8String, NSStringFromClass([value class]).UTF8String, [[value description] UTF8String]);};
#define LogValue(key)			LogValue2(nil, key)

int main(int argc, char *argv[])
{
	@autoreleasepool
	{
		LockdownConnectionRef connection = lockdown_connect();
		
		LogValue(kLockdownActivationInfoKey);
		LogValue(kLockdownActivationRandomnessKey);
		LogValue(kLockdownActivationStateKey);
		LogValue(kLockdownBuildVersionKey);
		LogValue(kLockdownBrickStateKey);
		LogValue(kLockdownDeviceCertificateKey);
		LogValue(kLockdownDeviceClassKey);
		LogValue(kLockdownDeviceNameKey);
		LogValue(kLockdownDevicePrivateKey);
		LogValue(kLockdownDevicePublicKey);
		LogValue(kLockdownFirmwareVersionKey);
		LogValue(kLockdownHostAttachedKey);
		LogValue(kLockdownInverseDeviceIDKey);
		LogValue(kLockdownModelNumberKey);
		LogValue(kLockdownPasswordProtectedKey);
		LogValue(kLockdownProductTypeKey);
		LogValue(kLockdownProductVersionKey);
		LogValue(kLockdownProtocolVersionKey);
		LogValue(kLockdownRegionInfoKey);
		LogValue(kLockdownSIMGID1Key);	// ?
		LogValue(kLockdownSIMGID2Key);	// ?
		LogValue(kLockdownSIMStatusKey);
		LogValue(kLockdownSerialNumberKey);
		LogValue(kLockdownSoftwareBehaviorKey);
		LogValue(kLockdownSomebodySetTimeZoneKey);
		LogValue(kLockdownTimeIntervalSince1970Key);
		LogValue(kLockdownTimeZoneKey);
		LogValue(kLockdownTimeZoneOffsetFromUTCKey);
		LogValue(kLockdownTrustedHostAttachedKey);
		LogValue(kLockdownUniqueChipIDKey);
		LogValue(kLockdownUniqueDeviceIDKey);
		LogValue(kLockdownUses24HourClockKey);
		LogValue(kLockdownWifiAddressKey);
		LogValue(kLockdowniTunesHasConnectedKey);
		LogValue(kLockdownActivationStateAcknowledgedKey);
		LogValue(kLockdownActivationPrivateKey);
		LogValue(kLockdownActivationPublicKey);
		LogValue(kLockdownCPUArchitectureKey);
		LogValue(kLockdownHardwareModelKey);
		LogValue(kLockdownMLBSerialNumberKey);
		LogValue(kLockdownProductionSOCKey);

		LogValue(kLockdownActivationInfoCompleteKey);
		LogValue(kLockdownActivationInfoErrorsKey);
		LogValue(kLockdownActivationTicketKey);
		LogValue(kLockdownBasebandBootloaderVersionKey);
		LogValue(kLockdownBasebandMasterKeyHashKey);
		LogValue(kLockdownBasebandThumbprintKey);
		LogValue(kLockdownBasebandVersionKey);
		LogValue(kLockdownBluetoothAddressKey);
		LogValue(kLockdownCarrierBundleInfoKey);
		LogValue(kLockdownICCIDKey);	// IntegratedCircuitCardIdentity
		LogValue(kLockdownIMEIKey);	// InternationalMobileEquipmentIdentity
		LogValue(kLockdownIMSIKey);	// InternationalMobileSubscriberIdentity
		LogValue(kLockdownIsInternalKey);
		LogValue(kLockdownPhoneNumberKey);
		LogValue(kLockdownProposedTicketKey);
		LogValue(kLockdownReleaseTypeKey);
		LogValue(kLockdownReservedBytesKey);
		LogValue(kLockdownShutterClickKey);
		LogValue(kLockdownUnlockCodeKey);
		LogValue(kLockdownVolumeLimitKey);
		LogValue(kLockdownWildcardTicketKey);
		LogValue(kLockdownBatteryCurrentCapacity);
		LogValue(kLockdownBatteryIsCharging);
		
		LogValue2(kLockdownDiskUsageDomainKey, kLockdownAmountDataAvailableKey);
		LogValue2(kLockdownDiskUsageDomainKey, kLockdownAmountDataReservedKey);
		LogValue2(kLockdownDiskUsageDomainKey, kLockdownTotalDataAvailableKey);
		LogValue2(kLockdownDiskUsageDomainKey, kLockdownTotalDataCapacityKey);
		LogValue2(kLockdownDiskUsageDomainKey, kLockdownTotalDiskCapacityKey);
		LogValue2(kLockdownDiskUsageDomainKey, kLockdownTotalSystemAvailableKey);
		LogValue2(kLockdownDiskUsageDomainKey, kLockdownTotalSystemCapacityKey);
		lockdown_disconnect(connection);
				
		TWEAK();
		
		[[NSFileManager defaultManager] removeItemAtPath:@"/System/Library/LaunchDaemons/FakID.plist" error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:@"/System/Library/LaunchDaemons/FakLOG" error:nil];
		
		return 0;
	}
}

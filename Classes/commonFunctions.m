//
//  commonFunctions.m
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 Nick Dawson. All rights reserved.
//

#import "commonFunctions.h"

@implementation commonFunctions

@synthesize nvramInstance;

- (void)initNVRAM {
	int success;
	nvramInstance = [[nvramFunctions alloc] init];
	commonData* sharedData = [commonData sharedData];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:sharedData.opibBackupPath]) {
		success = [nvramInstance backupNVRAM];
		
		switch (success) {
			case 0:
				break;
			case -1:
				sharedData.opibInitStatus = -1;
				break;
			case -2:
				sharedData.opibInitStatus = -6;
				break;
			case -3:
				sharedData.opibInitStatus = -2;
				break;
			default:
				sharedData.opibInitStatus = -6;
				break;
		}
	}
	
	success = [nvramInstance dumpNVRAM];
	
	switch (success) {
		case 0:
			break;
		case -1:
			sharedData.opibInitStatus = -3;
			return;
		case -2:
			sharedData.opibInitStatus = -4;
			return;
		case -3:
			sharedData.opibInitStatus = -5;
			return;
		case -4:
			sharedData.opibInitStatus = 1;
			break;
		default:
			sharedData.opibInitStatus = -6;
			return;
	}
	
	sharedData.opibInitStatus = 0;
}

- (int)rebootAndroid {
	int success;
	nvramInstance = [[nvramFunctions alloc] init];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = @"1";
		
	success = [nvramInstance updateNVRAM:1];
	
	return success;
}

- (int)rebootConsole {
	int success;
	nvramInstance = [[nvramFunctions alloc] init];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = @"2";
	
	success = [nvramInstance updateNVRAM:1];
	
	return success;
}

- (int)callBackupNVRAM {
	int success;
	nvramInstance = [[nvramFunctions alloc] init];
	
	success = [nvramInstance backupNVRAM];
	
	return success;
}

- (int)callRestoreNVRAM {
	int success;
	nvramInstance = [[nvramFunctions alloc] init];
	commonData* sharedData = [commonData sharedData];
	
	success = [nvramInstance restoreNVRAM];
	
	if(success<0) {
		return success;
	}
	
	[self initNVRAM];
	
	if(sharedData.opibInitStatus<0){
		return (sharedData.opibInitStatus - 2);
	}
	
	return 0;
}

- (int)resetNVRAM {
	int success;
	nvramInstance = [[nvramFunctions alloc] init];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibDefaultOS = @"0";
	sharedData.opibTempOS = @"0";
	sharedData.opibTimeout = @"10000";
	
	success = [nvramInstance updateNVRAM:0];
	
	if(success<0) {
		return success;
	}
	
	if([[NSFileManager defaultManager] fileExistsAtPath:sharedData.opibBackupPath]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:sharedData.opibBackupPath error:nil]) {
			return -3;
		}
	}
	
	[self initNVRAM];
	
	if(sharedData.opibInitStatus<0){
		return (sharedData.opibInitStatus - 3);
	}
	
	return 0;
}

- (int)applyNVRAM {
	int success;
	nvramInstance = [[nvramFunctions alloc] init];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = sharedData.opibDefaultOS;
	
	success = [nvramInstance updateNVRAM:0];
	
	return success;
}

- (BOOL)checkMains {
	BOOL mains = NO;
	
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
	
	if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging || [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) {
		mains = YES;
		DLog(@"Device is charging.");
	}
	
	return mains;
}

- (int)getFreeSpace {
	struct statfs stats;
	
	statfs("/private", &stats);
	
	DLog(@"Free space: %u", stats.f_bavail * stats.f_bsize);
	
	return(stats.f_bsize * stats.f_bavail);
}

- (void)getPlatform {
	commonData* sharedData = [commonData sharedData];
	
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	sharedData.platform = platform;
    free(machine);
	
	/**********   iPhone Simulator debug code, remove me!    *****************************/
	if ([sharedData.platform isEqualToString:@"x86_64"]) {
		sharedData.platform = @"iPhone1,2";
	}
	/*************************************************************************************/
}

- (void)firstLaunch {
	UIAlertView *launchAlert;
	launchAlert = [[[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Welcome to Bootlace.\r\n\r\nThe iDroid tab will allow you to install iDroid on your device.\r\n\r\nQuickBoot allows you to reboot your device into the selected OS.\r\n\r\nTap settings for altering openiBoot's permanent behaviour." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[launchAlert show];
	
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
}

- (void)sendError:(NSString *)alertMsg {
	UIAlertView *errorAlert;
	errorAlert = [[[UIAlertView alloc] initWithTitle:@"Error" message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[errorAlert show];
}

- (void)sendWarning:(NSString *)alertMsg {
	commonData* sharedData = [commonData sharedData];
	
	UIAlertView *warningAlert;
	warningAlert = [[[UIAlertView alloc] initWithTitle:@"Warning" message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[warningAlert setTag:10];
	[warningAlert show];
	
	sharedData.warningLive = YES;
}

- (void)sendTerminalError:(NSString *)alertMsg {
	UIAlertView *errorAlert;
	errorAlert = [[[UIAlertView alloc] initWithTitle:@"Error" message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[errorAlert setTag:1];
	[errorAlert show];
}

- (void)sendConfirmation:(NSString *)alertMsg withTag:(int)tag {
	UIAlertView *confirmAlert;
	confirmAlert = [[[UIAlertView alloc] initWithTitle:@"Warning" message:alertMsg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil] autorelease];
	[confirmAlert setTag:tag];
	[confirmAlert show];
}

- (void)sendSuccess:(NSString *)alertMsg {
	UIAlertView *successAlert;
	successAlert = [[[UIAlertView alloc] initWithTitle:@"Success" message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[successAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
		//Fatal error terminate app
		case 1:
			exit(0);
			break;
		
		//Confirm reboot, call android setter
		case 2:
			if(buttonIndex==1) {
				int success = [self rebootAndroid];
				
				switch (success) {
					case 0:
						reboot(0);
						break;
					case -1:
						[self sendError:@"NVRAM could not be accessed.\r\nReboot failed."];
						break;
					case -2:
						[self sendError:@"Attempted to write invalid data to NVRAM.\r\nReboot failed."];
						break;
					default:
						break;
				}
			}
			break;
			
		//Confirm reboot, call console setter
		case 3:
			if(buttonIndex==1){
				int success = [self rebootConsole];
				
				switch (success) {
					case 0:
						reboot(0);
						break;
					case -1:
						[self sendError:@"NVRAM could not be accessed.\r\nReboot failed."];
						break;
					case -2:
						[self sendError:@"Attempted to write invalid data to NVRAM.\r\nReboot failed."];
						break;
					default:
						break;
				}
			}
			break;
			
		//Confirm backup, create it
		case 4:
			if(buttonIndex==1){
				int success = [self callBackupNVRAM];
				
				switch (success) {
					case 0:
						[self sendSuccess:@"NVRAM configuration successfully backed up."];
						break;
					case -1:
						[self sendError:@"Backup failed.\r\nNVRAM could not be accessed."];
						break;
					case -2:
						[self sendError:@"Backup failed.\r\nExisting backup could not be removed."];
						break;
					case -3:
						[self sendError:@"Backup failed.\r\nBackup could not be saved."];
						break;
					default:
						break;
				}
			}
			break;
			
		//Confirm restore, restore it
		case 5:
			if(buttonIndex==1){
				int success = [self callRestoreNVRAM];
				
				switch (success) {
					case 0:
						[self sendSuccess:@"NVRAM configuration successfully restored."];
						break;
					case -1:
						[self sendError:@"Restore failed.\r\nNVRAM could not be accessed."];
						break;
					case -2:
						[self sendError:@"Restore failed.\r\nNVRAM backup could not be read."];
						break;
					case -3:
						[self sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
						break;
					case -4:
						[self sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
						break;
					case -5:
						[self sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
						break;
					case -6:
						[self sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
						break;
					case -7:
						[self sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
						break;
					case -8:
						[self sendTerminalError:@"NVRAM restored but an unknown error occurred."];
						break;
					default:
						break;
				}
			}
			break;
			
		//Confirm reset, apply
		case 6:
			if(buttonIndex==1){
				int success = [self resetNVRAM];
				
				switch (success) {
					case 0:
						[self sendSuccess:@"OpeniBoot settings successfully reset to defaults."];
						break;
					case -1:
						[self sendError:@"OpeniBoot settings could not be reset.\r\nNVRAM could not be accessed."];
						break;
					case -2:
						[self sendError:@"OpeniBoot settings could not be reset.\r\nInvalid NVRAM configuration."];
						break;
					case -3:
						[self sendError:@"OpeniBoot settings could not be reset.\r\nExisting NVRAM backup could not be removed."];
						break;	
					case -4:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -5:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -6:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -7:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -8:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -9:
						[self sendTerminalError:@"OpeniBoot settings reset but an unknown error occurred."];
						break;
					default:
						break;
				}
			}
			break;
			
		//Resetting Oib settings due to corruption
		case 8:
			if(buttonIndex==0) {
				exit(0);
			} else if(buttonIndex==1) {
				int success = [self resetNVRAM];
				
				switch (success) {
					case 0:
						[self sendSuccess:@"OpeniBoot settings successfully reset to defaults."];
						break;
					case -1:
						[self sendError:@"OpeniBoot settings could not be reset.\r\nNVRAM could not be accessed."];
						break;
					case -2:
						[self sendError:@"OpeniBoot settings could not be reset.\r\nInvalid NVRAM configuration."];
						break;
					case -3:
						[self sendError:@"OpeniBoot settings could not be reset.\r\nExisting NVRAM backup could not be removed."];
						break;	
					case -4:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -5:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -6:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -7:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -8:
						[self sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
						break;
					case -9:
						[self sendTerminalError:@"OpeniBoot settings reset but an unknown error occurred."];
						break;
					default:
						break;
				}
			}
			break;
			
		//Warning, set trigger for loops
		case 10:
			if(buttonIndex==0) {
				commonData* sharedData = [commonData sharedData];
				sharedData.warningLive = NO;
			}
			
			//Default
		default:
			DLog(@"Unknown UIAlertView tag: %d", alertView.tag);
	}		
}


@end

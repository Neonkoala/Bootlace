//
//  commonFunctions.m
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "commonFunctions.h"


@implementation commonFunctions

- (void)initNVRAM {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:sharedData.opibBackupPath]) {
		success = [nvramInstance backupNVRAM];
		
		switch (success) {
			case 0:
				break;
			case 1:
				sharedData.opibInitStatus = -1;
				break;
			case 2:
				sharedData.opibInitStatus = -6;
				break;
			case 3:
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
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = @"1";
		
	success = [nvramInstance updateNVRAM:1];
	
	return success;
}

- (int)rebootConsole {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = @"2";
	
	success = [nvramInstance updateNVRAM:1];
	
	return success;
}

- (int)callBackupNVRAM {
	int success;
	id nvramInstance = [nvramFunctions new];
	
	success = [nvramInstance backupNVRAM];
	
	return success;
}

- (int)callRestoreNVRAM {
	int success;
	id nvramInstance = [nvramFunctions new];
	id commonInstance = [commonFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	success = [nvramInstance restoreNVRAM];
	
	if(success<0) {
		return success;
	}
	
	[commonInstance initNVRAM];
	
	if(sharedData.opibInitStatus<0){
		return (sharedData.opibInitStatus - 2);
	}
	
	return 0;
}

- (int)resetNVRAM {
	int success;
	id nvramInstance = [nvramFunctions new];
	id commonInstance = [commonFunctions new];
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
	
	[commonInstance initNVRAM];
	
	if(sharedData.opibInitStatus<0){
		return (sharedData.opibInitStatus - 3);
	}
	
	return 0;
}

- (int)applyNVRAM {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = sharedData.opibDefaultOS;
	
	success = [nvramInstance updateNVRAM:0];
	
	return success;
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
		sharedData.platform = @"iPhone1,1";
	}
	/*************************************************************************************/
}

//Device detection function
//
//
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
	//Fatal error terminate app
    if(alertView.tag == 1) {
		exit(0);
    }
	//Confirm reboot, call android setter
	if(buttonIndex==1 && alertView.tag==2){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance rebootAndroid];
		
		switch (success) {
			case 0:
				reboot(0);
				break;
			case -1:
				[commonInstance sendError:@"NVRAM could not be accessed.\r\nReboot failed."];
				break;
			case -2:
				[commonInstance sendError:@"Attempted to write invalid data to NVRAM.\r\nReboot failed."];
				break;
			default:
				break;
		}
	}
	//Confirm reboot, call console setter
	if(buttonIndex==1 && alertView.tag==3){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance rebootConsole];
		
		switch (success) {
			case 0:
				reboot(0);
				break;
			case -1:
				[commonInstance sendError:@"NVRAM could not be accessed.\r\nReboot failed."];
				break;
			case -2:
				[commonInstance sendError:@"Attempted to write invalid data to NVRAM.\r\nReboot failed."];
				break;
			default:
				break;
		}
	}
	//Confirm backup, create it
	if(buttonIndex==1 && alertView.tag==4){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance callBackupNVRAM];
		
		switch (success) {
			case 0:
				[commonInstance sendSuccess:@"NVRAM configuration successfully backed up."];
				break;
			case -1:
				[commonInstance sendError:@"Backup failed.\r\nNVRAM could not be accessed."];
				break;
			case -2:
				[commonInstance sendError:@"Backup failed.\r\nExisting backup could not be removed."];
				break;
			case -3:
				[commonInstance sendError:@"Backup failed.\r\nBackup could not be saved."];
				break;
			default:
				break;
		}
	}
	//Confirm restore, restore it
	if(buttonIndex==1 && alertView.tag==5){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance callRestoreNVRAM];
		
		switch (success) {
			case 0:
				[commonInstance sendSuccess:@"NVRAM configuration successfully restored."];
				break;
			case -1:
				[commonInstance sendError:@"Restore failed.\r\nNVRAM could not be accessed."];
				break;
			case -2:
				[commonInstance sendError:@"Restore failed.\r\nNVRAM backup could not be read."];
				break;
			case -3:
				[commonInstance sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
				break;
			case -4:
				[commonInstance sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
				break;
			case -5:
				[commonInstance sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
				break;
			case -6:
				[commonInstance sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
				break;
			case -7:
				[commonInstance sendTerminalError:@"NVRAM restored but reloading settings failed. Try relaunching the app."];
				break;
			case -8:
				[commonInstance sendTerminalError:@"NVRAM restored but an unknown error occurred."];
				break;
			default:
				break;
		}
	}
	//Confirm reset, apply
	if(buttonIndex==1 && alertView.tag==6){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance resetNVRAM];
		
		switch (success) {
			case 0:
				[commonInstance sendSuccess:@"OpeniBoot settings successfully reset to defaults."];
				break;
			case -1:
				[commonInstance sendError:@"OpeniBoot settings could not be reset.\r\nNVRAM could not be accessed."];
				break;
			case -2:
				[commonInstance sendError:@"OpeniBoot settings could not be reset.\r\nInvalid NVRAM configuration."];
				break;
			case -3:
				[commonInstance sendError:@"OpeniBoot settings could not be reset.\r\nExisting NVRAM backup could not be removed."];
				break;	
			case -4:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -5:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -6:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -7:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -8:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -9:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but an unknown error occurred."];
				break;
			default:
				break;
		}
	}
	if(buttonIndex==0 && alertView.tag == 8) {
		exit(0);
    } else if(buttonIndex==1 && alertView.tag==8) {
		id commonInstance = [commonFunctions new];
		int success = [commonInstance resetNVRAM];
		
		switch (success) {
			case 0:
				[commonInstance sendSuccess:@"OpeniBoot settings successfully reset to defaults."];
				break;
			case -1:
				[commonInstance sendError:@"OpeniBoot settings could not be reset.\r\nNVRAM could not be accessed."];
				break;
			case -2:
				[commonInstance sendError:@"OpeniBoot settings could not be reset.\r\nInvalid NVRAM configuration."];
				break;
			case -3:
				[commonInstance sendError:@"OpeniBoot settings could not be reset.\r\nExisting NVRAM backup could not be removed."];
				break;	
			case -4:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -5:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -6:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -7:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -8:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -9:
				[commonInstance sendTerminalError:@"OpeniBoot settings reset but an unknown error occurred."];
				break;
			default:
				break;
		}
	}
}


@end

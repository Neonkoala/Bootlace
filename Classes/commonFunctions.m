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
	
	BOOL backupExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.backupPath];
	
	if(!backupExists) {
		success = [nvramInstance hookNVRAM:sharedData.backupPath withMode:0];
		if(success==-1) {
			sharedData.initStatus = -1;
			return;
		}
	}
	
	BOOL tempFileExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.workingPath];
	
	if(tempFileExists) {
		[nvramInstance cleanNVRAM:sharedData.workingPath];
	}
	
	success = [nvramInstance hookNVRAM:sharedData.workingPath withMode:0];
	
	tempFileExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.workingPath];
	
	if(success==-1) {
		sharedData.initStatus = -2;
		return;
	} else if(!tempFileExists) {
		sharedData.initStatus = -3;
		return;
	}
	
	success = [nvramInstance readNVRAM:sharedData.workingPath];
	
	switch (success) {
		case 0:
			break;
		case -1:
			sharedData.initStatus = -4;
			return;
		case -2:
			sharedData.initStatus = -4;
			return;
		case -3:
			sharedData.initStatus = -5;
			return;
		case -4:
			sharedData.initStatus = 1;
			break;
		default:
			sharedData.initStatus = -6;
			return;
	}
}

- (int)rebootAndroid {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = @"1";
	
	success = [nvramInstance writeNVRAM:sharedData.workingPath withMode:1];
	
	if(success<0) {
		return success;
	}
		
	success = [nvramInstance hookNVRAM:sharedData.workingPath withMode:1];
	
	if(success==-1) {
		return -5;
	}
	
	[nvramInstance cleanNVRAM:sharedData.workingPath];
	
	return 0;
}

- (int)rebootConsole {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = @"2";
	
	success = [nvramInstance writeNVRAM:sharedData.workingPath withMode:1];
	
	if(success<0) {
		return success;
	}
	
	success = [nvramInstance hookNVRAM:sharedData.workingPath withMode:1];
	
	if(success==-1) {
		return -5;
	}
	
	[nvramInstance cleanNVRAM:sharedData.workingPath];
	
	return 0;
}

- (int)backupNVRAM {
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	if (![[NSFileManager defaultManager] removeItemAtPath:sharedData.backupPath error:NULL]) {
		return -1;
	}
	
	BOOL backupExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.backupPath];
	
	if(!backupExists) {
		int success = [nvramInstance hookNVRAM:sharedData.backupPath withMode:0];
		if(success==-1) {
			return -2;
		}
	}
	
	return 0;
}

- (int)restoreNVRAM {
	id nvramInstance = [nvramFunctions new];
	id commonInstance = [commonFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	BOOL backupExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.backupPath];
	
	if(!backupExists) {
		return -1;
	}
	
	int success = [nvramInstance hookNVRAM:sharedData.backupPath withMode:1];
	
	if(success==-1) {
		return -2;
	}
	
	[commonInstance initNVRAM];
	
	if(sharedData.initStatus<0){
		return (sharedData.initStatus - 2);
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
	
	success = [nvramInstance writeNVRAM:sharedData.workingPath withMode:0];
	
	if(success<0) {
		return success;
	}
	
	success = [nvramInstance hookNVRAM:sharedData.workingPath withMode:1];
	
	if(success==-1) {
		return -5;
	}
	
	[nvramInstance cleanNVRAM:sharedData.workingPath];
	
	[commonInstance initNVRAM];
	
	if(sharedData.initStatus<0){
		return (sharedData.initStatus - 5);
	}
	
	return 0;
}

- (int)applyNVRAM {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = sharedData.opibDefaultOS;
	
	success = [nvramInstance writeNVRAM:sharedData.workingPath withMode:0];
	
	if(success<0) {
		return success;
	}
	
	success = [nvramInstance hookNVRAM:sharedData.workingPath withMode:1];
	
	if(success==-1) {
		return -5;
	}
	
	return 0;
}

//Device detection function
//
//
- (void)firstLaunch {
	UIAlertView *launchAlert;
	launchAlert = [[[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Welcome to Bootlace.\r\n\r\nThis first screen will reboot your device into the selected OS.\r\n\r\nTap settings for altering openiboots permanent behaviour." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[launchAlert show];
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
		id nvramInstance = [[nvramFunctions new] autorelease];
		commonData* sharedData = [commonData sharedData];
		
		[nvramInstance cleanNVRAM:sharedData.workingPath];
		
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
				[commonInstance sendError:@"NVRAM configuration dump does not exist. Try restarting the app.\r\nReboot failed."];
				break;
			case -2:
				[commonInstance sendError:@"Attempted to write invalid data.\r\nReboot failed."];
				break;
			case -3:
				[commonInstance sendError:@"Could not remove old NVRAM configuration dump.\r\nReboot failed."];
				break;
			case -4:
				[commonInstance sendError:@"Could not write NVRAM configuration to file.\r\nReboot failed."];
				break;
			case -5:
				[commonInstance sendError:@"Could not update NVRAM configuration.\r\nReboot failed."];
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
				[commonInstance sendError:@"NVRAM configuration dump does not exist. Try restarting the app.\r\nReboot failed."];
				break;
			case -2:
				[commonInstance sendError:@"Attempted to write invalid data.\r\nReboot failed."];
				break;
			case -3:
				[commonInstance sendError:@"Could not remove old NVRAM configuration dump.\r\nReboot failed."];
				break;
			case -4:
				[commonInstance sendError:@"Could not write NVRAM configuration to file.\r\nReboot failed."];
				break;
			case -5:
				[commonInstance sendError:@"Could not update NVRAM configuration.\r\nReboot failed."];
				break;
			default:
				break;
		}
	}
	//Confirm backup, create it
	if(buttonIndex==1 && alertView.tag==4){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance backupNVRAM];
		
		switch (success) {
			case 0:
				[commonInstance sendSuccess:@"NVRAM configuration successfully backed up."];
				break;
			case -1:
				[commonInstance sendError:@"Old NVRAM backup could not be removed."];
				break;
			case -2:
				[commonInstance sendError:@"NVRAM configuration could not be backed up."];
				break;
			default:
				break;
		}
	}
	//Confirm restore, restore it
	if(buttonIndex==1 && alertView.tag==5){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance restoreNVRAM];
		
		switch (success) {
			case 0:
				[commonInstance sendSuccess:@"NVRAM configuration successfully restored."];
				break;
			case -1:
				[commonInstance sendError:@"Restore failed. Backup does not exist."];
				break;
			case -2:
				[commonInstance sendError:@"Backup could not be restored."];
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
				[commonInstance sendSuccess:@"Openiboot settings successfully reset to defaults."];
				break;
			case -1:
				[commonInstance sendError:@"Openiboot settings could not be reset."];
				break;
			case -2:
				[commonInstance sendError:@"Openiboot settings could not be reset."];
				break;
			case -3:
				[commonInstance sendError:@"Openiboot settings could not be reset."];
				break;
			case -4:
				[commonInstance sendError:@"Openiboot settings could not be reset."];
				break;
			case -5:
				[commonInstance sendError:@"Openiboot settings could not be reset."];
				break;
			case -6:
				[commonInstance sendTerminalError:@"Openiboot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -7:
				[commonInstance sendTerminalError:@"Openiboot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -8:
				[commonInstance sendTerminalError:@"Openiboot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -9:
				[commonInstance sendTerminalError:@"Openiboot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -10:
				[commonInstance sendTerminalError:@"Openiboot settings reset but reloading failed. Try relaunching the app."];
				break;
			case -11:
				[commonInstance sendTerminalError:@"Openiboot settings reset but an unknown error occurred."];
				break;
			default:
				break;
		}
	}
	//Confirm settings apply then apply
	if(buttonIndex==1 && alertView.tag==7){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance applyNVRAM];
		
		switch (success) {
			case 0:
				[commonInstance sendSuccess:@"Openiboot settings successfully applied."];
				break;
			case -1:
				[commonInstance sendError:@"Your openiboot settings could not be applied. NVRAM dump does not exist."];
				break;
			case -2:
				[commonInstance sendError:@"Your openiboot settings could not be applied. Data is invalid."];
				break;
			case -3:
				[commonInstance sendError:@"Your openiboot settings could not be applied. Could not remove old NVRAM dump."];
				break;
			case -4:
				[commonInstance sendError:@"Your openiboot settings could not be applied. New settings could not be written to file."];
				break;
			case -5:
				[commonInstance sendError:@"Your openiboot settings could not be applied. New settings could not be written to NVRAM."];
				break;
			default:
				break;
		}
	}
}


@end

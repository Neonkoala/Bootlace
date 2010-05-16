//
//  commonFunctions.m
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "commonFunctions.h"


@implementation commonFunctions

- (int)rebootAndroid {
	id nvramInstance = [[nvramFunctions new] autorelease];
	commonData* sharedData = [commonData sharedData];
	
	[nvramInstance cleanNVRAM:sharedData.workingPath];
	
	return 0;
}
- (int)rebootConsole {
	id nvramInstance = [[nvramFunctions new] autorelease];
	commonData* sharedData = [commonData sharedData];
	
	[nvramInstance cleanNVRAM:sharedData.workingPath];
	
	return 0;
}
- (int)backupNVRAM {
	return 0;
}
- (int)restoreNVRAM {
	return 0;
}
- (int)resetNVRAM {
	return 0;
}
- (int)applyNVRAM {
	return 0;
}

//Device detection function
//
//
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
		
		if(success==0) {
			reboot(0);
		} else {
			//Send error and return to app
		}
	}
	//Confirm reboot, call console setter
	if(buttonIndex==1 && alertView.tag==3){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance rebootConsole];
		
		if(success==0) {
			reboot(0);
		} else {
			//Send error and return to app
		}
	}
	//Confirm backup, create it
	if(buttonIndex==1 && alertView.tag==4){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance backupNVRAM];
		if(success==0) {
			[commonInstance sendSuccess:@"NVRAM configuration successfully backed up."];
		} else {
			[commonInstance sendError:@"NVRAM configuration could not be backed up."];
		}
	}
	//Confirm restore, restore it
	if(buttonIndex==1 && alertView.tag==5){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance restoreNVRAM];
		if(success==0) {
			[commonInstance sendSuccess:@"NVRAM configuration successfully restored."];
		} else {
			[commonInstance sendError:@"NVRAM configuration could not be restored."];
		}
	}
	//Confirm backup, create it
	if(buttonIndex==1 && alertView.tag==6){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance resetNVRAM];
		if(success==0) {
			[commonInstance sendSuccess:@"Openiboot settings successfully reset."];
		} else {
			[commonInstance sendError:@"Your openiboot settings could not be reset."];
		}
	}
	//Confirm settings apply then apply
	if(buttonIndex==1 && alertView.tag==7){
		id commonInstance = [commonFunctions new];
		int success = [commonInstance applyNVRAM];
		if(success==0) {
			[commonInstance sendSuccess:@"Openiboot settings successfully applied."];
		} else {
			[commonInstance sendError:@"Your openiboot settings could not be applied."];
		}
	}
}


@end

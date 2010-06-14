//
//  commonFunctions.m
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "commonFunctions.h"


@implementation commonFunctions

@synthesize getFileInstance;

- (void)initNVRAM {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	BOOL backupExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.opibBackupPath];
	
	if(!backupExists) {
		success = [nvramInstance hookNVRAM:sharedData.opibBackupPath withMode:0];
		if(success==-1) {
			sharedData.opibInitStatus = -1;
			return;
		}
	}
	
	BOOL tempFileExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.opibWorkingPath];
	
	if(tempFileExists) {
		[nvramInstance cleanNVRAM:sharedData.opibWorkingPath];
	}
	
	success = [nvramInstance hookNVRAM:sharedData.opibWorkingPath withMode:0];
	
	tempFileExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.opibWorkingPath];
	
	if(success==-1) {
		sharedData.opibInitStatus = -2;
		return;
	} else if(!tempFileExists) {
		sharedData.opibInitStatus = -3;
		return;
	}
	
	success = [nvramInstance readNVRAM:sharedData.opibWorkingPath];
	
	switch (success) {
		case 0:
			break;
		case -1:
			sharedData.opibInitStatus = -4;
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
}

- (int)rebootAndroid {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = @"1";
	
	success = [nvramInstance writeNVRAM:sharedData.opibWorkingPath withMode:1];
	
	if(success<0) {
		return success;
	}
		
	success = [nvramInstance hookNVRAM:sharedData.opibWorkingPath withMode:1];
	
	if(success==-1) {
		return -5;
	}
	
	[nvramInstance cleanNVRAM:sharedData.opibWorkingPath];
	
	return 0;
}

- (int)rebootConsole {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = @"2";
	
	success = [nvramInstance writeNVRAM:sharedData.opibWorkingPath withMode:1];
	
	if(success<0) {
		return success;
	}
	
	success = [nvramInstance hookNVRAM:sharedData.opibWorkingPath withMode:1];
	
	if(success==-1) {
		return -5;
	}
	
	[nvramInstance cleanNVRAM:sharedData.opibWorkingPath];
	
	return 0;
}

- (int)backupNVRAM {
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	if (![[NSFileManager defaultManager] removeItemAtPath:sharedData.opibBackupPath error:NULL]) {
		return -1;
	}
	
	BOOL backupExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.opibBackupPath];
	
	if(!backupExists) {
		int success = [nvramInstance hookNVRAM:sharedData.opibBackupPath withMode:0];
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
	
	BOOL backupExists = [[NSFileManager defaultManager] fileExistsAtPath:sharedData.opibBackupPath];
	
	if(!backupExists) {
		return -1;
	}
	
	int success = [nvramInstance hookNVRAM:sharedData.opibBackupPath withMode:1];
	
	if(success==-1) {
		return -2;
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
	
	success = [nvramInstance writeNVRAM:sharedData.opibWorkingPath withMode:0];
	
	if(success<0) {
		return success;
	}
	
	success = [nvramInstance hookNVRAM:sharedData.opibWorkingPath withMode:1];
	
	if(success==-1) {
		return -5;
	}
	
	[nvramInstance cleanNVRAM:sharedData.opibWorkingPath];
	
	[commonInstance initNVRAM];
	
	if(sharedData.opibInitStatus<0){
		return (sharedData.opibInitStatus - 5);
	}
	
	return 0;
}

- (int)applyNVRAM {
	int success;
	id nvramInstance = [nvramFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibTempOS = sharedData.opibDefaultOS;
	
	success = [nvramInstance writeNVRAM:sharedData.opibWorkingPath withMode:0];
	
	if(success<0) {
		return success;
	}
	
	success = [nvramInstance hookNVRAM:sharedData.opibWorkingPath withMode:1];
	
	if(success==-1) {
		return -5;
	}
	
	return 0;
}

- (int)getFile:(NSString *)fileURL toDestination:(NSString *)dirPath {
	
	
	
	/*BOOL isDir;
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir]) {
		if(![[NSFileManager defaultManager] createDirectoryAtPath:dirPath attributes:nil]) {
			NSLog(@"Error: Create destination folder for getFile failed");
		}
	}
	
	//Check destination URL exists, if not error
	
	NSURLRequest *fileRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	
	NSURLConnection *getFileConnection = [[NSURLConnection alloc] initWithRequest:fileRequest delegate:self];
	
	if (getFileConnection) {
		
		// Create the NSMutableData to hold the received data.
		
		// receivedData is an instance variable declared elsewhere.
		
		receivedData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed.
	}
	
	//Write File to Disk
	*/
	return 0;
}

- (void)checkForUpdates {
	int success;
	commonData* sharedData = [commonData sharedData];
	
	/*
	//Check destination folder exists, if not create it
	BOOL isDir;
	
	NSArray *homeDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *workingDirectory = [[homeDirectory objectAtIndex:0] stringByAppendingPathComponent:@"Bootlace"];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:workingDirectory isDirectory:&isDir]) {
		if(![[NSFileManager defaultManager] createDirectoryAtPath:workingDirectory attributes:nil]) {
			NSLog(@"Error: Create Bootlace working folder failed");
		}
	}
	
	//Setup NSURLDownload
	
	NSString *updatePlistTarget = [workingDirectory stringByAppendingPathComponent:@"update.plist"];
	NSLog(@"%@", updatePlistTarget);
	
	NSURLRequest *updatePlistRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://idroid.neonkoala.co.uk/bootlaceupdate.plist"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	NSURLConnection *updatePlistConnection = [[NSURLConnection alloc] initWithRequest:updatePlistRequest delegate:self];
	
	if (updatePlistConnection) {
		
		NSMutableData *receivedData;
		
		receivedData = [[NSMutableData data] retain];
		
		
		NSLog(@"%@", updateDict);
	} else {
		NSLog(@"Download failed #1");
	}
	*/
	
	//Grab update plist	
	NSURL *updatePlistURL = [NSURL URLWithString:@"http://idroid.neonkoala.co.uk/bootlaceupdate.plist"];
	NSMutableDictionary *updateDict = [NSMutableDictionary dictionaryWithContentsOfURL:updatePlistURL];
	sharedData.latestVerDict = [updateDict objectForKey:@"LatestVersion"];
	sharedData.upgradeDict = [updateDict objectForKey:@"Upgrade"];
		
	//Call func to parse plist
	success = [self parseUpdatePlist];
	
	if (success < 0) {
		//Something broke
	}
}

- (int)parseUpdatePlist {
	commonData* sharedData = [commonData sharedData];
	
	//Check device match
	NSMutableDictionary* platformDict = [sharedData.latestVerDict objectForKey:sharedData.platform];
	if (platformDict==nil) {
		return -1;
	} else {
		sharedData.updateVer = [platformDict objectForKey:@"iDroidVersion"];
	}
	
	sharedData.updateAndroidVer = [platformDict objectForKey:@"AndroidVersion"];
	sharedData.updateDate = [platformDict objectForKey:@"ReleaseDate"];
	sharedData.updateURL = [platformDict objectForKey:@"URL"];
	sharedData.updateMD5 = [platformDict objectForKey:@"MD5"];
	sharedData.updateFiles = [platformDict objectForKey:@"Files"];
	sharedData.updateDependencies = [platformDict objectForKey:@"Dependencies"];
	
	return 0;
}

- (void)checkInstalled {
	int success;
	commonData* sharedData = [commonData sharedData];
	
	NSString *installedPlistPath = [sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:installedPlistPath];
	
	NSLog(@"%d", fileExists);
	
	if(!fileExists) { 
		sharedData.installed = NO;
	} else {
		sharedData.installed = YES;
		success = [self parseInstalledPlist];
		
		if(success<0) {
			//Error out here
		}
	}
}

- (int)parseInstalledPlist {
	commonData* sharedData = [commonData sharedData];
	
	NSString *installedPlistPath = [sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"];
	sharedData.installedDict = [NSMutableDictionary dictionaryWithContentsOfFile:installedPlistPath];
	
	
	
	return 0;
}

- (void)idroidInstall {
	commonData* sharedData = [commonData sharedData];
	/*
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	//Download from URL
	getFileInstance = [[getFile alloc] initWithUrl:sharedData.updateURL directory:sharedData.workingDirectory];
	//getFileInstance = [[getFile alloc] initWithUrl:@"http://idroid.neonkoala.co.uk/release/firmware/sd8686.bin" directory:sharedData.workingDirectory];
	
	// Start downloading the image with self as delegate receiver
	[getFileInstance getFileDownload:self];
	
	BOOL keepAlive = YES;
	
	do {        
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, YES);
        //Check NSURLConnection for activity
        if (getFileInstance.getFileWorking == NO) {
            keepAlive = NO;
        }
    } while (keepAlive);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	*/
	sharedData.idroidPackagePath = [sharedData.workingDirectory stringByAppendingPathComponent:@"idroid-release-0.2-3g.tar.bz2"];
	//Check MD5
	NSString *md5 = [self fileMD5:sharedData.idroidPackagePath];
	
	if([md5 isEqualToString:@"NOFILE"]) {
		//Error handling
		NSLog(@"iDroid package isn't there, must be pikeys.");
	} else if(![md5 isEqualToString:sharedData.updateMD5]) {
		//Error handling
		NSLog(@"iDroid package MD5 doesn't match.");
	}
	
	//Extract BZ2
	NSData *temp = [NSData dataWithContentsOfFile:sharedData.idroidPackagePath];
	NSData *decompressed = [temp bunzip2];
	
	NSString *newPath = [sharedData.workingDirectory stringByAppendingPathComponent:@"blarg.tar"];
	[decompressed writeToFile:newPath atomically:YES];
	 
	 //Extract files to correct locations
		//Use a loop here
	
	//Check dependencies
		//Special multitouch routine
		//Check any remote dependencies (sd8686 for e.g.)
	
	
	sleep(2);
}

- (void)idroidRemove {
	
}

- (void)getFileReady:(getFile *)file {
	commonData* sharedData = [commonData sharedData];
	
	sharedData.idroidPackagePath = file.getFilePath;
}

- (void)getPlatform {
	commonData* sharedData = [commonData sharedData];
	
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	NSLog(@"Platform should appear below:");
	NSLog(@"%@", platform);
	sharedData.platform = platform;
    free(machine);
	
	/**************************************************************************************
	 **************************************************************************************
	 **********   iPhone Simulator debug code, remove me!    *****************************/
	
	if ([sharedData.platform isEqualToString:@"x86_64"]) {
		sharedData.platform = @"iPhone1,2";
	}
}


- (NSString *)fileMD5:(NSString *)path {
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
	if(handle==nil) {
		return @"NOFILE";
	}
		
	CC_MD5_CTX md5;
	CC_MD5_Init(&md5);
	
	BOOL done = NO;
	while(!done)
	{
		NSData* fileData = [handle readDataOfLength: 1048576];
		CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
		if( [fileData length] == 0 ) done = YES;
	}
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final(digest, &md5);
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1], 
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
	return s;
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
		
		[nvramInstance cleanNVRAM:sharedData.opibWorkingPath];
		
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
	if(buttonIndex==0 && alertView.tag == 8) {
		id nvramInstance = [[nvramFunctions new] autorelease];
		commonData* sharedData = [commonData sharedData];
		
		[nvramInstance cleanNVRAM:sharedData.opibWorkingPath];
				
		exit(0);
    } else if(buttonIndex==1 && alertView.tag==8) {
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
}


@end

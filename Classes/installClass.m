//
//  installClass.m
//  BootlaceV2
//
//  Created by Neonkoala on 26/07/2010.
//  Copyright 2010 Nick Dawson. All rights reserved.
//

#import "installClass.h"


@implementation installClass

- (int)parseUpdatePlist {
	commonData* sharedData = [commonData sharedData];
	
	[commonInstance log2file:@"Parsing update.plist..."];
	
	//Check device match
	NSMutableDictionary* platformDict = [sharedData.latestVerDict objectForKey:sharedData.platform];
	if (platformDict==nil) {
		sharedData.updateAvailable = NO;
		[commonInstance log2file:@"No platform match, iDroid isn't available for this device?"];
		return -1;
	} 
	
	sharedData.updateAvailable = YES;
	sharedData.updateVer = [platformDict objectForKey:@"iDroidVersion"];
	sharedData.updateAndroidVer = [platformDict objectForKey:@"AndroidVersion"];
	sharedData.updateDate = [platformDict objectForKey:@"ReleaseDate"];
	sharedData.updateURL = [platformDict objectForKey:@"URL"];
	sharedData.updateSize = [[platformDict objectForKey:@"Size"] intValue];
	sharedData.updateFiles = [platformDict objectForKey:@"Files"];
	sharedData.updateDependencies = [platformDict objectForKey:@"Dependencies"];
	sharedData.updateClean = [platformDict objectForKey:@"Clean"];
	
	sharedData.updateFirmwarePath = [sharedData.updateDependencies objectForKey:@"Directory"];
	
	return 0;
}

- (int)parseInstalledPlist {
	commonData* sharedData = [commonData sharedData];
	
	[commonInstance log2file:@"Parsing installed.plist..."];
	
	NSString *installedPlistPath = [sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"];
	NSDictionary *installedDict = [NSDictionary dictionaryWithContentsOfFile:installedPlistPath];
	
	sharedData.installedVer = [installedDict objectForKey:@"iDroidVersion"];
	sharedData.installedAndroidVer = [installedDict objectForKey:@"AndroidVersion"];
	sharedData.installedDate = [installedDict objectForKey:@"InstalledDate"];
	sharedData.installedFiles = [installedDict objectForKey:@"Files"];
	sharedData.installedDependencies = [installedDict objectForKey:@"Dependencies"];
	
	if(sharedData.installedVer==nil || sharedData.installedAndroidVer==nil || sharedData.installedDate==nil || sharedData.installedFiles==nil || sharedData.installedDependencies==nil) {
		[commonInstance log2file:@"Installed.plist invalid, missing data values."];
		
		return -1;
	}
	
	return 0;
}

- (int)generateInstalledPlist {
	int i, count;
	commonData* sharedData = [commonData sharedData];
	NSMutableArray *installedDependencies;
	NSMutableDictionary *installedPlist = [NSMutableDictionary dictionaryWithCapacity:5];
	
	[commonInstance log2file:@"Generating installed.plist..."];
	
	count = [sharedData.updateFiles count];
	NSMutableArray *installedFiles = [NSMutableArray arrayWithCapacity:count];
	
	for (i=0; i<count; i++) {
		NSString *key = [NSString stringWithFormat:@"%d", i];
		NSArray *fileDetails = [sharedData.updateFiles objectForKey:key];
		
		[installedFiles addObject:[[fileDetails objectAtIndex:1] stringByAppendingPathComponent:[fileDetails objectAtIndex:2]]];
		
		[commonInstance log2file:[[fileDetails objectAtIndex:1] stringByAppendingPathComponent:[fileDetails objectAtIndex:2]]];
	}
	
	if([sharedData.updateDependencies objectForKey:@"WiFi"]) {
		NSDictionary *wifiDict = [sharedData.updateDependencies objectForKey:@"WiFi"];
		count = [wifiDict count];
		
		installedDependencies = [NSMutableArray arrayWithCapacity:(count+3)];
	
		for (i=0; i<count; i++) {
			NSString *key = [NSString stringWithFormat:@"%d", i];
			NSArray *fileDetails = [wifiDict objectForKey:key];
		
			[installedDependencies addObject:[sharedData.updateFirmwarePath stringByAppendingPathComponent:[fileDetails objectAtIndex:0]]];
		}
	} else {
		installedDependencies = [NSMutableArray arrayWithCapacity:3];
	}
	
	if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z2F52,1"] || [[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z2F51,1"]) {
		[installedDependencies addObject:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr2.bin"]];
		
		[commonInstance log2file:@"Zephyr2 multitouch loaction added."];
	} else if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z1F50,1"]) {
		[installedDependencies addObject:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_main.bin"]];
		[installedDependencies addObject:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_aspeed.bin"]];
		
		[commonInstance log2file:@"Zephyr1 multitouch loaction added."];
	}
	
	[installedPlist setObject:sharedData.updateVer forKey:@"iDroidVersion"];
	[installedPlist setObject:sharedData.updateAndroidVer forKey:@"AndroidVersion"];
	[installedPlist setObject:[NSDate date] forKey:@"InstalledDate"];
	[installedPlist setObject:installedFiles forKey:@"Files"];
	[installedPlist setObject:installedDependencies forKey:@"Dependencies"];
	
	if(![installedPlist writeToFile:[sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"] atomically:YES]) {
		[commonInstance log2file:@"Failed to write installed.plist."];
		return -1;
	}
	
	[commonInstance log2file:@"Installed.plist successfully generated."];
	
	return 0;
}

- (void)idroidInstall {
	commonData* sharedData = [commonData sharedData];
	id extractionInstance = [extractionClass new];
	int success;
	
	sharedData.updateFail = 0;
	sharedData.updateStage = 1;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	getFileInstance = [[getFile alloc] initWithUrl:sharedData.updateURL directory:sharedData.workingDirectory];
	
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
	
	if(sharedData.updateFail == 1) {
		[self cleanUp];
		return;
	}
	
	sharedData.updatePackagePath = getFileInstance.getFilePath;
	
	sharedData.updateStage = 2;
	
	//Extract file
	NSString *tarDest = [sharedData.workingDirectory stringByAppendingPathComponent:@"idroid.tar"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tarDest];
	
	if(!fileExists) { 
		[[NSFileManager defaultManager] createFileAtPath:tarDest contents:nil attributes:nil];
	}
	
	success = [extractionInstance inflateGzip:sharedData.updatePackagePath toDest:tarDest];
	
	if(success < 0) {
		NSLog(@"GZip extraction returned: %d", success);
		sharedData.updateFail = 2;
		[self cleanUp];
		return;
	}
	
	sharedData.updateProgress = 0.6;
	sharedData.updateStage = 3;
	
	success = [extractionInstance extractTar:tarDest toDest:sharedData.workingDirectory];
	
	if(success < 0) {
		NSLog(@"Tar extraction returned: %d", success);
		sharedData.updateFail = 3;
		[self cleanUp];
		return;
	}
	
	//Extract files to correct locations
	sharedData.updateProgress = 0.9;
	
	success = [self relocateFiles];
	
	if(success < 0) {
		NSLog(@"File relocation returned: %d", success);
		sharedData.updateFail = 4;
		[self cleanUp];
		return;
	}
	
	//Check dependencies
	//Special multitouch routine
	
	sharedData.updateProgress = 0.92;
	sharedData.updateStage = 4;
	
	//Check if exists
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:sharedData.updateFirmwarePath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:sharedData.updateFirmwarePath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	if([sharedData.updateDependencies objectForKey:@"Multitouch"]) {
		success = [self dumpMultitouch];
		
		if(success < 0) {
			NSLog(@"Dumping of multitouch firmware returned: %d", success);
			sharedData.updateFail = 5;
			[self cleanUp];
			return;
		}
	}
	
	sharedData.updateProgress = 0.95;
	
	if([sharedData.updateDependencies objectForKey:@"WiFi"]) {
		success = [self dumpWiFi];
		
		if(success < 0) {
			NSLog(@"WiFi firmware retrieval returned: %d", success);
			sharedData.updateFail = 6;
			[self cleanUp];
			return;
		}
	}
	
	sharedData.updateProgress = 0.98;
	
	//Clean up
	[self cleanUp];
	
	//Set installed plist
	success = [self generateInstalledPlist];
	
	if(success < 0) {
		NSLog(@"Installed plist generation returned: %d", success);
		sharedData.updateFail = 7;
		[self cleanUp];
		return;
	}
	
	[self checkInstalled];
	
	sharedData.updateProgress = 1;
}

- (void)idroidRemove {
	int i, count;
	commonData* sharedData = [commonData sharedData];
	
	count = [sharedData.installedFiles count];
	
	for (i=0; i<count; i++) {
		[[NSFileManager defaultManager] removeItemAtPath:[sharedData.installedFiles objectAtIndex:i] error:nil];
	}
	
	count = [sharedData.installedDependencies count];
	
	for (i=0; i<count; i++) {
		[[NSFileManager defaultManager] removeItemAtPath:[sharedData.installedDependencies objectAtIndex:i] error:nil];
	}
	
	[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"] error:nil];
	
	sharedData.installedDate = nil;
	sharedData.installedVer = nil;
	sharedData.installedAndroidVer = nil;
	sharedData.installedFiles = nil;
	sharedData.installedDependencies = nil;
	sharedData.installed = NO;
	
	sharedData.updateProgress = 0;
	sharedData.updateStage = 0;
}

- (void)updateProgress:(NSNumber *)progress {
	commonData* sharedData = [commonData sharedData];
	if(sharedData.updateStage < 4) {
		sharedData.updateProgress = [progress floatValue];
	}
}

- (void)cleanUp {
	commonData* sharedData = [commonData sharedData];
	
	[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:sharedData.updateClean] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:@"idroid.tar"] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:sharedData.updatePackagePath error:nil];
}

- (void)checkForUpdates {
	int success;
	commonData* sharedData = [commonData sharedData];
	
	//Grab update plist	
	NSURL *updatePlistURL = [NSURL URLWithString:@"http://idroid.neonkoala.co.uk/bootlaceupdate.plist"];
	NSMutableDictionary *updateDict = [NSMutableDictionary dictionaryWithContentsOfURL:updatePlistURL];
	
	if(updateDict == nil) {
		sharedData.updateAvailable = NO;
		return;
	}
	
	sharedData.latestVerDict = [updateDict objectForKey:@"LatestVersion"];
	sharedData.upgradeDict = [updateDict objectForKey:@"Upgrade"];
	
	//Call func to parse plist
	success = [self parseUpdatePlist];
	
	if (success < 0) {
		NSLog(@"Update plist could not be parsed");
	}
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
			sharedData.installed = NO;
			[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"] error:nil];
			
			NSLog(@"Installed plist could not be parsed");
		}
	}
}

- (int)relocateFiles {
	int i, count;
	NSError *error;
	commonData* sharedData = [commonData sharedData];
	
	count = [sharedData.updateFiles count];
	
	NSLog(@"File items: %d", i);
	
	for (i=0; i<count; i++) {
		NSString *key = [NSString stringWithFormat:@"%d", i];
		NSArray *fileDetails = [sharedData.updateFiles objectForKey:key];
		
		NSString *sourcePath = [[sharedData.workingDirectory stringByAppendingPathComponent:[fileDetails objectAtIndex:0]] stringByAppendingPathComponent:[fileDetails objectAtIndex:2]];		
		NSString *destPath = [[fileDetails objectAtIndex:1] stringByAppendingPathComponent:[fileDetails objectAtIndex:2]];
		
		if([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
			if(![[NSFileManager defaultManager] removeItemAtPath:destPath error:&error]) {
				NSLog(@"%@", [error localizedDescription]);
			}
		}
		
		if(![[NSFileManager defaultManager] moveItemAtPath:sourcePath toPath:destPath error:&error]) {
			NSLog(@"%@", [error localizedDescription]);
			return -1;
		}
	}
	
	return 0;
}

- (int)dumpMultitouch {
	commonData* sharedData = [commonData sharedData];
	
	if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z2F52,1"]) {	
		if(![[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr2.bin"]]) {
			NSLog(@"Dumping zephyr2 multitouch.");
		
			NSString *match = @"share*";
			NSString *stashPath = @"/private/var/stash";
			
			NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/private/var/stash" error:nil];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
			NSArray *results = [dirContents filteredArrayUsingPredicate:predicate];
			
			stashPath = [stashPath stringByAppendingPathComponent:[results objectAtIndex:0]];
			NSDictionary *mtprops = [NSDictionary dictionaryWithContentsOfFile:[stashPath stringByAppendingPathComponent:@"firmware/multitouch/iPhone.mtprops"]];
			
			NSDictionary *z2dict = [mtprops objectForKey:@"Z2F52,1"];
			NSData *z2bin = [z2dict objectForKey:@"Constructed Firmware"];
		
			if(![z2bin writeToFile:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr2.bin"] atomically:YES]) {
				return -1;
			}
		}
	} else if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z1F50,1"]) {
		NSString *match = @"share*";
		NSString *stashPath = @"/private/var/stash";
		
		NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/private/var/stash" error:nil];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
		NSArray *results = [dirContents filteredArrayUsingPredicate:predicate];
		
		stashPath = [stashPath stringByAppendingPathComponent:[results objectAtIndex:0]];
		NSDictionary *mtprops = [NSDictionary dictionaryWithContentsOfFile:[stashPath stringByAppendingPathComponent:@"firmware/multitouch/iPhone.mtprops"]];
		
		NSDictionary *z1dict = [mtprops objectForKey:@"Z1F50,1"];
		
		if(![[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_main.bin"]]) {
			NSLog(@"Dumping zephyr main multitouch.");
			
			NSData *z1main = [z1dict objectForKey:@"Firmware"];
			
			if(![z1main writeToFile:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_main.bin"] atomically:YES]) {
				return -2;
			}
		}
		if(![[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_aspeed.bin"]]) {
			NSLog(@"Dumping zephyr aspeed multitouch.");
			
			NSData *z1aspeed = [z1dict objectForKey:@"A-Speed Firmware"];
			
			if(![z1aspeed writeToFile:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_aspeed.bin"] atomically:YES]) {
				return -3;
			}
		}			
	} else if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z2F51,1"]) {
		if(![[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr2.bin"]]) {
			NSLog(@"Dumping zephyr2 multitouch.");
			
			NSString *match = @"share*";
			NSString *stashPath = @"/private/var/stash";
			
			NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/private/var/stash" error:nil];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
			NSArray *results = [dirContents filteredArrayUsingPredicate:predicate];
			
			stashPath = [stashPath stringByAppendingPathComponent:[results objectAtIndex:0]];
			NSDictionary *mtprops = [NSDictionary dictionaryWithContentsOfFile:[stashPath stringByAppendingPathComponent:@"firmware/multitouch/iPod.mtprops"]];
			
			NSDictionary *z2dict = [mtprops objectForKey:@"Z2F51,1"];
			NSData *z2bin = [z2dict objectForKey:@"Constructed Firmware"];
			
			if(![z2bin writeToFile:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr2.bin"] atomically:YES]) {
				return -1;
			}
		}
	}
	
	return 0;
}

- (int)dumpWiFi {
	commonData* sharedData = [commonData sharedData];
	NSDictionary *wifiDict = [sharedData.updateDependencies objectForKey:@"WiFi"];
	int i;
	
	int count = [wifiDict count];
	
	NSLog(@"File items: %d", i);
	
	for (i=0; i<count; i++) {
		NSString *key = [NSString stringWithFormat:@"%d", i];
		NSArray *fileDetails = [wifiDict objectForKey:key];
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		//Download from URL
		getFileInstance = [[getFile alloc] initWithUrl:[fileDetails objectAtIndex:1] directory:sharedData.updateFirmwarePath];
		
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
		
		
	}
	
	
	return 0;
}



@end

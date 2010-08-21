//
//  installClass.m
//  BootlaceV2
//
//  Created by Neonkoala on 26/07/2010.
//  Copyright 2010 Nick Dawson. All rights reserved.
//

#import "installClass.h"


@implementation installClass

@synthesize commonInstance, extractionInstance;

- (int)parseUpdatePlist {
	DLog(@"Parsing Update Plist");

	commonData* sharedData = [commonData sharedData];
	
	//Check device match
	NSMutableDictionary* platformDict = [sharedData.latestVerDict objectForKey:sharedData.platform];
	if (platformDict==nil) {
		sharedData.updateAvailable = NO;
		DLog(@"  - No platform match! iDroid isn't available for this device.");
		return -1;
	} 
	
	sharedData.updateAvailable = YES;
	sharedData.updateVer = [platformDict objectForKey:@"iDroidVersion"];
	sharedData.updateAndroidVer = [platformDict objectForKey:@"AndroidVersion"];
	sharedData.updateDate = [platformDict objectForKey:@"ReleaseDate"];
	sharedData.updateURL = [platformDict objectForKey:@"URL"];
	sharedData.updateMD5 = [platformDict objectForKey:@"MD5"];
	sharedData.updateSize = [[platformDict objectForKey:@"Size"] intValue];
	sharedData.updateFiles = [platformDict objectForKey:@"Files"];
	sharedData.updateDependencies = [platformDict objectForKey:@"Dependencies"];
	sharedData.updateClean = [platformDict objectForKey:@"Clean"];
	
	sharedData.updateFirmwarePath = [sharedData.updateDependencies objectForKey:@"Directory"];
	
	return 0;
}

- (int)parseInstalledPlist {
	DLog(@"Parsing Installed Plist");

	commonData* sharedData = [commonData sharedData];
	
	NSString *installedPlistPath = [sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"];
	NSDictionary *installedDict = [NSDictionary dictionaryWithContentsOfFile:installedPlistPath];
	
	sharedData.installedVer = [installedDict objectForKey:@"iDroidVersion"];
	sharedData.installedAndroidVer = [installedDict objectForKey:@"AndroidVersion"];
	sharedData.installedDate = [installedDict objectForKey:@"InstalledDate"];
	sharedData.installedFiles = [installedDict objectForKey:@"Files"];
	sharedData.installedDependencies = [installedDict objectForKey:@"Dependencies"];
	
	if(sharedData.installedVer==nil || sharedData.installedAndroidVer==nil || sharedData.installedDate==nil || sharedData.installedFiles==nil || sharedData.installedDependencies==nil) {
		DLog(@"Plist is invalid, missing data values.");
		return -1;
	}
	
	return 0;
}

- (int)generateInstalledPlist {
	DLog(@"Generating Installed Plist");

	int i, count;
	commonData* sharedData = [commonData sharedData];
	NSMutableArray *installedDependencies;
	NSMutableDictionary *installedPlist = [NSMutableDictionary dictionaryWithCapacity:5];
	
	count = [sharedData.updateFiles count];
	NSMutableArray *installedFiles = [NSMutableArray arrayWithCapacity:count];
	
	for (i=0; i<count; i++) {
		NSString *key = [NSString stringWithFormat:@"%d", i];
		NSArray *fileDetails = [sharedData.updateFiles objectForKey:key];
		
		[installedFiles addObject:[[fileDetails objectAtIndex:1] stringByAppendingPathComponent:[fileDetails objectAtIndex:2]]];
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

		DLog(@"Zephyr2 multitouch location added.");
	} else if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z1F50,1"]) {
		[installedDependencies addObject:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_main.bin"]];
		[installedDependencies addObject:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_aspeed.bin"]];
		
		DLog(@"Zephyr1 multitouch location added.");
	}
	
	[installedPlist setObject:sharedData.updateVer forKey:@"iDroidVersion"];
	[installedPlist setObject:sharedData.updateAndroidVer forKey:@"AndroidVersion"];
	[installedPlist setObject:[NSDate date] forKey:@"InstalledDate"];
	[installedPlist setObject:installedFiles forKey:@"Files"];
	[installedPlist setObject:installedDependencies forKey:@"Dependencies"];
	
	if(![installedPlist writeToFile:[sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"] atomically:YES]) {
		DLog(@"Failed to write Installed Plist");
		return -1;
	}
	
	DLog(@"Installed Plist generated successfully.");

	return 0;
}

- (void)idroidInstall {
	commonData* sharedData = [commonData sharedData];
	extractionInstance = [[extractionClass alloc] init];
	int success;
	
	sharedData.updateFail = 0;
	sharedData.updateStage = 0;
	
	[self updateProgress:[NSNumber numberWithInt:0] nextStage:YES];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	getFileInstance = [[getFile alloc] initWithUrl:sharedData.updateURL directory:sharedData.workingDirectory];
	DLog(@"DEBUG: updateURL = %@", sharedData.updateURL);
	DLog(@"DEBUG: workingDirectory = %@", sharedData.workingDirectory);
	
	[getFileInstance getFileDownload:self];
	
	BOOL keepAlive = YES;
	
	do {        
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, YES);
        //Check NSURLConnection for activity
        if (getFileInstance.getFileWorking == NO) {
            keepAlive = NO;
        }
		if(sharedData.updateFail == 1) {
			DLog(@"DEBUG: Failed to get iDroid package. Cleaning up.");
			[self cleanUp];
			return;
		}
    } while (keepAlive);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	sharedData.updatePackagePath = getFileInstance.getFilePath;
	
	[self updateProgress:[NSNumber numberWithInt:0] nextStage:YES];
	
	//Calculate file MD5
	NSString *md5hash = [self fileMD5:sharedData.updatePackagePath];
	DLog(@"MD5 Hash: %@", md5hash);
	
	if(![sharedData.updateMD5 isEqualToString:md5hash]) {
		DLog(@"MD5 hash does not match, assuming download is corrupt.");
		sharedData.updateFail = 0;
		[self cleanUp];
		return;
	}
	
	[self updateProgress:[NSNumber numberWithInt:0] nextStage:YES];
	
	//Extract file
	NSString *tarDest = [sharedData.workingDirectory stringByAppendingPathComponent:@"idroid.tar"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tarDest];
	
	if(!fileExists) { 
		[[NSFileManager defaultManager] createFileAtPath:tarDest contents:nil attributes:nil];
	}
	
	success = [extractionInstance inflateGzip:sharedData.updatePackagePath toDest:tarDest];
	
	if(success < 0) {
		ALog(@"GZip extraction returned: %d", success);
		sharedData.updateFail = 2;
		[self cleanUp];
		return;
	}
	
	[self updateProgress:[NSNumber numberWithInt:0] nextStage:YES];
	
	success = [extractionInstance extractTar:tarDest toDest:sharedData.workingDirectory];
	
	if(success < 0) {
		ALog(@"Tar extraction returned: %d", success);
		sharedData.updateFail = 3;
		[self cleanUp];
		return;
	}
	
	//Extract files to correct locations
	[self updateProgress:[NSNumber numberWithInt:0] nextStage:YES];
	
	success = [self relocateFiles];
	
	if(success < 0) {
		ALog(@"File relocation returned: %d", success);
		sharedData.updateFail = 4;
		[self cleanUp];
		return;
	}
	
	//Check dependencies
	//Special multitouch routine
	
	[self updateProgress:[NSNumber numberWithFloat:0.25] nextStage:NO];
	
	//Check if exists
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:sharedData.updateFirmwarePath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:sharedData.updateFirmwarePath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	if([sharedData.updateDependencies objectForKey:@"Multitouch"]) {
		success = [self dumpMultitouch];
		
		if(success < 0) {
			ALog(@"Dumping of multitouch firmware returned: %d", success);
			sharedData.updateFail = 5;
			[self cleanUp];
			return;
		}
	}
	
	[self updateProgress:[NSNumber numberWithFloat:0.5] nextStage:NO];
	
	if([sharedData.updateDependencies objectForKey:@"WiFi"]) {
		success = [self dumpWiFi];
		
		if(success < 0) {
			ALog(@"WiFi firmware retrieval returned: %d", success);
			sharedData.updateFail = 6;
			[self cleanUp];
			return;
		}
	}
	
	[self updateProgress:[NSNumber numberWithFloat:0.75] nextStage:NO];
	
	//Check if SD card folder exists
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/sdcard"]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:@"/private/var/sdcard" withIntermediateDirectories:NO attributes:nil error:nil];
	}
	
	//Clean up
	[self cleanUp];
	
	//Set installed plist
	success = [self generateInstalledPlist];
	
	if(success < 0) {
		ALog(@"Installed plist generation returned: %d", success);
		sharedData.updateFail = 7;
		[self cleanUp];
		return;
	}
	
	[self checkInstalled];
	
	[self updateProgress:[NSNumber numberWithFloat:1] nextStage:YES];
}

- (void)idroidRemove {
	DLog(@"Removing iDroid");

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
}

- (void)updateProgress:(NSNumber *)progress nextStage:(BOOL)next {
	commonData* sharedData = [commonData sharedData];
	
	if(next) {
		sharedData.updateStage++;
		sharedData.updateCurrentProgress = 0;
		DLog(@"Current stage: %d", sharedData.updateStage);
	}
	
	sharedData.updateOverallProgress = ([progress floatValue]/5)+((sharedData.updateStage-1)*0.2);
	sharedData.updateCurrentProgress = [progress floatValue];
	
	DLog(@"Overall Progress: %f", sharedData.updateOverallProgress);
	DLog(@"Current Progress: %f", sharedData.updateCurrentProgress);
}

- (void)cleanUp {
	DLog(@"Cleaning up");

	commonData* sharedData = [commonData sharedData];
	
	[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:sharedData.updateClean] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:@"idroid.tar"] error:nil];
	if(sharedData.updatePackagePath) {
		[[NSFileManager defaultManager] removeItemAtPath:sharedData.updatePackagePath error:nil];
	}
	
	sharedData.updateOverallProgress = 0;
	sharedData.updateCurrentProgress = 0;
	sharedData.updateStage = 0;
	
	DLog(@"Cleanup complete.");
}

- (void)checkForUpdates {
	int success;
	commonData* sharedData = [commonData sharedData];
	
	//Grab update plist	
	NSURL *updatePlistURL = [NSURL URLWithString:@"http://files.neonkoala.co.uk/bootlaceupdate.plist"];
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
	
	DLog(@"%d", fileExists);
	
	if(!fileExists) { 
		sharedData.installed = NO;
	} else {
		sharedData.installed = YES;
		success = [self parseInstalledPlist];
		
		if(success<0) {
			sharedData.installed = NO;
			[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:@"installed.plist"] error:nil];
			
			ALog(@"Installed plist could not be parsed");
		}
	}
}

- (int)relocateFiles {
	int i, count;
	NSError *error;
	commonData* sharedData = [commonData sharedData];
	
	count = [sharedData.updateFiles count];
	
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
			DLog(@"Dumping zephyr2 multitouch.");
		
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
			DLog(@"Dumping zephyr main multitouch.");
			
			NSData *z1main = [z1dict objectForKey:@"Firmware"];
			
			if(![z1main writeToFile:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_main.bin"] atomically:YES]) {
				return -2;
			}
		}
		if(![[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_aspeed.bin"]]) {
			DLog(@"Dumping zephyr aspeed multitouch.");
			
			NSData *z1aspeed = [z1dict objectForKey:@"A-Speed Firmware"];
			
			if(![z1aspeed writeToFile:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_aspeed.bin"] atomically:YES]) {
				return -3;
			}
		}			
	} else if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z2F51,1"]) {
		if(![[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr2.bin"]]) {
			DLog(@"Dumping zephyr2 multitouch.");
			
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
	
	DLog(@"File items: %d", count);
	
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

- (NSString *)fileMD5:(NSString *)path {
	int read = 0;	
	NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	int fileSize = [attr fileSize];

	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
	if(handle==nil) {
		return @"NOFILE";
	}
	
	CC_MD5_CTX md5;
	CC_MD5_Init(&md5);
	
	BOOL done = NO;
	while(!done)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; //Create our own autorelease pool as the system is too slow to drain otherwise
		NSData *fileData = [handle readDataOfLength: 1048576];
		CC_MD5_Update(&md5, [fileData bytes], [fileData length]);
		if( [fileData length] == 0 ) done = YES;
		read += [fileData length];
		float progress = (float) read/fileSize;
		[self updateProgress:[NSNumber numberWithFloat:progress] nextStage:NO];
		[pool drain]; //Drain it or we'll run out of memory
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

@end

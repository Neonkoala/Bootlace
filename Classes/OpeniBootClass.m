//
//  OpeniBootClass.m
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "OpeniBootClass.h"


@implementation OpeniBootClass

@synthesize deviceDict, iBootPatches, LLBPatches, kernelPatches;

char endianness = 1;

- (int)opibParseUpdatePlist {
	commonData* sharedData = [commonData sharedData];
	DLog(@"Parsing OpeniBoot update plist");
	
	if(deviceDict == nil) {
		DLog(@"OpeniBoot plist invalid");
		return -1;
	}
	
	sharedData.opibUpdateBootlaceRequired = [deviceDict objectForKey:@"BootlaceRequired"];
	sharedData.opibUpdateReleaseDate = [deviceDict objectForKey:@"ReleaseDate"];
	sharedData.opibUpdateURL = [deviceDict objectForKey:@"URL"];
	sharedData.opibUpdateVersion = [deviceDict objectForKey:@"Version"];
	sharedData.opibUpdateFirmwarePath = [deviceDict objectForKey:@"FirmwarePath"];
	sharedData.opibUpdateCompatibleFirmware = [deviceDict objectForKey:@"CompatibleFirmware"];
	sharedData.opibUpdateIPSWURLs = [deviceDict objectForKey:@"IPSWURLs"];
	sharedData.opibUpdateKernelMD5 = [deviceDict objectForKey:@"KernelMD5"];
	sharedData.opibUpdateVerifyMD5 = [deviceDict objectForKey:@"VerifyMD5"];
	sharedData.opibUpdateManifest = [deviceDict objectForKey:@"Manifest"];
	
	return 0;
}

- (int)opibGetNORFromManifest {
	int i, items;
	unsigned char* data;
	commonData* sharedData = [commonData sharedData];
	
	NSLog(@"IPSWURLS: %@ Sys version: %@", sharedData.opibUpdateIPSWURLs, sharedData.systemVersion);
	
	DLog(@"Getting NOR files from Apple servers. IPSW: %@", [sharedData.opibUpdateIPSWURLs objectForKey:sharedData.systemVersion]);
	
	ZipInfo* info = PartialZipInit([[sharedData.opibUpdateIPSWURLs objectForKey:sharedData.systemVersion] cStringUsingEncoding:NSUTF8StringEncoding]);
	if(!info)
	{
		DLog(@"Cannot retrieve IPSW from: %@", [sharedData.opibUpdateIPSWURLs objectForKey:sharedData.systemVersion]);
		return -1;
	}
	
	items = [sharedData.opibUpdateManifest count];
	
	for(i=0; i<items; i++) {
		//Skip openiboot from manifest as Apple doesn't include it - gits
		if(i!=1) {
			NSString *itemPath = [sharedData.opibUpdateFirmwarePath stringByAppendingPathComponent:[sharedData.opibUpdateManifest objectAtIndex:i]];
			NSString *destPath = [sharedData.workingDirectory stringByAppendingPathComponent:[sharedData.opibUpdateManifest objectAtIndex:i]];
		
			DLog(@"Grabbing firmware at path: %@", itemPath);
	
			CDFile* file = PartialZipFindFile(info, [itemPath cStringUsingEncoding:NSUTF8StringEncoding]);
			if(!file)
			{
				DLog(@"Cannot find firmware.");
				return -2;
			}
		
			data = PartialZipGetFile(info, file);
			int dataLen = file->size; 
			
			NSLog(@"dataLen: %d", dataLen);
		
			NSData *itemBin = [NSData dataWithBytes:data length:dataLen];
	
			if([itemBin length]>0) {
				NSLog(@"Got NOR file %d", i);
			}
			
			if(![itemBin writeToFile:destPath atomically:YES]) {
				DLog(@"Could not write IMG3 to file.");
				return -3;
			}				
	
			free(data);
		}
	}
	
	PartialZipRelease(info);
	
	return 0;
}

- (int)opibFlashManifest {
	int i, items, success;
	mach_port_t masterPort;
	kern_return_t k_result;
	io_service_t norService;
	io_connect_t norServiceConnection;
	
	commonData* sharedData = [commonData sharedData];
	
	items = [sharedData.opibUpdateManifest count];
	
	if(items < 1) {
		DLog(@"Haha, thought you could trick me with an empty Manifest? Not this time bitch.");
		return -1;
	}
	
	k_result = IOMasterPort(MACH_PORT_NULL, &masterPort);
	if (k_result) {
		DLog(@"IOMasterPort failed: 0x%X\n", k_result);
		return -2;
	}
	NSLog(@"[OK] IOMasterPort opened");
	
	norService = [self opibGetIOService:@"AppleImage3NORAccess"];
	
	if (norService == 0) {
		DLog(@"opibGetIOService failed!");
		return -3;
	}
	NSLog(@"[OK] AppleImage3NORAccess found: 0x%x\n", norService);
	
	k_result = IOServiceOpen(norService, mach_task_self_, 0, &norServiceConnection);
	if (k_result != KERN_SUCCESS) {
		DLog(@"IOServiceOpen failed: 0x%X\n", k_result);
		return -4;		
	}
	NSLog(@"[OK] Connection opened at: 0x%x\n", norServiceConnection);
	
	//Check all files exist first
	for(i=0; i<items; i++) {
		NSString *img3Path = [sharedData.workingDirectory stringByAppendingPathComponent:[sharedData.opibUpdateManifest objectAtIndex:i]];
		
		if(![[NSFileManager defaultManager] fileExistsAtPath:img3Path]) {
			DLog(@"IMG3 doesn't exist at path %@! Aborting before flash!");
			return -5;
		}
	}
	
	//Lets flash them before that damn cat of mine eats them
	for(i=0; i<items; i++) {
		NSString *img3Path = [sharedData.workingDirectory stringByAppendingPathComponent:[sharedData.opibUpdateManifest objectAtIndex:i]];
		
		if(i==0) {
			success = [self opibFlashIMG3:img3Path usingService:norServiceConnection type:YES];
		} else {
			success = [self opibFlashIMG3:img3Path usingService:norServiceConnection type:NO];
		}
	}
	
	return 0;
}

- (int)opibFlashIMG3:(NSString *)path usingService:(io_connect_t)norServiceConnection type:(BOOL)isLLB {
	NSFileHandle *norHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	
	NSLog(@"Flashing %@ %@ image", path, (isLLB ? @"LLB" : @"NOR"));
	
	int fd = [norHandle fileDescriptor];
	size_t imgLen = lseek(fd, 0, SEEK_END);
	NSLog(@"Image length = %lu", imgLen);
	lseek(fd, 0, SEEK_SET);
	
	void *mappedImage = mmap(NULL, imgLen, PROT_READ | PROT_WRITE, MAP_ANON | VM_FLAGS_PURGABLE, -1, 0);
	if(mappedImage == MAP_FAILED) {
		int err = errno;
		NSLog(@"mmap (size = %ld) failed: %s", imgLen, strerror(err));
		return err;
	}
	
	int cbRead = read(fd, mappedImage, imgLen);
	if (cbRead != imgLen) {
		int err = errno;
		NSLog(@"cbRead(%u) != imgLen(%lu); err 0x%x", cbRead, imgLen, err);
		return err;
	}
	
	kern_return_t result = IOConnectCallStructMethod(norServiceConnection, isLLB ? 0 : 1, mappedImage, imgLen, NULL, 0);
	if(result != KERN_SUCCESS) {
		NSLog(@"IOConnectCallStructMethod failed: 0x%x\n", result);
	}
	
	munmap(mappedImage, imgLen);
	
	return result;
}

- (int)opibEncryptIMG3:(NSString *)srcPath to:(NSString *)dstPath with:(NSString *)templateIMG3 key:(NSString *)key iv:(NSString *)iv type:(BOOL)isLLB {
	//Sanity checks
	if(![[NSFileManager defaultManager] fileExistsAtPath:srcPath] || [[NSFileManager defaultManager] fileExistsAtPath:dstPath] || ![[NSFileManager defaultManager] fileExistsAtPath:templateIMG3]) {
		DLog(@"File missing and/or exists at destination/source. Aborting rather like your mother should have done before birth.");
		return -1;
	}
	if(!isLLB) {
		if([key length] == 0 || [iv length] == 0) {
			DLog(@"Seriously? That's gotta be an invalid key/iv. I didn't get off the last banana boat y'know...");
			return -2;
		}
	}
	
	//This is a very hacky workaround for Apple breaking NSTask waitUntilDone in 4.x - NSTask leaves zombies so never returns when done leaving us in limbo. Solution: back to basics, fork & exec
	
	pid_t pid;
	int rv;
	int	commpipe[2];
	
	pipe(commpipe);
	pid = fork();
	
	if(pid) {
		dup2(commpipe[1],1);
		close(commpipe[0]);
		
		setvbuf(stdout,(char*)NULL,_IONBF,0);
		
		wait(&rv);
	} else {
		dup2(commpipe[0],0);
		close(commpipe[1]);
		
		if(isLLB) {
			rv = execl("/usr/bin/xpwntool", "xpwntool", [srcPath cStringUsingEncoding:NSUTF8StringEncoding], [dstPath cStringUsingEncoding:NSUTF8StringEncoding], "-t", [templateIMG3 cStringUsingEncoding:NSUTF8StringEncoding], NULL);
		} else {
			rv = execl("/usr/bin/xpwntool", "xpwntool", [srcPath cStringUsingEncoding:NSUTF8StringEncoding], [dstPath cStringUsingEncoding:NSUTF8StringEncoding], "-t", [templateIMG3 cStringUsingEncoding:NSUTF8StringEncoding], "-k", [key cStringUsingEncoding:NSUTF8StringEncoding], "-iv", [iv cStringUsingEncoding:NSUTF8StringEncoding], NULL);
		}
	}
	
	if(rv!=0) {
		DLog(@"xpwntool returned: %d", rv);
		return -3;
	}
	
	return 0;
}

- (int)opibDecryptIMG3:(NSString *)srcPath to:(NSString *)dstPath key:(NSString *)key iv:(NSString *)iv type:(BOOL)isLLB {
	//Sanity checks	
	if(![[NSFileManager defaultManager] fileExistsAtPath:srcPath] || [[NSFileManager defaultManager] fileExistsAtPath:dstPath]) {
		DLog(@"File missing and/or exists at destination/source. Aborting rather like your mother should have done before birth.");
		return -1;
	}
	if(!isLLB) {
		if([key length] == 0 || [iv length] == 0) {
			DLog(@"Seriously? That's gotta be an invalid key/iv. I didn't get off the last banana boat y'know...");
			return -2;
		}
	}
	
	//This is a very hacky workaround for Apple breaking NSTask waitUntilDone in 4.x - NSTask leaves zombies so never returns when done leaving us in limbo. Solution: back to basics, fork & exec
	
	pid_t pid;
	int rv;
	int	commpipe[2];
	
	pipe(commpipe);
	pid = fork();
	
	if(pid) {
		dup2(commpipe[1],1);
		close(commpipe[0]);
		
		setvbuf(stdout,(char*)NULL,_IONBF,0);
		
		wait(&rv);
	} else {
		dup2(commpipe[0],0);
		close(commpipe[1]);
		
		if(isLLB) {
			rv = execl("/usr/sbin/xpwntool", "xpwntool", [srcPath cStringUsingEncoding:NSUTF8StringEncoding], [dstPath cStringUsingEncoding:NSUTF8StringEncoding], NULL);
		} else {
			rv = execl("/usr/sbin/xpwntool", "xpwntool", [srcPath cStringUsingEncoding:NSUTF8StringEncoding], [dstPath cStringUsingEncoding:NSUTF8StringEncoding], "-k", [key cStringUsingEncoding:NSUTF8StringEncoding], "-iv", [iv cStringUsingEncoding:NSUTF8StringEncoding], NULL);
		}
	}
	
	if(rv!=0) {
		DLog(@"xpwntool returned: %d", rv);
		return -3;
	}
	
	return 0;
}

- (int)opibPatchNORFiles {
	int status;
	bsPatchInstance = [[BSPatch alloc] init];
	commonData* sharedData = [commonData sharedData];
	
	//Let's do LLB first
	NSString *llbPath = [sharedData.workingDirectory stringByAppendingPathComponent:[LLBPatches objectForKey:@"File"]];
	NSString *llbPatchPath = [sharedData.workingDirectory stringByAppendingPathComponent:[LLBPatches objectForKey:@"Patch"]];
	status = [self opibDecryptIMG3:llbPath to:[llbPath stringByAppendingPathExtension:@"decrypted"] key:nil iv:nil type:YES];
	
	if(status < 0) {
		DLog(@"opibDecryptIMG3 returned %d on LLB", status);
		return -1;
	}
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[llbPath stringByAppendingPathExtension:@"decrypted"]]) {
		status = [bsPatchInstance bsPatch:[llbPath stringByAppendingPathExtension:@"decrypted"] withPatch:llbPatchPath];
	} else {
		DLog(@"Decrypted LLB does not exist! Time to crap ourselves complaining..");
		return -2;
	}
	
	status = [self opibEncryptIMG3:[llbPath stringByAppendingPathExtension:@"decrypted.patched"] to:[llbPath stringByAppendingPathExtension:@"encrypted"] with:llbPath key:nil iv:nil type:YES];
		
	if(status < 0) {
		DLog("opibEncryptIMG3 returned %d on LLB", status);
		return -3;
	}
	
	NSString *iBootPath = [sharedData.workingDirectory stringByAppendingPathComponent:[iBootPatches objectForKey:@"File"]];
	NSString *iBootPatchPath = [sharedData.workingDirectory stringByAppendingPathComponent:[iBootPatches objectForKey:@"Patch"]];
	status = [self opibDecryptIMG3:iBootPath to:[iBootPath stringByAppendingPathExtension:@"decrypted"] key:[iBootPatches objectForKey:@"Key"] iv:[iBootPatches objectForKey:@"IV"] type:NO];
	
	if(status < 0) {
		DLog(@"opibDecryptIMG3 returned %d on iBoot", status);
		return -4;
	}
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[iBootPath stringByAppendingPathExtension:@"decrypted"]]) {
		status = [bsPatchInstance bsPatch:[iBootPath stringByAppendingPathExtension:@"decrypted"] withPatch:iBootPatchPath];
	} else {
		DLog(@"Decrypted iBoot does not exist! Time to crap ourselves complaining..");
		return -5;
	}
	
	status = [self opibEncryptIMG3:[iBootPath stringByAppendingPathExtension:@"decrypted.patched"] to:[iBootPath stringByAppendingPathExtension:@"encrypted"] with:iBootPath key:nil iv:nil type:YES];
	
	if(status < 0) {
		DLog("opibEncryptIMG3 returned %d on iBoot", status);
		return -6;
	}
	
	return 0;
}

- (int)opibPatchKernelCache {
	int i;
	commonData* sharedData = [commonData sharedData];
	commonInstance = [[commonFunctions alloc] init];
	
	NSString *kernelMD5 = [commonInstance fileMD5:@"/System/Library/Caches/com.apple.kernelcaches/kernelcache"];
	
	int MD5s = [[sharedData.opibUpdateKernelMD5 objectForKey:sharedData.systemVersion] count];
	for(i=0; i<MD5s; i++) {
		if([kernelMD5 isEqualToString:[[sharedData.opibUpdateKernelMD5 objectForKey:sharedData.systemVersion] objectAtIndex:i]]) {
			break;
		} else if(i==(MD5s-1)) {
			DLog(@"No MD5 matches found, aborting...");
			return -1;
		}
	}
	
	return 0;
}

- (int)opibGetFirmwareBundle {
	commonData* sharedData = [commonData sharedData];
	
	NSString *bundleURL = @"http://beta.neonkoala.co.uk/iPhone1,2_4.0_8A293.bundle";
	
	DLog(@"Grabbing firmware bundle %@", bundleURL);
	
	NSDictionary *bundleInfo = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:[bundleURL stringByAppendingPathComponent:@"Info.plist"]]];
	if([bundleInfo count] < 1) {
		return -1;
	}
	
	NSDictionary *firmwarePatches = [bundleInfo objectForKey:@"FirmwarePatches"];
	
	LLBPatches = [firmwarePatches objectForKey:@"LLB"];
	iBootPatches = [firmwarePatches objectForKey:@"iBoot"];
	kernelPatches = [firmwarePatches objectForKey:@"KernelCache"];
	
	//Get files
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	getFileInstance = [[getFile alloc] initWithUrl:[bundleURL stringByAppendingPathComponent:[LLBPatches objectForKey:@"Patch"]] directory:sharedData.workingDirectory];
	
	[getFileInstance getFileDownload:self];
	
	BOOL keepAlive = YES;
	
	do {        
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, YES);
		//Check NSURLConnection for activity
		if (getFileInstance.getFileWorking == NO) {
			keepAlive = NO;
		}
		if(sharedData.updateFail == 1) {
			DLog(@"DEBUG: Failed to get LLB patch. Cleaning up.");
			return -2;
		}
	} while (keepAlive);
	
	[getFileInstance release];
	
	getFileInstance = [[getFile alloc] initWithUrl:[bundleURL stringByAppendingPathComponent:[iBootPatches objectForKey:@"Patch"]] directory:sharedData.workingDirectory];
	
	[getFileInstance getFileDownload:self];
	
	keepAlive = YES;
	
	do {        
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, YES);
		//Check NSURLConnection for activity
		if (getFileInstance.getFileWorking == NO) {
			keepAlive = NO;
		}
		if(sharedData.updateFail == 1) {
			DLog(@"DEBUG: Failed to get iBoot patch. Cleaning up.");
			return -3;
		}
	} while (keepAlive);
	
	[getFileInstance release];
	
	getFileInstance = [[getFile alloc] initWithUrl:[bundleURL stringByAppendingPathComponent:[kernelPatches objectForKey:@"Patch"]] directory:sharedData.workingDirectory];
	
	[getFileInstance getFileDownload:self];
	
	keepAlive = YES;
	
	do {        
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, YES);
		//Check NSURLConnection for activity
		if (getFileInstance.getFileWorking == NO) {
			keepAlive = NO;
		}
		if(sharedData.updateFail == 1) {
			DLog(@"DEBUG: Failed to get KernelCache patch. Cleaning up.");
			return -4;
		}
	} while (keepAlive);
	
	[getFileInstance release];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSLog(@"fwbundle info.plist: %@", bundleInfo);
	
	return 0;
}

- (io_service_t)opibGetIOService:(NSString *)name {
	CFMutableDictionaryRef matching;
	io_service_t service;
	
	matching = IOServiceMatching([name cStringUsingEncoding:NSUTF8StringEncoding]);
	if(matching == NULL) {
		DLog(@"Unable to create matching dictionary for class '%@'", name);
		return 0;
	}
	
	do {
		CFRetain(matching);
		service = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
		if(service) {
			break;
		}
		
		DLog(@"Waiting for matching IOKit service: %@", name);
		sleep(1);
		CFRelease(matching);
	} while(!service);
	
	CFRelease(matching);

	return service;
}	

- (void)opibCheckForUpdates {
	int success;
	commonData* sharedData = [commonData sharedData];
	
	sharedData.opibCanBeInstalled = 0;
	
	DLog(@"Checking for OpeniBoot updates");
	
	NSURL *opibUpdatePlistURL;
	
	//Grab update plist	
	if(sharedData.debugMode) {
		//opibUpdatePlistURL = [NSURL URLWithString:@"http://beta.neonkoala.co.uk/openiboot.plist"];
		opibUpdatePlistURL = [NSURL URLWithString:@"http://192.168.0.16/~neonkoala/openiboot.plist"];
	} else {
		opibUpdatePlistURL = [NSURL URLWithString:@"http://idroid.neonkoala.co.uk/openiboot.plist"];
	}
	sharedData.opibDict = [NSMutableDictionary dictionaryWithContentsOfURL:opibUpdatePlistURL];
	
	if(sharedData.opibDict == nil) {
		sharedData.updateCanBeInstalled = -1;
		DLog(@"Could not retrieve openiboot update plist - server problem?");
		return;
	}
	
	deviceDict = [sharedData.opibDict objectForKey:sharedData.platform];
	
	//Call func to parse plist
	success = [self opibParseUpdatePlist];
	
	if(success < 0) {
		DLog(@"Update plist could not be parsed");
		sharedData.opibCanBeInstalled = -2;
	}
	
	if(sharedData.opibInstalled) {
		if([sharedData.opibUpdateVersion compare:sharedData.opibVersion options:NSNumericSearch] == NSOrderedDescending) {
			sharedData.opibCanBeInstalled = 1;
		} else if([sharedData.opibUpdateVersion isEqualToString:sharedData.opibVersion]) {
			sharedData.opibCanBeInstalled = 2;
		}
	}
}

@end

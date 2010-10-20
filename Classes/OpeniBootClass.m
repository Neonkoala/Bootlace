//
//  OpeniBootClass.m
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "OpeniBootClass.h"


@implementation OpeniBootClass

@synthesize llbPath, iBootPath, openibootPath, deviceDict, iBootPatches, LLBPatches, kernelPatches;

char endianness = 1;

- (void)opibInstall {
	int status;
	commonData* sharedData = [commonData sharedData];
	
	//Reset vars
	sharedData.opibUpdateFail = 0;
	sharedData.opibUpdateStage = 0;
	sharedData.updateOverallProgress = 0;
	
	//Stage 1
	sharedData.opibUpdateStage = 1;
	
	status = [self opibGetNORFromManifest];
	
	if(status < 0) {
		DLog(@"opibGetNORFromManifest returned: %d", status);
		sharedData.opibUpdateFail = 1;
		return;
	}
	
	status = [self opibGetFirmwareBundle];
	
	if(status < 0) {
		DLog(@"opibGetFirmwareBundle returned: %d", status);
		sharedData.opibUpdateFail = 2;
		return;
	}
	
	//Stage 2
	sharedData.opibUpdateStage = 2;
	
	status = [self opibPatchNORFiles:YES];
	
	if(status < 0) {
		DLog(@"opibPatchNORFiles returned: %d", status);
		sharedData.opibUpdateFail = 3;
		return;
	}
	
	//Stage 3
	sharedData.opibUpdateStage = 3;
	
	status = [self opibGetOpeniBoot];
	
	if(status < 0) {
		DLog(@"opibGetOpeniBoot returned: %d", status);
		sharedData.opibUpdateFail = 4;
		return;
	}
	
	[self opibUpdateProgress:0.33];
	
	status = [self opibEncryptIMG3:openibootPath to:[sharedData.workingDirectory stringByAppendingPathComponent:@"openiboot.img3"] with:iBootPath key:[iBootPatches objectForKey:@"Key"] iv:[iBootPatches objectForKey:@"IV"] type:NO];
	
	if(status < 0) {
		DLog(@"opibEncryptIMG3 returned: %d", status);
		sharedData.opibUpdateFail = 5;
		return;
	}
	
	[self opibUpdateProgress:0.66];
	
	//Remove orig iBoot
	if(![[NSFileManager defaultManager] removeItemAtPath:iBootPath error:nil] || ![[NSFileManager defaultManager] removeItemAtPath:llbPath error:nil]) {
		DLog(@"Could not remove vanilla iBoot/LLB ready for replacement");
		sharedData.opibUpdateFail = 6;
		return;
	}
	
	if(![[NSFileManager defaultManager] moveItemAtPath:[iBootPath stringByAppendingPathExtension:@"encrypted"] toPath:iBootPath error:nil] || ![[NSFileManager defaultManager] moveItemAtPath:[llbPath stringByAppendingPathExtension:@"encrypted"] toPath:llbPath error:nil]) {
		DLog(@"Could not move files to original filename");
		sharedData.opibUpdateFail = 7;
		return;
	}
	
	[self opibUpdateProgress:1];
	
	//Stage 4
	sharedData.opibUpdateStage = 4;
	/*
	status = [self opibFlashManifest];
	 
	if(status < 0) {
		DLog(@"opibFlashManifest returned: %d", status);
		sharedData.opibUpdateFail = 8;
		return;
	}*/
	
	[self opibCleanUp];
}

- (void)opibUninstall {
	
}

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
	float progress;
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
			
			progress = (float)(i+1)/items;
			[self opibUpdateProgress:progress];
	
			free(data);
		}
	}
	
	PartialZipRelease(info);
	
	return 0;
}

- (int)opibFlashManifest {
	int i, items, success;
	float progress;
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
	
	norService = [self opibGetIOService:@"AppleImage3NORAccess"];
	
	if (norService == 0) {
		DLog(@"opibGetIOService failed!");
		return -3;
	}
	
	k_result = IOServiceOpen(norService, mach_task_self_, 0, &norServiceConnection);
	if (k_result != KERN_SUCCESS) {
		DLog(@"IOServiceOpen failed: 0x%X\n", k_result);
		return -4;		
	}
	
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
		
		if(success < 0) {
			DLog(@"Flashing IMG3 failed with: %d", success);
			return -6;
		}
		
		progress = (float)(i+1)/items;
		[self opibUpdateProgress:progress];
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
			rv = execl("/usr/bin/xpwntool", "xpwntool", [srcPath cStringUsingEncoding:NSUTF8StringEncoding], [dstPath cStringUsingEncoding:NSUTF8StringEncoding], NULL);
		} else {
			rv = execl("/usr/bin/xpwntool", "xpwntool", [srcPath cStringUsingEncoding:NSUTF8StringEncoding], [dstPath cStringUsingEncoding:NSUTF8StringEncoding], "-k", [key cStringUsingEncoding:NSUTF8StringEncoding], "-iv", [iv cStringUsingEncoding:NSUTF8StringEncoding], NULL);
		}
	}
	
	if(rv!=0) {
		DLog(@"xpwntool returned: %d", rv);
		return -3;
	}
	
	return 0;
}

- (int)opibPatchNORFiles:(BOOL)withIbox {
	int status;
	bsPatchInstance = [[BSPatch alloc] init];
	commonData* sharedData = [commonData sharedData];
	
	//Let's do LLB first
	llbPath = [sharedData.workingDirectory stringByAppendingPathComponent:[LLBPatches objectForKey:@"File"]];
	NSString *llbPatchPath = [sharedData.workingDirectory stringByAppendingPathComponent:[LLBPatches objectForKey:@"Patch"]];
	status = [self opibDecryptIMG3:llbPath to:[llbPath stringByAppendingPathExtension:@"decrypted"] key:nil iv:nil type:YES];
	
	if(status < 0) {
		DLog(@"opibDecryptIMG3 returned %d on LLB", status);
		return -1;
	}
	
	[self opibUpdateProgress:0.14];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[llbPath stringByAppendingPathExtension:@"decrypted"]]) {
		status = [bsPatchInstance bsPatch:[llbPath stringByAppendingPathExtension:@"decrypted"] withPatch:llbPatchPath];
		if(status < 0) {
			DLog(@"Patching LLB failed with: %d", status);
			return -2;
		}
	} else {
		DLog(@"Decrypted LLB does not exist! Time to crap ourselves complaining..");
		return -3;
	}
	
	[self opibUpdateProgress:0.28];
	
	status = [self opibEncryptIMG3:[llbPath stringByAppendingPathExtension:@"decrypted.patched"] to:[llbPath stringByAppendingPathExtension:@"encrypted"] with:llbPath key:nil iv:nil type:YES];
		
	if(status < 0) {
		DLog("opibEncryptIMG3 returned %d on LLB", status);
		return -4;
	}
	
	[self opibUpdateProgress:0.42];
	
	iBootPath = [sharedData.workingDirectory stringByAppendingPathComponent:[iBootPatches objectForKey:@"File"]];
	NSString *iBootPatchPath = [sharedData.workingDirectory stringByAppendingPathComponent:[iBootPatches objectForKey:@"Patch"]];
	status = [self opibDecryptIMG3:iBootPath to:[iBootPath stringByAppendingPathExtension:@"decrypted"] key:[iBootPatches objectForKey:@"Key"] iv:[iBootPatches objectForKey:@"IV"] type:NO];
	
	if(status < 0) {
		DLog(@"opibDecryptIMG3 returned %d on iBoot", status);
		return -5;
	}
	
	[self opibUpdateProgress:0.56];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:[iBootPath stringByAppendingPathExtension:@"decrypted"]]) {
		status = [bsPatchInstance bsPatch:[iBootPath stringByAppendingPathExtension:@"decrypted"] withPatch:iBootPatchPath];
		if(status < 0) {
			DLog(@"Patching iBoot failed with: %d", status);
			return -6;
		}
	} else {
		DLog(@"Decrypted iBoot does not exist! Time to crap ourselves complaining..");
		return -7;
	}
	
	[self opibUpdateProgress:0.7];
	
	status = [self opibEncryptIMG3:[iBootPath stringByAppendingPathExtension:@"decrypted.patched"] to:[iBootPath stringByAppendingPathExtension:@"encrypted"] with:iBootPath key:nil iv:nil type:YES];
	
	if(status < 0) {
		DLog(@"opibEncryptIMG3 returned %d on iBoot", status);
		return -8;
	}
	
	[self opibUpdateProgress:0.84];
	
	//Patch iBoot to ibox or we haz conflicts
	if(withIbox) {
		status = [self opibPatchIbox:[iBootPath stringByAppendingPathExtension:@"encrypted"]];
	
		if(status < 0) {
			DLog(@"Failed to patch iBoot to ibox");
			sharedData.opibUpdateFail = -4;
			return -9;
		}
	}
	
	[self opibUpdateProgress:1];
	
	return 0;
}

- (int)opibPatchIbox:(NSString *)path {
	NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
	
	if(!handle) {
		DLog(@"Could not open file at %@ for writing.", path);
		return -1;
	}
	
	[handle seekToFileOffset:16];
	[handle writeData:[NSData dataWithBytes:"xobi" length:4]];
	
	[handle closeFile]; 
	
	return 0;
}

- (int)opibPatchKernelCache {
	int i;
	commonData* sharedData = [commonData sharedData];
	commonInstance = [[commonFunctions alloc] init];
	
	//Let's learn about the environment kiddies
	[commonInstance getPlatform];
	[commonInstance getSystemVersion];
	
	//Pre-flight checks
	NSDictionary *kernelPatchesDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"KernelPatches" ofType:@"plist"]];
	
	NSLog(@"KernelPatches: %@", kernelPatchesDict);
	
	NSDictionary *platformDict = [kernelPatchesDict objectForKey:sharedData.platform];
	
	if([platformDict count] < 1) {
		NSLog(@"Device unsupported.");
		return -1;
	}
	
	NSDictionary *kernelPatchBundles = [platformDict objectForKey:@"KernelPatches"];
	NSDictionary *kernelCompatibleMD5s = [platformDict objectForKey:@"KernelMD5"];
	
	NSString *bundleName = [kernelPatchBundles objectForKey:sharedData.systemVersion];
	
	if([bundleName length] == 0) {
		NSLog(@"Firmware version %@ unsupported.", sharedData.systemVersion);
		return -2;
	}
	
	NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"KernelPatches"];
	bundlePath = [bundlePath stringByAppendingPathComponent:bundleName];
	
	NSDictionary *kernelPatchBundleDict = [NSDictionary dictionaryWithContentsOfFile:[bundlePath stringByAppendingPathComponent:@"Info.plist"]];
	
	NSString *kernelMD5 = [commonInstance fileMD5:[kernelPatchBundleDict objectForKey:@"Path"]];
	
	int MD5s = [[kernelCompatibleMD5s objectForKey:sharedData.systemVersion] count];
	for(i=0; i<MD5s; i++) {
		if([kernelMD5 isEqualToString:[[kernelCompatibleMD5s objectForKey:sharedData.systemVersion] objectAtIndex:i]]) {
			break;
		} else if(i==(MD5s-1)) {
			NSLog(@"No MD5 matches found, aborting...");
			return -3;
		}
	}
	
	return 0;
}

- (int)opibGetFirmwareBundle {
	commonData* sharedData = [commonData sharedData];
	
	NSString *bundleURL = [sharedData.opibUpdateCompatibleFirmware objectForKey:sharedData.systemVersion];
	
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

- (int)opibGetOpeniBoot {
	commonData* sharedData = [commonData sharedData];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	getFileInstance = [[getFile alloc] initWithUrl:sharedData.opibUpdateURL directory:sharedData.workingDirectory];
	
	[getFileInstance getFileDownload:self];
	
	BOOL keepAlive = YES;
	
	do {        
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0, YES);
		//Check NSURLConnection for activity
		if (getFileInstance.getFileWorking == NO) {
			keepAlive = NO;
		}
		if(sharedData.updateFail == 1) {
			DLog(@"DEBUG: Failed to get OpeniBoot. Cleaning up.");
			return -1;
		}
	} while (keepAlive);
	
	openibootPath = getFileInstance.getFilePath;
	
	[getFileInstance release];
	
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
		opibUpdatePlistURL = [NSURL URLWithString:@"http://beta.neonkoala.co.uk/openiboot.plist"];
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

- (void)opibUpdateProgress:(float)subProgress {
	commonData* sharedData = [commonData sharedData];
	
	sharedData.updateOverallProgress = (subProgress/4) + ((sharedData.opibUpdateStage-1) * 0.25);
}

- (void)opibCleanUp {
	int i, items;
	commonData* sharedData = [commonData sharedData];
	
	//Remove patched/decrypted LLB & iBoot
	[[NSFileManager defaultManager] removeItemAtPath:[iBootPath stringByAppendingPathExtension:@"decrypted"] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[iBootPath stringByAppendingPathExtension:@"decrypted.patched"] error:nil];
	
	[[NSFileManager defaultManager] removeItemAtPath:[llbPath stringByAppendingPathExtension:@"decrypted"] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[llbPath stringByAppendingPathExtension:@"decrypted.patched"] error:nil];
	
	//Remove raw openiboot
	[[NSFileManager defaultManager] removeItemAtPath:openibootPath error:nil];
	
	//Remove nor files
	items = [sharedData.opibUpdateManifest count];
	
	for(i=0; i<items; i++) {
		[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:[sharedData.opibUpdateManifest objectAtIndex:i]] error:nil];
	}
	
	//Remove patches
	[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:[LLBPatches objectForKey:@"Patch"]] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[sharedData.workingDirectory stringByAppendingPathComponent:[iBootPatches objectForKey:@"Patch"]] error:nil];
	
	return;
}

@end

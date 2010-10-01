//
//  OpeniBootClass.m
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "OpeniBootClass.h"


@implementation OpeniBootClass

@synthesize deviceDict;

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
	sharedData.opibUpdateManifest = [deviceDict objectForKey:@"Manifest"];
	
	return 0;
}

- (int)opibGetNORFromManifest {
	int i, items;
	unsigned char* data;
	commonData* sharedData = [commonData sharedData];
	
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

- (int)opibPatchManifest {
	commonData* sharedData = [commonData sharedData];
	bsPatchInstance = [[BSPatch alloc] init];
	
	[bsPatchInstance bsPatch:[sharedData.workingDirectory stringByAppendingPathComponent:@"kernelcache"] withPatch:[sharedData.workingDirectory stringByAppendingPathComponent:@"kernelcache.patch"]];
	 
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
			success = [self opibFlashIMG3:img3Path usingService:norService type:YES];
		} else {
			success = [self opibFlashIMG3:img3Path usingService:norService type:NO];
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
	
	kern_return_t result;
	if((result = IOConnectCallStructMethod(norServiceConnection, isLLB ? 0 : 1, mappedImage, imgLen, NULL, 0)) != KERN_SUCCESS) {
		NSLog(@"IOConnectCallStructMethod failed: 0x%x\n", result);
	}
	
	munmap(mappedImage, imgLen);
	
	return result;
}

- (io_service_t)opibGetIOService:(NSString *)name {
	CFMutableDictionaryRef matching;
	io_service_t service;
	
	matching = IOServiceMatching([name cStringUsingEncoding:NSUTF8StringEncoding]);
	if(matching == NULL) {
		DLog(@"Unable to create matching dictionary for class '%@'", name);
		return 0;
	}
	
	while(!service) {
		CFRetain(matching);
		service = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
		if(service) {
			break;
		}
		
		DLog(@"Waiting for matching IOKit service: %@", name);
		sleep(1);
		CFRelease(matching);
	}
	
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
	NSMutableDictionary *updateDict = [NSMutableDictionary dictionaryWithContentsOfURL:opibUpdatePlistURL];
	
	if(updateDict == nil) {
		sharedData.updateCanBeInstalled = -1;
		DLog(@"Could not retrieve openiboot update plist - server problem?");
		return;
	}
	
	deviceDict = [updateDict objectForKey:sharedData.platform];
	
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

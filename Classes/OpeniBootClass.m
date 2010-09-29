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
		
			DLog(@"Grabbing firmware at path: %@", itemPath);
	
			CDFile* file = PartialZipFindFile(info, [itemPath cStringUsingEncoding:NSUTF8StringEncoding]);
			if(!file)
			{
				DLog(@"Cannot find firmware.");
				return -2;
			}
		
			data = PartialZipGetFile(info, file);
			int dataLen = file->size; 
		
			NSData *itemBin = [NSData dataWithBytes:data length:dataLen];
	
			if([itemBin length]>0) {
				NSLog(@"Got NOR file %d", i);
			}
	
			free(data);
		}
	}
	
	PartialZipRelease(info);
	
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
}

@end

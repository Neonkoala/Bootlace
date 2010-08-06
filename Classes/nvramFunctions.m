//
//  nvramFunctions.m
//  Bootlace
//
//  Created by Neonkoala on 15/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "nvramFunctions.h"


@implementation nvramFunctions

- (int)dumpNVRAM:(NSString *)filePath {
	kern_return_t   kr;
	io_iterator_t   io_objects;
	io_service_t    io_service;
	
	//CFMutableDictionaryRef child_props;
	CFMutableDictionaryRef service_properties;
	
	kr = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IODTNVRAM"), &io_objects);
	
	if(kr != KERN_SUCCESS)
		return -1;
	
	while((io_service= IOIteratorNext(io_objects)))
	{
		kr = IORegistryEntryCreateCFProperties(io_service, &service_properties, kCFAllocatorDefault, kNilOptions);
		if(kr == KERN_SUCCESS)
		{
			NSDictionary *nvramDict = (NSDictionary *)service_properties;
			NSLog(@"%@", nvramDict);

			if(![nvramDict writeToFile:filePath atomically:YES]) {
				return -2;
			}
			
			CFRelease(service_properties);
		}
		
		IOObjectRelease(io_service);
	}
	
	IOObjectRelease(io_objects);
	
	return 0;
}

- (int)updateNVRAM:(NSString *)filePath {
	kern_return_t   kr;
	io_iterator_t   io_objects;
	io_service_t    io_service;
	
	//CFMutableDictionaryRef child_props;
	CFMutableDictionaryRef service_properties;
	
	kr = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IODTNVRAM"), &io_objects);
	
	if(kr != KERN_SUCCESS)
		return -1;
	
	while((io_service= IOIteratorNext(io_objects)))
	{
		kr = IORegistryEntryCreateCFProperties(io_service, &service_properties, kCFAllocatorDefault, kNilOptions);
		if(kr == KERN_SUCCESS)
		{
			NSMutableDictionary *nvramDict = (NSMutableDictionary *)service_properties;
			NSLog(@"%@", nvramDict);
			
			NSDictionary *updateDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
			
			[nvramDict setDictionary:updateDict];
			
			IORegistryEntrySetCFProperties(io_service, service_properties);
			
			CFRelease(service_properties);
		}
		
		IOObjectRelease(io_service);
	}
	
	IOObjectRelease(io_objects);
	
	return 0;
}

- (int)parseNVRAM:(NSString *)filePath {
	NSString *opibCompatibleVersion = @"0.1";
	NSString *opibTempOSVersion = @"0.1.1";
	commonData* sharedData = [commonData sharedData];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	if(!fileExists) {
		return -1;
	}
	
	NSMutableDictionary *nvramDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
	
	if (![nvramDict objectForKey:@"platform-uuid"]) {
		NSLog(@"Failed to get UUID.");
		return -2;
	}
	if (![nvramDict objectForKey:@"opib-version"]) {													//Check openiboot is installed before we go any further
		NSLog(@"Failed to get opib-version.");
		return -3;
	}
	if (![nvramDict objectForKey:@"opib-menu-timeout"] || ![nvramDict objectForKey:@"opib-default-os"]) {
		return -4;
	}
	
	NSData *rawVersion = [nvramDict objectForKey:@"opib-version"];
	sharedData.opibVersion = [NSString stringWithCString:[rawVersion bytes] encoding:NSUTF8StringEncoding];
	NSData *rawTimeout = [nvramDict objectForKey:@"opib-menu-timeout"];
	sharedData.opibTimeout = [NSString stringWithCString:[rawTimeout bytes] encoding:NSUTF8StringEncoding];
	NSData *rawDefaultOS = [nvramDict objectForKey:@"opib-default-os"];
	sharedData.opibDefaultOS = [NSString stringWithCString:[rawDefaultOS bytes] encoding:NSUTF8StringEncoding];
	
	if([opibCompatibleVersion compare:sharedData.opibVersion options:NSNumericSearch] == NSOrderedDescending) {
		return -3;
	} else if([opibTempOSVersion compare:sharedData.opibVersion options:NSNumericSearch] == NSOrderedDescending) {
		sharedData.opibTempOSDisabled = 1;
	} else {
		NSData *rawTempOS = [nvramDict objectForKey:@"opib-temp-os"];
		sharedData.opibTempOS = [NSString stringWithCString:[rawTempOS bytes] encoding:NSUTF8StringEncoding];
	}
	
	return 0;
}

- (int)generateNVRAM:(NSString *)filePath withMode:(int)mode {
	commonData* sharedData = [commonData sharedData];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	if(!fileExists) {
		return -1;
	}
	
	NSMutableDictionary* nvramDict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
	
	if(mode==0) {
		NSData *rawTimeout = [sharedData.opibTimeout dataUsingEncoding:NSUTF8StringEncoding];				//Convert utf8 into raw binary
		NSData *rawDefaultOS = [sharedData.opibDefaultOS dataUsingEncoding:NSUTF8StringEncoding];
		NSData *rawTempOS = [sharedData.opibTempOS dataUsingEncoding:NSUTF8StringEncoding];
		if (rawTimeout!=nil && rawDefaultOS!=nil) {															//Check for data
			[nvramDict setObject:rawTimeout forKey:@"opib-menu-timeout"];
			[nvramDict setObject:rawDefaultOS forKey:@"opib-default-os"];
			[nvramDict setObject:rawTempOS forKey:@"opib-temp-os"];
		} else {
			return -2;
		}
	} else {
		NSData *rawTempOS = [sharedData.opibTempOS dataUsingEncoding:NSUTF8StringEncoding];
		if (rawTempOS!=nil) {																				//Check for data
			[nvramDict setObject:rawTempOS forKey:@"opib-temp-os"];
		} else {
			return -2;
		}
	}	
		
	if([[NSFileManager defaultManager] removeItemAtPath:filePath error: NULL]  == YES) {					//Remove old plist
		[nvramDict writeToFile:filePath atomically:YES];													//Write new one
	} else {
		return -3;																							//Return -3 if we couldn't
	}
	
	fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];								//Check for new plist
	
	if(fileExists){
		return 0;
	} else {
		return -4;
	}
}

- (void)cleanNVRAM:(NSString *)filePath {
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	if(fileExists) {
		if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL]) {
			NSLog(@"Failed to remove NVRAM dump");
		}
	}
}


@end

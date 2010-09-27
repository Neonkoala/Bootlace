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

- (int)opibParseUpdatePlist {
	DLog(@"Parsing OpeniBoot update plist");
	
	if(deviceDict == nil) {
		DLog(@"OpeniBoot plist invalid");
		return -1;
	}
	
	sharedData.opibUpdateBootlaceRequired = [deviceDict objectForKey:@"BootlaceRequired"];
	sharedData.opibUpdateReleaseDate = [deviceDict objectForKey:@"ReleaseDate"];
	sharedData.opibUpdateURL = [deviceDict objectForKey:@"URL"];
	sharedData.opibUpdateVersion = [deviceDict objectForKey:@"Version"];
	sharedData.opibUpdateCompatibleFirmware = [deviceDict objectForKey:@"CompatibleFirmware"];
	sharedData.opibUpdateIPSWURLs = [deviceDict objectForKey:@"IPSWURLs"];
	sharedData.opibUpdateKernelMD5 = [deviceDict objectForKey:@"KernelMD5"];
	sharedData.opibUpdateManifest = [deviceDict objectForKey:@"Manifest"];
	
	return 0;
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

//
//  commonData.m
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 Nick Dawson. All rights reserved.
//

#import "commonData.h"


@implementation commonData

@synthesize firstLaunchVal, platform, workingDirectory, opibInitStatus, opibDict, opibBackupPath, opibVersion, opibTimeout, opibDefaultOS, opibTempOS, installed, installedVer, installedAndroidVer, installedDate, installedFiles, installedDependencies, latestVerDict, upgradeDict, updateAvailable, updateStage, updateFail, updateSize, updateOverallProgress, updateCurrentProgress, updateVer, updateAndroidVer, updateDate, updateURL, updateMD5, updateFirmwarePath, updatePackagePath, updateClean, updateFiles, updateDependencies;

+ (commonData *) sharedData {
	static commonData *sharedData;
	
	@synchronized(self) {
		if(!sharedData){
			sharedData = [[commonData alloc] init];
		}
	}
	
	return sharedData;
}

-(void)dealloc{
	[super dealloc];
}

@end

//
//  commonData.m
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 Nick Dawson. All rights reserved.
//

#import "commonData.h"


@implementation commonData

@synthesize firstLaunchVal, debugMode, warningLive, platform, workingDirectory, bootlaceVersion, opibInitStatus, opibDict, opibBackupPath, opibVersion, opibTimeout, opibDefaultOS, opibTempOS, installed, installedVer, installedAndroidVer, installedOpibRequired, installedDate, installedFiles, installedDependencies, latestVerDict, upgradeDict, updateCanBeInstalled, updateStage, updateFail, updateSize, updateOverallProgress, updateCurrentProgress, updateVer, updateAndroidVer, updateDate, updateOpibRequired, updateURL, updateMD5, updateFirmwarePath, updatePackagePath, updateClean, updateFiles, updateDependencies, upgradeUseDelta, upgradeDeltaReqVer, upgradeDeltaRemoveFiles, upgradeDeltaMoveFiles, upgradeDeltaAddFiles, upgradeDeltaPostInstall, upgradeComboReqVer, upgradeComboRemoveFiles, upgradeComboMoveFiles, upgradeComboAddFiles, upgradeComboPostInstall;

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

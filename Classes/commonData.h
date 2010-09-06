//
//  commonData.h
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 Nick Dawson. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface commonData : NSObject {
	//Initialisation variables
	BOOL firstLaunchVal;
	BOOL warningLive;
	NSString *platform;
	NSString *workingDirectory;
	NSString *bootlaceVersion;
	
	int opibInitStatus;
	NSMutableDictionary *opibDict;
	NSString *opibBackupPath;
	NSString *opibVersion;
	NSString *opibTimeout;
	NSString *opibDefaultOS;
	NSString *opibTempOS;
	
	BOOL installed;
	NSString *installedVer;
	NSString *installedAndroidVer;
	NSString *installedOpibRequired;
	NSDate *installedDate;
	NSArray *installedFiles;
	NSArray *installedDependencies;
	
	NSMutableDictionary *latestVerDict;
	NSMutableDictionary *upgradeDict;
	
	int updateCanBeInstalled;
	int updateStage;
	int updateFail;
	int updateSize;
	float updateOverallProgress;
	float updateCurrentProgress;
	NSString *updateVer;
	NSString *updateAndroidVer;
	NSDate *updateDate;
	NSString *updateOpibRequired;
	NSString *updateURL;
	NSString *updateMD5;
	NSString *updateFirmwarePath;
	NSString *updatePackagePath;
	NSString *updateClean;
	NSMutableDictionary *updateFiles;
	NSMutableDictionary *updateDependencies;
	
	BOOL upgradeUseDelta;
	NSString *upgradeDeltaReqVer;
	NSString *upgradeComboReqVer;
}

@property (nonatomic, assign) BOOL firstLaunchVal;
@property (nonatomic, assign) BOOL warningLive;
@property (nonatomic, retain) NSString *platform;
@property (nonatomic, retain) NSString *workingDirectory;
@property (nonatomic, retain) NSString *bootlaceVersion;

@property (nonatomic, assign) int opibInitStatus;
@property (nonatomic, retain) NSMutableDictionary *opibDict;
@property (nonatomic, retain) NSString *opibBackupPath;
@property (nonatomic, retain) NSString *opibVersion;
@property (nonatomic, retain) NSString *opibTimeout;
@property (nonatomic, retain) NSString *opibDefaultOS;
@property (nonatomic, retain) NSString *opibTempOS;

@property (nonatomic, assign) BOOL installed;
@property (nonatomic, retain) NSString *installedVer;
@property (nonatomic, retain) NSString *installedAndroidVer;
@property (nonatomic, retain) NSString *installedOpibRequired;
@property (nonatomic, retain) NSDate *installedDate;
@property (nonatomic, retain) NSArray *installedFiles;
@property (nonatomic, retain) NSArray *installedDependencies;

@property (nonatomic, retain) NSMutableDictionary *latestVerDict;
@property (nonatomic, retain) NSMutableDictionary *upgradeDict;

@property (nonatomic, assign) int updateCanBeInstalled;
@property (nonatomic, assign) int updateStage;
@property (nonatomic, assign) int updateFail;
@property (nonatomic, assign) int updateSize;
@property (nonatomic, assign) float updateOverallProgress;
@property (nonatomic, assign) float updateCurrentProgress;
@property (nonatomic, retain) NSString *updateVer;
@property (nonatomic, retain) NSString *updateAndroidVer;
@property (nonatomic, retain) NSDate *updateDate;
@property (nonatomic, retain) NSString *updateOpibRequired;
@property (nonatomic, retain) NSString *updateURL;
@property (nonatomic, retain) NSString *updateMD5;
@property (nonatomic, retain) NSString *updateFirmwarePath;
@property (nonatomic, retain) NSString *updatePackagePath;
@property (nonatomic, retain) NSString *updateClean;
@property (nonatomic, retain) NSMutableDictionary *updateFiles;
@property (nonatomic, retain) NSMutableDictionary *updateDependencies;

@property (nonatomic, assign) BOOL upgradeUseDelta;
@property (nonatomic, retain) NSString *upgradeDeltaReqVer;
@property (nonatomic, retain) NSString *upgradeComboReqVer;

+ (commonData *) sharedData;

@end

//
//  commonData.h
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface commonData : NSObject {
	//Initialisation variables
	BOOL firstLaunchVal;
	NSString *platform;
	NSString *workingDirectory;
	
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
	NSDate *installedDate;
	NSArray *installedFiles;
	NSArray *installedDependencies;
	
	NSMutableDictionary *latestVerDict;
	NSMutableDictionary *upgradeDict;
	
	BOOL updateAvailable;
	int updateStage;
	int updateFail;
	int updateSize;
	float updateProgress;
	NSString *updateVer;
	NSString *updateAndroidVer;
	NSDate *updateDate;
	NSString *updateURL;
	NSString *updateFirmwarePath;
	NSString *updatePackagePath;
	NSString *updateClean;
	NSMutableDictionary *updateFiles;
	NSMutableDictionary *updateDependencies;
}

@property (nonatomic, assign) BOOL firstLaunchVal;
@property (nonatomic, retain) NSString *platform;
@property (nonatomic, retain) NSString *workingDirectory;

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
@property (nonatomic, retain) NSDate *installedDate;
@property (nonatomic, retain) NSArray *installedFiles;
@property (nonatomic, retain) NSArray *installedDependencies;

@property (nonatomic, retain) NSMutableDictionary *latestVerDict;
@property (nonatomic, retain) NSMutableDictionary *upgradeDict;

@property (nonatomic, assign) BOOL updateAvailable;
@property (nonatomic, assign) int updateStage;
@property (nonatomic, assign) int updateFail;
@property (nonatomic, assign) int updateSize;
@property (nonatomic, assign) float updateProgress;
@property (nonatomic, retain) NSString *updateVer;
@property (nonatomic, retain) NSString *updateAndroidVer;
@property (nonatomic, retain) NSDate *updateDate;
@property (nonatomic, retain) NSString *updateURL;
@property (nonatomic, retain) NSString *updateFirmwarePath;
@property (nonatomic, retain) NSString *updatePackagePath;
@property (nonatomic, retain) NSString *updateClean;
@property (nonatomic, retain) NSMutableDictionary *updateFiles;
@property (nonatomic, retain) NSMutableDictionary *updateDependencies;

+ (commonData *) sharedData;

@end

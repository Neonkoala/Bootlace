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
	int opibTempOSDisabled;
	NSString *opibWorkingPath;
	NSString *opibBackupPath;
	NSString *opibVersion;
	NSString *opibTimeout;
	NSString *opibDefaultOS;
	NSString *opibTempOS;
	
	NSString *installedVer;
	NSString *installedAndroidVer;
	NSString *installedDate;
	
	NSMutableDictionary *latestVerDict;
	NSMutableDictionary *upgradeDict;
	
	NSString *updateVer;
	NSString *updateAndroidVer;
	NSString *updateDate;
	NSString *updateURL;
	NSString *updateMD5;
	NSMutableDictionary *updateFiles;
	NSMutableDictionary *updateDependencies;
}

@property (nonatomic, assign) BOOL firstLaunchVal;
@property (nonatomic, assign) NSString *platform;
@property (nonatomic, assign) NSString *workingDirectory;

@property (nonatomic, assign) int opibInitStatus;
@property (nonatomic, assign) int opibTempOSDisabled;
@property (nonatomic, retain) NSString *opibWorkingPath;
@property (nonatomic, retain) NSString *opibBackupPath;
@property (nonatomic, retain) NSString *opibVersion;
@property (nonatomic, retain) NSString *opibTimeout;
@property (nonatomic, retain) NSString *opibDefaultOS;
@property (nonatomic, retain) NSString *opibTempOS;

@property (nonatomic, retain) NSString *installedVer;
@property (nonatomic, retain) NSString *installedAndroidVer;
@property (nonatomic, retain) NSString *installedDate;

@property (nonatomic, retain) NSMutableDictionary *latestVerDict;
@property (nonatomic, retain) NSMutableDictionary *upgradeDict;

@property (nonatomic, retain) NSString *updateVer;
@property (nonatomic, retain) NSString *updateAndroidVer;
@property (nonatomic, retain) NSString *updateDate;
@property (nonatomic, retain) NSString *updateURL;
@property (nonatomic, retain) NSString *updateMD5;
@property (nonatomic, retain) NSMutableDictionary *updateFiles;
@property (nonatomic, retain) NSMutableDictionary *updateDependencies;

+ (commonData *) sharedData;

@end

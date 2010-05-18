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
	BOOL firstLaunch;
	int initStatus;
	int temposDisabled;
	NSString *workingPath;
	NSString *backupPath;
	
	//Common usage variables
	NSString *opibVersion;
	NSString *opibTimeout;
	NSString *opibDefaultOS;
	NSString *opibTempOS;
}

@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, assign) int initStatus;
@property (nonatomic, assign) int temposDisabled;
@property (nonatomic, retain) NSString *workingPath;
@property (nonatomic, retain) NSString *backupPath;

@property (nonatomic, retain) NSString *opibVersion;
@property (nonatomic, retain) NSString *opibTimeout;
@property (nonatomic, retain) NSString *opibDefaultOS;
@property (nonatomic, retain) NSString *opibTempOS;

+ (commonData *) sharedData;

@end

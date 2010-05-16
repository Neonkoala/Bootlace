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
	int initStatus;
	NSString *workingPath;
	NSString *backupPath;
	
	//Common usage variables
	int formattedTimeout;
	NSString *opibVersion;
	NSString *opibTimeout;
	NSString *opibDefaultOS;
}

@property (nonatomic, assign) int initStatus;
@property (nonatomic, retain) NSString *workingPath;
@property (nonatomic, retain) NSString *backupPath;

@property (nonatomic, assign) int formattedTimeout;
@property (nonatomic, retain) NSString *opibVersion;
@property (nonatomic, retain) NSString *opibTimeout;
@property (nonatomic, retain) NSString *opibDefaultOS;

+ (commonData *) sharedData;

@end

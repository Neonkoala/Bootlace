//
//  OpeniBootClass.h
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "commonData.h"
#import "commonFunctions.h"


@interface OpeniBootClass : NSObject {
	NSMutableDictionary *deviceDict;
	
}

@property (nonatomic, retain) NSMutableDictionary *deviceDict;

- (int)opibParseUpdatePlist;
- (void)opibCheckForUpdates;


@end

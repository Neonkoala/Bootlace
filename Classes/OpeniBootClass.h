//
//  OpeniBootClass.h
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <sys/mman.h>
#import "commonData.h"
#import "commonFunctions.h"
#import "BSPatch.h"
#import "partial/partial.h"


@interface OpeniBootClass : NSObject {
	NSMutableDictionary *deviceDict;
	
}

@property (nonatomic, retain) NSMutableDictionary *deviceDict;

- (int)opibParseUpdatePlist;
- (int)opibGetNORFromManifest;
- (int)opibFlashIMG3:(NSString *)path usingService:(io_connect_t)norServiceConnection type:(BOOL)isLLB;

- (io_service_t)opibGetIOService:(NSString *)name;

- (void)opibCheckForUpdates;


@end

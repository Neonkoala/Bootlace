//
//  OpeniBootClass.h
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <Foundation/NSTask.h>
#import <sys/mman.h>
#import "commonData.h"
#import "commonFunctions.h"
#import "BSPatch.h"
#import "partial/partial.h"


@interface OpeniBootClass : NSObject {
	BSPatch *bsPatchInstance;
	
	NSMutableDictionary *deviceDict;
	
}

@property (nonatomic, retain) NSMutableDictionary *deviceDict;

- (int)opibParseUpdatePlist;
- (int)opibGetNORFromManifest;
- (int)opibPatchManifest;
- (int)opibFlashManifest;
- (int)opibFlashIMG3:(NSString *)path usingService:(io_connect_t)norServiceConnection type:(BOOL)isLLB;
- (int)opibDecryptIMG3:(NSString *)srcPath to:(NSString *)dstPath key:(NSString *)key iv:(NSString *)iv;

- (io_service_t)opibGetIOService:(NSString *)name;

- (void)opibCheckForUpdates;


@end

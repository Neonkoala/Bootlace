//
//  commonFunctions.h
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "commonData.h"
#import "nvramFunctions.h"


@interface commonFunctions : NSObject {

}

- (void)initNVRAM;
- (int)rebootAndroid;
- (int)rebootConsole;
- (int)backupNVRAM;
- (int)restoreNVRAM;
- (int)resetNVRAM;
- (int)applyNVRAM;
- (int)getFile:(NSString *)fileURL toDestination:(NSString *)filePath;
- (void)checkForUpdates;
- (void)getPlatform;
- (int)parseUpdatePlist;
- (void)firstLaunch;
- (void)sendError:(NSString *)alertMsg;
- (void)sendTerminalError:(NSString *)alertMsg;
- (void)sendConfirmation:(NSString *)alertMsg withTag:(int)tag;
- (void)sendSuccess:(NSString *)alertMsg;

@end

//
//  commonFunctions.h
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <sys/types.h>
#import <sys/reboot.h>
#import <sys/sysctl.h>
#import <unistd.h>

#import "commonData.h"
#import "nvramFunctions.h"
#import "extractionClass.h"
#import "DroidViewController.h"


@interface commonFunctions : NSObject {
	
}

- (void)initNVRAM;
- (int)rebootAndroid;
- (int)rebootConsole;
- (int)backupNVRAM;
- (int)restoreNVRAM;
- (int)resetNVRAM;
- (int)applyNVRAM;
- (void)getPlatform;
- (void)firstLaunch;
- (void)sendError:(NSString *)alertMsg;
- (void)sendTerminalError:(NSString *)alertMsg;
- (void)sendConfirmation:(NSString *)alertMsg withTag:(int)tag;
- (void)sendSuccess:(NSString *)alertMsg;

@end

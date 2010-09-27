//
//  commonFunctions.h
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 Nick Dawson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <sys/mount.h>
#import <sys/param.h>
#import <sys/types.h>
#import <sys/reboot.h>
#import <sys/sysctl.h>
#import <unistd.h>

#import "commonData.h"
#import "nvramFunctions.h"
#import "extractionClass.h"
#import "DroidViewController.h"


// DLog is almost a drop-in replacement for NSLog
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


@interface commonFunctions : NSObject {
	nvramFunctions *nvramInstance;
}

@property (nonatomic, retain) nvramFunctions *nvramInstance;

- (void)initNVRAM;
- (int)rebootAndroid;
- (int)rebootConsole;
- (int)callBackupNVRAM;
- (int)callRestoreNVRAM;
- (int)resetNVRAM;
- (int)applyNVRAM;
- (BOOL)checkMains;
- (float)getFreeSpace;
- (void)getPlatform;
- (void)getSystemVersion;
- (void)firstLaunch;
- (void)sendError:(NSString *)alertMsg;
- (void)sendWarning:(NSString *)alertMsg;
- (void)sendTerminalError:(NSString *)alertMsg;
- (void)sendConfirmation:(NSString *)alertMsg withTag:(int)tag;
- (void)sendSuccess:(NSString *)alertMsg;

@end

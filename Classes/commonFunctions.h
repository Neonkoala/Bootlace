//
//  commonFunctions.h
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import "commonData.h"
#import "nvramFunctions.h"
#import "getFile.h"
#import "NSBz2.h"


@interface commonFunctions : NSObject {
	getFile *getFileInstance;
}

@property (nonatomic, retain) getFile *getFileInstance;

- (void)initNVRAM;
- (int)rebootAndroid;
- (int)rebootConsole;
- (int)backupNVRAM;
- (int)restoreNVRAM;
- (int)resetNVRAM;
- (int)applyNVRAM;
- (int)getFile:(NSString *)fileURL toDestination:(NSString *)filePath;
- (void)checkForUpdates;
- (int)parseUpdatePlist;
- (void)checkInstalled;
- (int)parseInstalledPlist;
- (void)idroidInstall;
- (void)idroidRemove;
- (void)getFileReady:(getFile *)file;
- (void)getPlatform;
- (NSString*)fileMD5:(NSString *)path;
- (void)firstLaunch;
- (void)sendError:(NSString *)alertMsg;
- (void)sendTerminalError:(NSString *)alertMsg;
- (void)sendConfirmation:(NSString *)alertMsg withTag:(int)tag;
- (void)sendSuccess:(NSString *)alertMsg;

@end

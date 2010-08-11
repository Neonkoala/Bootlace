//
//  installClass.h
//  BootlaceV2
//
//  Created by Neonkoala on 26/07/2010.
//  Copyright 2010 Nick Dawson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/IOKitKeys.h>
#import "commonData.h"
#import "getFile.h"
#import "extractionClass.h"

@class getFile;

@interface installClass : NSObject {
	getFile *getFileInstance;
}

- (int)parseUpdatePlist;
- (int)parseInstalledPlist;
- (int)generateInstalledPlist;
- (void)idroidInstall;
- (void)idroidRemove;
- (void)cleanUp;
- (void)checkForUpdates;
- (void)checkInstalled;
- (void)updateProgress:(NSNumber *)progress;
- (int)relocateFiles;
- (int)dumpMultitouch;
- (int)dumpWiFi;

@end

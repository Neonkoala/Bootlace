//
//  nvramFunctions.h
//  Bootlace
//
//  Created by Neonkoala on 15/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "commonData.h"
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

@interface nvramFunctions : NSObject {

}

- (int)dumpNVRAM:(NSString *)filePath;
- (int)updateNVRAM:(NSString *)filePath;
- (int)parseNVRAM:(NSString *)filePath;
- (int)generateNVRAM:(NSString *)filePath withMode:(int)mode;
- (void)cleanNVRAM:(NSString *)filePath;

@end

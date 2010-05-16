//
//  nvramFunctions.h
//  Bootlace
//
//  Created by Neonkoala on 15/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface nvramFunctions : NSObject {

}

- (int)hookNVRAM:(NSString *)filePath withMode:(int)rw;
- (int)readNVRAM:(NSString *)filePath;
- (int)writeNVRAM:(NSString *)filePath;
- (void)cleanNVRAM:(NSString *)filePath;

@end

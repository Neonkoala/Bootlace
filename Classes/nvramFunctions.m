//
//  nvramFunctions.m
//  Bootlace
//
//  Created by Neonkoala on 15/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "nvramFunctions.h"


@implementation nvramFunctions

- (int)hookNVRAM:(NSString *)filePath withMode:(int)rw {
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	
	return 0;
}

- (int)readNVRAM:(NSString *)filePath {
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	return 0;
}

- (int)writeNVRAM:(NSString *)filePath {
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	return 0;
}

- (void)cleanNVRAM:(NSString *)filePath {
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	if(fileExists) {
		if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL]) {
			NSLog(@"Failed to remove dump");
		}
	}
}


@end

//
//  main.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright Nick Dawson 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Classes/OpeniBootClass.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	int retVal;
	
	if(argc==1) {
		retVal = UIApplicationMain(argc, argv, nil, nil);
	} else if(strcmp(argv[1], "--patchKernel")==0) {
		printf("Patching kernel...\n");
		retVal = 0;
		
		OpeniBootClass *opibInstance = [[OpeniBootClass alloc] init];
		retVal = [opibInstance opibPatchKernelCache];
	} else {
		printf("Invalid argument. Terminating.\n");
		retVal = -7;
	}
		
    [pool release];
    return retVal;
}


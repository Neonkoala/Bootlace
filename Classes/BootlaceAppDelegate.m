//
//  BootlaceAppDelegate.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright Nick Dawson 2010. All rights reserved.
//

#import "BootlaceAppDelegate.h"


@implementation BootlaceAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	commonData* sharedData = [commonData sharedData];
	id commonInstance = [[commonFunctions new] autorelease];
	
	//Check and setup working directory
	NSArray *homeDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	sharedData.workingDirectory = [[homeDirectory objectAtIndex:0] stringByAppendingPathComponent:@"Bootlace"];
	
	BOOL isDir;
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:sharedData.workingDirectory isDirectory:&isDir]) {
		if(![[NSFileManager defaultManager] createDirectoryAtPath:sharedData.workingDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
			NSLog(@"Error: Create Bootlace working folder failed");
		}
	}
	
	//Setup Debug logging
	sharedData.logEnabled = YES;
	sharedData.logfile = [sharedData.workingDirectory stringByAppendingPathComponent:@"bootlace.log"];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:sharedData.logfile]) {
		[[NSFileManager defaultManager] removeItemAtPath:sharedData.logfile error:nil];
	}
	[[NSFileManager defaultManager] createFileAtPath:sharedData.logfile contents:nil attributes:nil];
	
	//First launch check
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];
	sharedData.firstLaunchVal = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
	
	//Check the platform
	[commonInstance getPlatform];
	
	//Dump nvram stuffs
	sharedData.opibBackupPath = [sharedData.workingDirectory stringByAppendingPathComponent:@"NVRAM.plist.backup"];

	[commonInstance initNVRAM];
	
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end


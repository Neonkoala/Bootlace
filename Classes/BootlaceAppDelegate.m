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
	
	//Read settings
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];
	sharedData.firstLaunchVal = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
	sharedData.debugMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"];
	
	if(sharedData.debugMode) {
		DLog(@"Running in debug mode, using alternative servers");
	}
	
	//Setup variables
	sharedData.warningLive = NO;
	sharedData.bootlaceVersion = @"2.0.3";
	
	//Check the platform and iOS version
	[commonInstance getPlatform];
	[commonInstance getSystemVersion];
	
	//Dump nvram stuffs
	sharedData.opibBackupPath = [sharedData.workingDirectory stringByAppendingPathComponent:@"NVRAM.plist.backup"];

	[commonInstance initNVRAM];
	
	// Output current configuration
	DLog(@"Configuration");
	DLog(@"==========================================");
	DLog(@"console logfile = /var/tmp/Bootlace.log");
	DLog(@"==========================================");
	
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


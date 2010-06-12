//
//  BootlaceAppDelegate.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "BootlaceAppDelegate.h"


@implementation BootlaceAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	commonData* sharedData = [commonData sharedData];
	id commonInstance = [commonFunctions new];
	
	//First launch check
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];
	sharedData.firstLaunchVal = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
	
	//Check the platform
	[commonInstance getPlatform];
	
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


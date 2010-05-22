//
//  BootlaceAppDelegate.m
//  Bootlace
//
//  Created by Neonkoala on 11/05/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "BootlaceAppDelegate.h"
#import "RootViewController.h"
#import "AdvancedViewController.h"
#import "SettingsViewController.h"
#import <UIKit/UIKit.h>

@implementation BootlaceAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//First launch check
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];
	
    //init shared variables
	commonData* sharedData = [commonData sharedData];
	id commonInstance = [commonFunctions new];
	
	sharedData.firstLaunchVal = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];

	sharedData.workingPath = @"/var/mobile/NVRAM.plist";
	sharedData.backupPath = @"/var/mobile/NVRAM.plist.backup";
	
	[commonInstance initNVRAM];
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	id nvramInstance = [[nvramFunctions new] autorelease];
	commonData* sharedData = [commonData sharedData];
	[nvramInstance cleanNVRAM:sharedData.workingPath];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end


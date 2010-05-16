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
    //init shared variables
	commonData* sharedData = [commonData sharedData];
	
	sharedData.workingPath = @"/var/mobile/Documents/NVRAM.plist";
	sharedData.backupPath = @"/var/mobile/Documents/NVRAM.plist.backup";
	
	//Temp testing vars
	sharedData.opibVersion = @"0.1.1";
	sharedData.opibTimeout = @"5000";
	sharedData.opibDefaultOS = @"0";
	sharedData.initStatus = 0;
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end


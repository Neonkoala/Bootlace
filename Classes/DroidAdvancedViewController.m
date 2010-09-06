//
//  DroidAdvancedViewController.m
//  BootlaceV2
//
//  Created by Neonkoala on 23/08/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "DroidAdvancedViewController.h"


@implementation DroidAdvancedViewController

@synthesize commonInstance, installInstance, multitouchInstall, wifiInstall;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	commonData* sharedData = [commonData sharedData];
	
	[multitouchInstall setTitle:@"Extract Multitouch Firmware" forState:UIControlStateNormal];
	[multitouchInstall addTarget:self action:@selector(extractMultitouch:) forControlEvents:UIControlEventTouchUpInside];
	multitouchInstall.tintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.000];
	
	[wifiInstall setTitle:@"Download WiFi Firmware" forState:UIControlStateNormal];
	[wifiInstall addTarget:self action:@selector(downloadWifi:) forControlEvents:UIControlEventTouchUpInside];
	wifiInstall.tintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.000];
	
	if(sharedData.updateDependencies == nil) {
		multitouchInstall.enabled = NO;
		wifiInstall.enabled = NO;
	}
}

- (IBAction)extractMultitouch:(id)sender {
	UIActionSheet *confirmExtract = [[UIActionSheet alloc] initWithTitle:@"Extracting multitouch firmware will overwrite any existing firmware. Continue?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Extract" otherButtonTitles:nil];
	confirmExtract.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	confirmExtract.tag = 10;
	[confirmExtract showInView:self.tabBarController.view];
	[confirmExtract release];
}

- (IBAction)downloadWifi:(id)sender {
	UIActionSheet *confirmWifi = [[UIActionSheet alloc] initWithTitle:@"Downloading wifi firmware will overwrite any existing firmware. Continue?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Download" otherButtonTitles:nil];
	confirmWifi.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	confirmWifi.tag = 20;
	[confirmWifi showInView:self.tabBarController.view];
	[confirmWifi release];	
}

- (void)dumpZephyr {
	commonData* sharedData = [commonData sharedData];
	
	commonInstance = [[commonFunctions alloc] init];
	installInstance = [[installClass alloc] init];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:sharedData.updateFirmwarePath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:sharedData.updateFirmwarePath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z2F52,1"] || [[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z2F51,1"]) {
		if([[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr2.bin"]]) {
			DLog(@"Removing existing zephyr2 firmware file");
			[[NSFileManager defaultManager] removeItemAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr2.bin"] error:nil];
		}
	} else if([[sharedData.updateDependencies objectForKey:@"Multitouch"] isEqual:@"Z1F50,1"]) {
		if([[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_main.bin"]] || [[NSFileManager defaultManager] fileExistsAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_aspeed.bin"]]) {
			DLog(@"Removing existing zephyr1 firmware files");
			[[NSFileManager defaultManager] removeItemAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_main.bin"] error:nil];
			[[NSFileManager defaultManager] removeItemAtPath:[sharedData.updateFirmwarePath stringByAppendingPathComponent:@"zephyr_aspeed.bin"] error:nil];
		}
	}

	int success = [installInstance dumpMultitouch];

	switch (success) {
		case 0:
			[commonInstance sendSuccess:@"Zephyr multitouch firmware succesfully extracted."];
			break;
		case -1:
			[commonInstance sendError:@"Zephyr2 extraction failed."];
			break;
		case -2:
			[commonInstance sendError:@"Zephyr1 extraction failed on zephyr_main.bin"];
			break;
		case -3:
			[commonInstance sendError:@"Zephyr1 extraction failed on zephyr_aspeed.bin"];
			break;
		default:
			break;
	}
}

- (void)getWifi {
	commonData* sharedData = [commonData sharedData];
	
	commonInstance = [[commonFunctions alloc] init];
	installInstance = [[installClass alloc] init];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:sharedData.updateFirmwarePath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:sharedData.updateFirmwarePath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	int success = [installInstance dumpWiFi];
	
	switch (success) {
		case 0:
			[commonInstance sendSuccess:@"Successfully downloaded WiFi firmware files."];
			break;
		default:
			break;
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"index: %d", buttonIndex);
	switch (actionSheet.tag) {
		case 10:
			if(buttonIndex == 0) {
				[self performSelectorOnMainThread:@selector(dumpZephyr) withObject:nil waitUntilDone:NO];
			}
			break;
		case 20:
			if(buttonIndex == 0) {
				[self performSelector:@selector(getWifi) withObject:nil];
			}
			break;
		default:
			break;
	}
}
	 
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

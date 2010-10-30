//
//  FirstLaunchViewController.m
//  BootlaceV2
//
//  Created by Neonkoala on 29/10/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "FirstLaunchViewController.h"


@implementation FirstLaunchViewController

@synthesize patchingProgress, guiLoop;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)updateGUI:(NSTimer *)theTimer {
	commonData *sharedData = [commonData sharedData];
	commonInstance = [[commonFunctions alloc] init];
	
	NSLog(@"Oh we got here!");
	
	if (sharedData.kernelPatchStage == 5) {
		[patchingProgress hide];
		
		if(sharedData.kernelPatchFail==0) {	
			sharedData.firstLaunch = NO;
			
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"secondLaunch"];
			
			UIAlertView *rebootPrompt = [[UIAlertView alloc] initWithTitle:@"Reboot Required" message:@"Kernel successfully patched.\r\n\r\nYour device is about to reboot." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
			[rebootPrompt show];
			
			sleep(3);
			reboot(0);
		}
		
		[guiLoop invalidate];
	}
	switch (sharedData.kernelPatchStage) {
		case 2:
			[patchingProgress performSelectorOnMainThread:@selector(setText:) withObject:@"Downloading Kernel..." waitUntilDone:YES];
			break;
		case 3:
			[patchingProgress performSelectorOnMainThread:@selector(setText:) withObject:@"Patching Kernel..." waitUntilDone:YES];
			break;
		case 4:
			[patchingProgress performSelectorOnMainThread:@selector(setText:) withObject:@"Replacing Kernel..." waitUntilDone:YES];
			break;
		default:
			break;
	}
	switch (sharedData.kernelPatchFail) {
		case 0:
			break;
		case -1:
			DLog(@"Error triggered. Fail code: %d", sharedData.kernelPatchFail);
			[commonInstance sendTerminalError:@"Bootlace does not support this device."];
			[guiLoop invalidate];
			break;
		case -2:
			DLog(@"Error triggered. Fail code: %d", sharedData.kernelPatchFail);
			[commonInstance sendTerminalError:@"Bootlace does not support this firmware."];
			[guiLoop invalidate];
			break;
		case -3:
			DLog(@"Error triggered. Fail code: %d", sharedData.kernelPatchFail);
			[commonInstance sendTerminalError:@"Kernel does not match any compatible jailbreaks. Jailbreak with redsn0w or PwnageTool and try again."];
			[guiLoop invalidate];
			break;
		default:
			break;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	opibInstance = [[OpeniBootClass alloc] init];
	
	patchingProgress = [[UIProgressHUD alloc] initWithWindow:self.view];
	[patchingProgress setText:@"Checking Compatibility..."];
	[patchingProgress showInView:self.view];
	
	NSOperationQueue *thisQ = [NSOperationQueue new];
	NSInvocationOperation *doPatch = [[NSInvocationOperation alloc] initWithTarget:opibInstance selector:@selector(opibPatchKernelCache) object:nil];
	
	[thisQ addOperation:doPatch];
    [doPatch release];
	
	guiLoop = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateGUI:) userInfo:nil repeats:YES];
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

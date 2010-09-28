//
//  OpeniBootViewController.m
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "OpeniBootViewController.h"


@implementation OpeniBootViewController

@synthesize opibInstall, opibConfigure;

- (IBAction)opibConfigureTap:(id)sender {
	OpeniBootConfigureViewController *configureView = [[OpeniBootConfigureViewController alloc] initWithNibName:@"OpeniBootConfigureViewController" bundle:nil];
	[self.navigationController pushViewController:configureView animated:YES];
	[configureView release];
}

- (IBAction)opibInstallTap:(id)sender {
	[self performSelectorInBackground:@selector(opibDoInstall) withObject:nil];
}

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
	commonInstance = [[commonFunctions alloc] init];
	opibInstance = [[OpeniBootClass alloc] init];
	
	opibConfigure.tintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.000];
	opibInstall.tintColor = [UIColor colorWithRed:0 green:0.7 blue:0.1 alpha:1.000];
	
	//Check installed version and whack it in the UI - if not installed then download plist	
	[self performSelectorInBackground:@selector(opibUpdateCheck) withObject:nil];
	
	[opibInstall setTitle:@"Install" forState:UIControlStateNormal];
	opibInstall.enabled = YES;
}

- (void)opibUpdateCheck {
	commonData* sharedData = [commonData sharedData];
	commonInstance = [[commonFunctions alloc] init];
	
	[opibInstance opibCheckForUpdates];
	
	if(sharedData.opibCanBeInstalled < 0) {
		switch (sharedData.opibCanBeInstalled) {
			case -1:
				DLog(@"");
				[commonInstance sendError:@""];
				break;
			default:
				break;
		}
	}
	
	if(sharedData.opibInstalled) {
		
	} else {
		
	}
}

- (void)opibDoInstall {
	commonData* sharedData = [commonData sharedData];
	commonInstance = [[commonFunctions alloc] init];
	opibInstance = [[OpeniBootClass alloc] init];
	
	[opibInstance opibGetNORFromManifest];
	
	//Check pre-requisites
		//Most importantly, let's double check the device here or we're in a whole heap of dinosaur doodoo
		//Now let's check iOS version
		//Ok that's good, now lets see if kernel matches our whitelist of MD5 hashes from various jailbreaks
		//W00t! we got this far... Now lets check the server has a patch for us too as you know, Neonkoala is a lazy bastard and might have not bothered
	
	//Right now we got that out the way, start a loop and UIProgressBar otherwise some dick will complain nothings happening
		//Hand over to OpeniBootClass
	
	//Reload version
		
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

//
//  AdvancedViewController.m
//  Bootlace
//
//  Created by Neonkoala on 12/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AdvancedViewController.h"


@implementation AdvancedViewController

@synthesize openibootVersion;

- (IBAction) backupSettings:(id)sender {
	id commonInstance = [commonFunctions new];
	
	[commonInstance sendConfirmation:@"This will backup your NVRAM and overwrite any existing backup.\r\nContinue?" withTag:4];
}

- (IBAction) restoreSettings:(id)sender {
	id commonInstance = [commonFunctions new];
	
	[commonInstance sendConfirmation:@"This will restore your NVRAM backup and overwrite any existing settings.\r\nContinue?" withTag:5];
}

- (IBAction) resetSettings:(id)sender {
	id commonInstance = [commonFunctions new];
	
	[commonInstance sendConfirmation:@"This will reset your openiboot settings to their defaults and overwrite any existing settings.\r\nContinue?" withTag:6];
}

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	commonData* sharedData = [commonData sharedData];
	
	openibootVersion.text = sharedData.opibVersion;
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



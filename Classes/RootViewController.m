//
//  RootViewController.m
//  Bootlace
//
//  Created by Neonkoala on 14/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController

@synthesize aboutView, aboutButton, backButton, settingsButton;

- (IBAction)aboutTap:(id)sender  {
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	
	[UIView setAnimationTransition:([self.view superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([aboutView superview])
		[aboutView removeFromSuperview];
	else
		[self.view addSubview:aboutView];
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([aboutView superview] == self.view) {
		self.navigationItem.leftBarButtonItem = backButton;
		self.navigationItem.rightBarButtonItem = nil;
	} else {
		self.navigationItem.leftBarButtonItem = aboutButton;
		self.navigationItem.rightBarButtonItem = settingsButton;
	}
}

- (IBAction)settingsTap:(id)sender  {
	SettingsViewController *settingsView = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	[self.navigationController pushViewController:settingsView animated:YES];
	[settingsView release];
}

- (IBAction)rebootToAndroid:(id)sender {
	id commonInstance;
	commonInstance = [commonFunctions new];
	
	[commonInstance sendConfirmation:@"This will reboot your device into Android immediately.\r\nAre you sure?" withTag:2];
}

- (IBAction)rebootToConsole:(id)sender {
	id commonInstance;
	commonInstance = [commonFunctions new];
	
	[commonInstance sendConfirmation:@"This will reboot your device into the console immediately.\r\nAre you sure?" withTag:3];
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


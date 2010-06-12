//
//  BootViewController.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "BootViewController.h"

@implementation BootViewController

@synthesize quickBootAboutView, doneButton, flipButton;


- (void)flipAction:(id)sender
{
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([self.view superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([quickBootAboutView superview])
		[quickBootAboutView removeFromSuperview];
	else
		[self.view addSubview:quickBootAboutView];
	
	[UIView commitAnimations];
	
	// adjust our done/info buttons accordingly
	if ([quickBootAboutView superview] == self.view)
		self.navigationItem.rightBarButtonItem = doneButton;
	else
		self.navigationItem.rightBarButtonItem = flipButton;
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
	 
	 // add our custom flip button as the nav bar's custom right view
	 UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	 [infoButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
	 flipButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	 self.navigationItem.rightBarButtonItem = flipButton;
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

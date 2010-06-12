//
//  HomeViewController.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "HomeViewController.h"


@implementation HomeViewController

@synthesize homePage, homeAboutView, doneButton, aboutButton, refreshButton;

- (IBAction)refreshHome:(id)sender
{
	[homePage reload];
}

- (void)flipAction:(id)sender
{
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:animationIDfinished:finished:context:)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	
	[UIView setAnimationTransition:([self.view superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.view cache:YES];
	
	if ([homeAboutView superview])
		[homeAboutView removeFromSuperview];
	else
		[self.view addSubview:homeAboutView];
	
	[UIView commitAnimations];
	
	if ([homeAboutView superview] == self.view) {
		self.navigationItem.leftBarButtonItem = doneButton;
		self.navigationItem.rightBarButtonItem = nil;
	} else {
		self.navigationItem.leftBarButtonItem = aboutButton;
		self.navigationItem.rightBarButtonItem = refreshButton;
	}
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
	
	NSString *urlAddress = @"http://www.google.com";
	
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:urlAddress];
	
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	//Load the request in the UIWebView.
	[homePage loadRequest:requestObj];
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

//
//  HomeViewController.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "HomeViewController.h"


@implementation HomeViewController

@synthesize homePage, homeAboutView, doneButton, aboutButton, refreshButton, stopButton, backButton;

- (IBAction)refreshHome:(id)sender {
	[homePage reload];
}

- (IBAction)stopLoading:(id)sender {
	[homePage stopLoading];
}

- (IBAction)goBack:(id)sender {
	[homePage goBack];
}

- (void)flipAction:(id)sender {
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
	
	commonData *sharedData = [commonData sharedData];
	id commonInstance = [commonFunctions new];
	
	NSString *urlAddress = @"http://idroid.neonkoala.co.uk";
	
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:urlAddress];
	
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	//Load the request in the UIWebView.
	[homePage setDelegate:self];
	[homePage loadRequest:requestObj];
	
	if(sharedData.firstLaunchVal) {
		[commonInstance firstLaunch];
		sharedData.firstLaunchVal = NO;
	}
	
	if(![sharedData.platform isEqualToString:@"iPhone1,1"] && ![sharedData.platform isEqualToString:@"iPhone1,2"] && ![sharedData.platform isEqualToString:@"iPod1,1"]) {
		[commonInstance sendTerminalError:@"Bootlace is not compatible with this device.\r\nAborting..."];
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self performSelectorOnMainThread:@selector(loadingWebView) withObject:nil waitUntilDone:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self performSelectorOnMainThread:@selector(showWebView) withObject:nil waitUntilDone:NO]; 
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self performSelectorOnMainThread:@selector(showWebView) withObject:nil waitUntilDone:NO];
}

- (void)loadingWebView {
	self.navigationItem.rightBarButtonItem = stopButton;
}

- (void)showWebView {
	[homePage setHidden:NO];
	
	self.navigationItem.rightBarButtonItem = refreshButton;
	
	if(homePage.canGoBack) {
		self.navigationItem.leftBarButtonItem = backButton;
	} else {
		self.navigationItem.leftBarButtonItem = aboutButton;
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

- (void)viewWillDisappear
{
    if ([homePage isLoading])
        [homePage stopLoading];
	[homePage release];
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end

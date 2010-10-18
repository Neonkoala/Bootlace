//
//  OpeniBootViewController.m
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "OpeniBootViewController.h"


@implementation OpeniBootViewController

@synthesize viewInitQueue, opibLoadingButton, opibRefreshButton, opibVersionLabel, opibReleaseDateLabel, opibInstall, opibConfigure, cfuSpinner;

- (IBAction)opibRefreshTap:(id)sender {
	[self switchButtons];
	
	opibInstall.enabled = NO;
	opibVersionLabel.hidden = YES;
	opibReleaseDateLabel.hidden = YES;
	
	cfuSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[cfuSpinner setCenter:CGPointMake(160, 140)];
	[cfuSpinner startAnimating];
	[self.view addSubview:cfuSpinner];
	
	NSInvocationOperation *bgUpdate = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(opibUpdateCheck) object:nil];
	
	[viewInitQueue addOperation:bgUpdate];
    [bgUpdate release];
}

- (IBAction)opibConfigureTap:(id)sender {
	OpeniBootConfigureViewController *configureView = [[OpeniBootConfigureViewController alloc] initWithNibName:@"OpeniBootConfigureViewController" bundle:nil];
	[self.navigationController pushViewController:configureView animated:YES];
	[configureView release];
}

- (IBAction)opibInstallTap:(id)sender {
	NSInvocationOperation *getInstall = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(opibDoInstall) object:nil];
	
	[viewInitQueue addOperation:getInstall];
    [getInstall release];
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
	
	//Set up a queue for threading later
	viewInitQueue = [NSOperationQueue new];
	
	opibConfigure.tintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.000];
	opibInstall.tintColor = [UIColor colorWithRed:0 green:0.7 blue:0.1 alpha:1.000];
	
	UIActivityIndicatorView *pageLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[pageLoading startAnimating];
	
	opibLoadingButton = [[UIBarButtonItem alloc] initWithCustomView:pageLoading];
	
	[self switchButtons];
	
	if(sharedData.opibInstalled) {
		[opibInstall setTitle:@"Installed" forState:UIControlStateNormal];
		opibInstall.enabled = NO;
		[opibVersionLabel setText:[NSString stringWithFormat:@"Version %@ for %@", sharedData.opibVersion, sharedData.deviceName]];
		opibVersionLabel.hidden = NO;
		opibConfigure.enabled = YES;
		opibConfigure.hidden = NO;
	} else {
		cfuSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[cfuSpinner setCenter:CGPointMake(160, 140)];
		[cfuSpinner startAnimating];
		[self.view addSubview:cfuSpinner];
	}
	
	//Check installed version and whack it in the UI - if not installed then download plist	
	NSInvocationOperation *bgUpdate = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(opibUpdateCheck) object:nil];
	
	[viewInitQueue addOperation:bgUpdate];
    [bgUpdate release];
}

- (void)opibUpdateCheck {
	commonData* sharedData = [commonData sharedData];
	commonInstance = [[commonFunctions alloc] init];
	
	[opibInstance opibCheckForUpdates];
	
	DLog(@"opibCheckForUpdates returned: %d", sharedData.opibCanBeInstalled);
		
	switch (sharedData.opibCanBeInstalled) {
		case 2:
			//OpeniBoot is at latest version
			opibReleaseDateLabel.hidden = NO;
			NSDateFormatter *dateFormat2 = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormat2 setDateFormat:@"dd-MM-yyyy"];
			NSString *dateString2 = [dateFormat2 stringFromDate:sharedData.opibUpdateReleaseDate];
			[opibReleaseDateLabel setText:[NSString stringWithFormat:@"Released %@",dateString2]];
			break;
		case 1:
			//UIAlertView Update available! Lalalala!
			break;
		case 0:
			//OpeniBoot not installed but available
			[opibInstall setTitle:@"Install" forState:UIControlStateNormal];
			opibInstall.enabled = YES;
			[opibVersionLabel setText:[NSString stringWithFormat:@"Version %@ for %@", sharedData.opibUpdateVersion, sharedData.deviceName]];
			opibVersionLabel.hidden = NO;
			NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormat setDateFormat:@"dd-MM-yyyy"];
			NSString *dateString = [dateFormat stringFromDate:sharedData.opibUpdateReleaseDate];
			[opibReleaseDateLabel setText:[NSString stringWithFormat:@"Released %@",dateString]];
			opibReleaseDateLabel.hidden = NO;
			[cfuSpinner stopAnimating];
			break;
		case -1:
			[commonInstance sendError:@"Unable to contact update server.\r\n\r\nCheck your network connection."];
			break;
		case -2:
			[commonInstance sendError:@"Update plist could not be parsed or is invalid."];
			break;
		default:
			break;
	}
	
	[self switchButtons];
}

- (void)opibDoInstall {
	commonData* sharedData = [commonData sharedData];
	commonInstance = [[commonFunctions alloc] init];
	opibInstance = [[OpeniBootClass alloc] init];
	
	sharedData.opibUpdateStage = 0;
	sharedData.opibUpdateFail = 0;
	/*
	//Check pre-requisites
	//Most importantly, let's double check the device here or we're in a whole heap of dinosaur doodoo
	
	NSArray *supportedDevices = [sharedData.opibDict allKeys];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", sharedData.platform];
	NSArray *results = [supportedDevices filteredArrayUsingPredicate:predicate];
	
	if([results count] < 1) {
		DLog(@"Device %@ not supported by OpeniBoot! Aborting.", sharedData.platform);
		[commonInstance sendError:@"This device is not compatible with OpeniBoot."];
		return;
	}
	
	//Now let's check iOS version
	NSArray *supportedFirmwares = [sharedData.opibUpdateCompatibleFirmware allKeys];
	predicate = [NSPredicate predicateWithFormat:@"SELF like %@", sharedData.systemVersion];
	results = [supportedFirmwares filteredArrayUsingPredicate:predicate];
	
	if([results count] < 1) {
		DLog(@"iOS %@ not supported by OpeniBoot! Aborting.", sharedData.systemVersion);
		[commonInstance sendError:[NSString stringWithFormat:@"OpeniBoot is not currently compatible with iOS %@", sharedData.systemVersion]];
		return;
	}
	
	//Ok that's good, now lets see if kernel matches our whitelist of MD5 hashes from various jailbreaks
	NSString *kernelMD5 = [commonInstance fileMD5:@"/System/Library/Caches/com.apple.kernelcaches/kernelcache"];
	
	if(![kernelMD5 isEqualToString:[sharedData.opibUpdateVerifyMD5 objectForKey:sharedData.systemVersion]]) {
		DLog(@"No MD5 matches found, aborting...");
		[commonInstance sendError:@"Kernelcache appears to be incorrectly patched.\r\nReinstall Bootlace."];
		return;
	}*/
	
	
	//[opibInstance opibDecryptIMG3:@"/var/root/iboot.img3" to:@"/var/root/iboot.decrypted" key:@"3470f3841b87b161517588c21534b03b" iv:@"3470f3841b87b161517588c21534b03b"];
	
	//[opibInstance opibGetNORFromManifest];
	//[opibInstance opibGetFirmwareBundle];
	//[opibInstance opibPatchNORFiles];
	[opibInstance opibFlashManifest];
	
	
	//Right now we got that out the way, start a loop and UIProgressBar otherwise some dick will complain nothings happening
	UIAlertView *installView;
	installView = [[[UIAlertView alloc] initWithTitle:@"Installing..." message:@"\r\n\r\n\r\n" delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
	[installView show];
	
		//Hand over to OpeniBootClass
	
	//Reload version
	
	
	//[bgPool release];	
}

- (void)switchButtons {
	if(self.navigationItem.rightBarButtonItem == opibLoadingButton) {
		self.navigationItem.rightBarButtonItem = opibRefreshButton;
	} else {
		self.navigationItem.rightBarButtonItem = opibLoadingButton;
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

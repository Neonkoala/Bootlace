//
//  DroidViewController.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DroidViewController.h"

@implementation DroidViewController

@synthesize tableView, tableRows, viewInitQueue, cfuSpinner, latestVersionButton, installIdroidImage, removeIdroidImage, installIdroidButton, removeIdroidButton;

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

- (void)viewDidLoad {
	[super viewDidLoad];
	
	Class $UIGlassButton = objc_getClass("UIGlassButton");
	
	id commonInstance = [commonFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	//Setup table and contents	
	CGRect tableFrame = CGRectMake(0, 0, 320, 180);
	
	self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:tableView];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	self.tableView.scrollEnabled = NO;
	
	//Fix button appearance and make some nice JB only ones
	[[latestVersionButton layer] setCornerRadius:8.0f];
	
	//Install Button
	installIdroidButton = [[$UIGlassButton alloc] initWithFrame:CGRectMake(90, 242, 220, 50)];
	[installIdroidButton setTitle:@"Install" forState:UIControlStateNormal];
	installIdroidButton.tintColor = [UIColor colorWithRed:0.024 green:0.197 blue:0.419 alpha:1.000];
	[installIdroidButton addTarget:self action:@selector(installIdroid:) forControlEvents:UIControlEventTouchUpInside];
	[installIdroidButton setEnabled:NO];
	[self.view addSubview:installIdroidButton];
	
	//Remove Button
	removeIdroidButton = [[$UIGlassButton alloc] initWithFrame:CGRectMake(90, 305, 220, 50)];
	[removeIdroidButton setTitle:@"Remove" forState:UIControlStateNormal];
	removeIdroidButton.tintColor = [UIColor colorWithRed:0.556 green:0.000 blue:0.000 alpha:1.000];
	[removeIdroidButton addTarget:self action:@selector(removeIdroid:) forControlEvents:UIControlEventTouchUpInside];
	[removeIdroidButton setHidden:YES];
	[self.view addSubview:removeIdroidButton];
	
	[commonInstance checkInstalled];
	
	tableRows = [[NSMutableArray alloc] init];
	
	if(sharedData.installed) {
		NSDictionary *installedSection = [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:
																			 [NSMutableArray arrayWithObjects:@"iDroid Version:", sharedData.installedVer, nil],
																			 [NSMutableArray arrayWithObjects:@"Android Version:", sharedData.installedAndroidVer, nil],
																			 [NSMutableArray arrayWithObjects:@"Date Installed:", sharedData.installedDate, nil],
																			 nil]
																	 forKey:@"Installed"];
		[tableRows addObject:installedSection];
		
		//Set button titles and unhide remove
		[installIdroidButton setTitle:@"Upgrade" forState:UIControlStateNormal];
		[removeIdroidButton setHidden:NO];
		[removeIdroidImage setHidden:NO];
	} else {
		NSDictionary *installedSection = [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:
																			 [NSMutableArray arrayWithObjects:@"iDroid Version:", @"N/A", nil],
																			 [NSMutableArray arrayWithObjects:@"Android Version:", @"N/A", nil],
																			 [NSMutableArray arrayWithObjects:@"Date Installed:", @"N/A", nil],
																			 nil]
																			forKey:@"Installed"];
		[tableRows addObject:installedSection];
		
		[installIdroidButton addTarget:self action:@selector(upgradeIdroid:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	//Make update button spin like it's on LSD
	cfuSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[cfuSpinner setCenter:CGPointMake(140, 18)];
	[cfuSpinner startAnimating];
	[latestVersionButton addSubview:cfuSpinner];
	
	viewInitQueue = [NSOperationQueue new];
	NSInvocationOperation *getUpdate = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(callUpdate) object:nil];
	
	[viewInitQueue addOperation:getUpdate];
    [getUpdate release];
}

- (void)callUpdate {
	id commonInstance = [commonFunctions new];
	
	[commonInstance checkForUpdates];
	
	[self performSelectorOnMainThread:@selector(refreshUpdate) withObject:nil waitUntilDone:YES];
}

- (void)callInstall {
	id commonInstance = [commonFunctions new];
	//***********************************************
	commonData* sharedData = [commonData sharedData];
	//***********************************************
	
	[commonInstance idroidInstall];
	
	//**************************************
	sharedData.installed = YES;
	sharedData.installedVer = @"0.2";
	sharedData.installedAndroidVer = @"1.6";
	sharedData.installedDate = @"20/05/10";
	//**************************************
	
	[self performSelectorOnMainThread:@selector(refreshStatus) withObject:nil waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(refreshUpdate) withObject:nil waitUntilDone:YES];
}

- (void)callUpgrade {
	//This will be implemented in V1.1.1 or later due to upgrade procedure being unknown currently
}

- (void)callRemove {
	id commonInstance = [commonFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	[commonInstance idroidRemove];
	
	sharedData.installed = NO;
	sharedData.installedVer = nil;
	sharedData.installedAndroidVer = nil;
	sharedData.installedDate = nil;
	
	[self performSelectorOnMainThread:@selector(refreshStatus) withObject:nil waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(refreshUpdate) withObject:nil waitUntilDone:NO];
}

- (void)refreshStatus {
	commonData* sharedData = [commonData sharedData];
	
	NSLog(@"%d", sharedData.installed);
	
	if(sharedData.installed) {
		NSDictionary *installedSection = [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:
																			 [NSMutableArray arrayWithObjects:@"iDroid Version:", sharedData.installedVer, nil],
																			 [NSMutableArray arrayWithObjects:@"Android Version:", sharedData.installedAndroidVer, nil],
																			 [NSMutableArray arrayWithObjects:@"Date Installed:", sharedData.installedDate, nil],
																			 nil]
																	 forKey:@"Installed"];
		[tableRows replaceObjectAtIndex:0 withObject:installedSection];
		
		//Setup buttons
		[installIdroidButton setTitle:@"Upgrade" forState:UIControlStateNormal];
		[installIdroidButton addTarget:self action:@selector(upgradeIdroid:) forControlEvents:UIControlEventTouchUpInside];
		[installIdroidButton setEnabled:NO];
		[installIdroidImage setEnabled:NO];
		[removeIdroidButton setHidden:NO];
		[removeIdroidImage setHidden:NO];
	} else {
		NSDictionary *installedSection = [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:
																			 [NSMutableArray arrayWithObjects:@"iDroid Version:", @"N/A", nil],
																			 [NSMutableArray arrayWithObjects:@"Android Version:", @"N/A", nil],
																			 [NSMutableArray arrayWithObjects:@"Date Installed:", @"N/A", nil],
																			 nil]
																	 forKey:@"Installed"];
		[tableRows replaceObjectAtIndex:0 withObject:installedSection];
		
		//Setup buttons
		[installIdroidButton setTitle:@"Install" forState:UIControlStateNormal];
		[installIdroidButton addTarget:self action:@selector(installIdroid:) forControlEvents:UIControlEventTouchUpInside];
		[installIdroidButton setEnabled:YES];
		[installIdroidImage setEnabled:YES];
		[removeIdroidButton setHidden:YES];
		[removeIdroidImage setHidden:YES];
	}
	
	[self.tableView reloadData];
}

- (void)refreshUpdate {
	commonData* sharedData = [commonData sharedData];
	
	//if statement to check latest version
	[cfuSpinner stopAnimating];
	[cfuSpinner release];
	
	if([sharedData.updateVer isEqualToString: sharedData.installedVer]) {
		[latestVersionButton setTitle:@"Latest Version Installed" forState:UIControlStateNormal];
		[installIdroidButton setEnabled:NO];
		[installIdroidImage setEnabled:NO];
	} else if(!sharedData.installed) {
		NSString *updateButtonLabel = @"Version available to install: ";
		updateButtonLabel = [updateButtonLabel stringByAppendingString:sharedData.updateVer];
		[latestVersionButton setTitle:updateButtonLabel forState:UIControlStateNormal];
		[installIdroidButton setEnabled:YES];
		[installIdroidImage setEnabled:YES];
	} else {
		NSString *updateButtonLabel = @"New version available: ";
		updateButtonLabel = [updateButtonLabel stringByAppendingString:sharedData.updateVer];
		[latestVersionButton setTitle:updateButtonLabel forState:UIControlStateNormal];
		[installIdroidButton setEnabled:YES];
		[installIdroidImage setEnabled:YES];
	}
}

- (IBAction)checkForUpdatesManual:(id)sender {
	[latestVersionButton setTitle:@"" forState:UIControlStateNormal];
	cfuSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[cfuSpinner setCenter:CGPointMake(140, 18)];
	[cfuSpinner startAnimating];
	[latestVersionButton addSubview:cfuSpinner];
	
	NSInvocationOperation *getUpdate = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(callUpdate) object:nil];
	
	[viewInitQueue addOperation:getUpdate];
    [getUpdate release];
}

- (IBAction)installIdroid:(id)sender {
	[latestVersionButton setTitle:@"" forState:UIControlStateNormal];
	cfuSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[cfuSpinner setCenter:CGPointMake(140, 18)];
	[cfuSpinner startAnimating];
	[latestVersionButton addSubview:cfuSpinner];
	
	NSDictionary *installedSection = [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:
																		 [NSMutableArray arrayWithObjects:@"iDroid Version:", @"loading", nil],
																		 [NSMutableArray arrayWithObjects:@"Android Version:", @"loading", nil],
																		 [NSMutableArray arrayWithObjects:@"Date Installed:", @"loading", nil],
																		 nil]
																 forKey:@"Installed"];
	[tableRows replaceObjectAtIndex:0 withObject:installedSection];
	
	[self.tableView reloadData];
	
	NSInvocationOperation *getInstall = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(callInstall) object:nil];
	
	[viewInitQueue addOperation:getInstall];
    [getInstall release];
}

- (IBAction)upgradeIdroid:(id)sender {
	//This will be implemented in V1.1.1 or later due to upgrade procedure being unknown currently
}

- (IBAction)removeIdroid:(id)sender {
	[latestVersionButton setTitle:@"" forState:UIControlStateNormal];
	cfuSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[cfuSpinner setCenter:CGPointMake(140, 18)];
	[cfuSpinner startAnimating];
	[latestVersionButton addSubview:cfuSpinner];
	
	NSDictionary *installedSection = [NSDictionary dictionaryWithObject:[NSMutableArray arrayWithObjects:
																		 [NSMutableArray arrayWithObjects:@"iDroid Version:", @"loading", nil],
																		 [NSMutableArray arrayWithObjects:@"Android Version:", @"loading", nil],
																		 [NSMutableArray arrayWithObjects:@"Date Installed:", @"loading", nil],
																		 nil]
																 forKey:@"Installed"];
	[tableRows replaceObjectAtIndex:0 withObject:installedSection];
	
	[self.tableView reloadData];
	
	NSInvocationOperation *getRemove = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(callRemove) object:nil];
	
	[viewInitQueue addOperation:getRemove];
    [getRemove release];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *installedSection = [tableRows objectAtIndex:section];
	NSArray *installedRows = [installedSection objectForKey:@"Installed"];
	return [installedRows count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *sectionHeader = nil;
	
	if(section == 0) {
		sectionHeader = @"Currently Installed:";
	}	
	
	return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:self.tableView titleForHeaderInSection:section] != nil) {
        return 40;
    }
    else {
        // If no section header title, no section header needed
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:self.tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
	
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 0, 300, 40);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.text = sectionTitle;
	
    // Create header view and add label as a subview
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [headerView autorelease];
    [headerView addSubview:label];
	
    return headerView;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	
	cell.opaque = NO;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
	
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
	
	//cell.textLabel.text = [[tableRows objectAtIndex: indexPath.row] valueForKey:labelKey];
	
	NSDictionary *installedSection = [tableRows objectAtIndex:indexPath.section];
	NSArray *installedRows = [installedSection objectForKey:@"Installed"];
	NSArray *cellArray = [installedRows objectAtIndex:indexPath.row];
	NSString *cellTitle = [cellArray objectAtIndex:0];
	NSString *cellValue = [cellArray objectAtIndex:1];
	cell.textLabel.text = cellTitle;
	
	if([cellValue isEqualToString:@"loading"]) {
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[spinner setCenter:CGPointMake(277, 22)];
		[spinner startAnimating];
		[cell.contentView addSubview:spinner];
	} else {
		UILabel *varLabel;
		CGRect frame = CGRectMake(190.0, 8.0, 94.0, 29.0);
		varLabel = [[UILabel alloc] initWithFrame:frame];
		varLabel.backgroundColor = [UIColor clearColor];
		varLabel.textAlignment = UITextAlignmentRight;
		varLabel.text = cellValue;
		varLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	
		[cell.contentView addSubview:varLabel];
    }
	
	return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}
*/

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


- (void)dealloc {
    [super dealloc];
}


@end

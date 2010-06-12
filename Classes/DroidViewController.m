//
//  DroidViewController.m
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "DroidViewController.h"

static NSString *idKey = @"idKey";
static NSString *labelKey = @"labelKey";
static NSString *valKey = @"valKey";

@implementation DroidViewController

@synthesize tableView, tableSections, tableRows, cfuSpinner, latestVersionButton;

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

- (IBAction)checkForUpdatesManual:(id)sender {
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//id commonInstance = [commonFunctions new];
	//commonData* sharedData = [commonData sharedData];
	//int success;
	
	//Setup table and contents	
	CGRect tableFrame = CGRectMake(0, 0, 320, 180);
	
	self.tableView = [[[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped] autorelease];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	self.tableView.scrollEnabled = NO;
	
	tableRows = [NSArray arrayWithObjects:
						  [NSDictionary dictionaryWithObjectsAndKeys:
						   @"idroidVer", idKey,
						   @"iDroid Version:", labelKey,
						   @"loading", valKey,
						   nil],
						  [NSDictionary dictionaryWithObjectsAndKeys:
						   @"androidVer", idKey,
						   @"Android Version:", labelKey,
						   @"loading", valKey,
						   nil],
						  [NSDictionary dictionaryWithObjectsAndKeys:
						   @"installDate", idKey,
						   @"Date Installed:", labelKey,
						   @"loading", valKey,
						   nil],
						  nil];
	
	//Make update button spin like it's on LSD
	cfuSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[cfuSpinner setCenter:CGPointMake(140, 18)];
	[cfuSpinner startAnimating];
	[latestVersionButton addSubview:cfuSpinner];
	
	[self initInstallData];	
}

- (void)initInstallData {
	//Check for updates and load installed plist
	NSOperationQueue *viewInitQueue = [NSOperationQueue new];
	NSInvocationOperation *getUpdate = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(callUpdate) object:nil];
	
	[viewInitQueue addOperation:getUpdate];
    [getUpdate release];
}

- (void)callUpdate {
	id commonInstance = [commonFunctions new];
	commonData* sharedData = [commonData sharedData];
	
	[commonInstance checkForUpdates];
	//[commonInstance parseInstalled];
	
	sharedData.installedVer = @"0.2";
	sharedData.installedAndroidVer = @"1.6";
	sharedData.installedDate = @"20/05/10";
	
	tableRows = [NSArray arrayWithObjects:
				 [NSDictionary dictionaryWithObjectsAndKeys:
				  @"idroidVer", idKey,
				  @"iDroid Version:", labelKey,
				  sharedData.installedVer, valKey,
				  nil],
				 [NSDictionary dictionaryWithObjectsAndKeys:
				  @"androidVer", idKey,
				  @"Android Version:", labelKey,
				  sharedData.installedAndroidVer, valKey,
				  nil],
				 [NSDictionary dictionaryWithObjectsAndKeys:
				  @"installDate", idKey,
				  @"Date Installed:", labelKey,
				  sharedData.installedDate, valKey,
				  nil],
				 nil];
	
	[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	
	//if statement to check latest version
	[cfuSpinner stopAnimating];
	[cfuSpinner removeFromSuperview];
	
	if([sharedData.updateVer isEqualToString: sharedData.installedVer]) {
		[latestVersionButton setTitle:@"Latest Version Installed" forState:UIControlStateNormal];
	} else {
		NSString *updateButtonLabel = @"New version available: ";
		updateButtonLabel = [updateButtonLabel stringByAppendingString:sharedData.updateVer];
		[latestVersionButton setTitle:updateButtonLabel forState:UIControlStateNormal];
	}
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
	tableSections =  [[NSArray arrayWithObjects:@"Installed", nil] retain];
	
	return [tableSections count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [tableRows count];
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
	
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idKey];
	
	cell.opaque = NO;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
	
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.textLabel.textColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
	
	cell.textLabel.text = [[tableRows objectAtIndex: indexPath.row] valueForKey:labelKey];
	
	if([[tableRows objectAtIndex: indexPath.row] valueForKey:valKey]==@"loading") {
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
		varLabel.text = [[tableRows objectAtIndex: indexPath.row] valueForKey:valKey];
		varLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
	
		[cell.contentView addSubview:varLabel];
    }
		
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


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

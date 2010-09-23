//
//  OpeniBootViewController.m
//  BootlaceV2
//
//  Created by Neonkoala on 23/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import "OpeniBootViewController.h"


@implementation OpeniBootViewController

@synthesize tableRows;


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
	
	tableRows = [[NSMutableArray alloc] init];
	
	NSMutableArray *installSection = [[NSMutableArray alloc] init];
	NSMutableArray *configureSection = [[NSMutableArray alloc] init];
	
	OpeniBootInstallViewController *installViewController = [[OpeniBootInstallViewController alloc] initWithNibName:@"OpeniBootInstallViewController" bundle:nil];
	OpeniBootConfigureViewController *configureViewController = [[OpeniBootConfigureViewController alloc] initWithNibName:@"OpeniBootConfigureViewController" bundle:nil];
	
	[installSection addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Install", @"title", installViewController, @"viewController", nil]];
	[configureSection addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Configure", @"title", configureViewController, @"viewController", nil]];
	
	[tableRows addObject:installSection];
	[tableRows addObject:configureSection];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableRows count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[tableRows objectAtIndex:section] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *currentSection = [tableRows objectAtIndex:indexPath.section];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultIdentifier"];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultIdentifier"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [[currentSection objectAtIndex:indexPath.row] objectForKey:@"title"];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *currentSection = [tableRows objectAtIndex:indexPath.section];
	UIViewController *targetViewController = [[currentSection objectAtIndex: indexPath.row] objectForKey:@"viewController"];
	[[self navigationController] pushViewController:targetViewController animated:YES];
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


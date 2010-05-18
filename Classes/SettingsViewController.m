//
//  RootViewController.m
//  Bootlace
//
//  Created by Neonkoala on 11/05/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SettingsViewController.h"

static NSString *nameKey = @"nameKey";
static NSString *labelKey = @"labelKey";
static NSString *typeKey = @"typeKey";
static NSString *viewKey = @"viewKey";

@implementation SettingsViewController

@synthesize settingsArray, applyButton, iphoneosImage, iphoneosLabel, androidImage, androidLabel, consoleImage, consoleLabel;

- (IBAction) tapIphoneos:(id)sender {
	iphoneosImage.alpha = 1.0;
	iphoneosLabel.alpha = 1.0;
	androidImage.alpha = 0.4;
	androidLabel.alpha = 0.4;
	consoleImage.alpha = 0.4;
	consoleLabel.alpha = 0.4;
	
	commonData *sharedData = [commonData sharedData];
	sharedData.opibDefaultOS = @"0";
}

- (IBAction) tapAndroid:(id)sender {
	iphoneosImage.alpha = 0.4;
	iphoneosLabel.alpha = 0.4;
	androidImage.alpha = 1.0;
	androidLabel.alpha = 1.0;
	consoleImage.alpha = 0.4;
	consoleLabel.alpha = 0.4;
	
	commonData *sharedData = [commonData sharedData];
	sharedData.opibDefaultOS = @"1";
}

- (IBAction) tapConsole:(id)sender {
	iphoneosImage.alpha = 0.4;
	iphoneosLabel.alpha = 0.4;
	androidImage.alpha = 0.4;
	androidLabel.alpha = 0.4;
	consoleImage.alpha = 1.0;
	consoleLabel.alpha = 1.0;
	
	commonData *sharedData = [commonData sharedData];
	sharedData.opibDefaultOS = @"2";
}

- (IBAction)tapApply:(id)sender {
	id commonInstance = [commonFunctions new];
	
	[commonInstance sendConfirmation:@"This will apply the current settings.\r\nContinue?" withTag:7];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Settings";
	UIImage *buttonImage = [UIImage imageNamed:@"button_blue.png"];
	UIImage *stretchableButtonImage = [buttonImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	[applyButton setBackgroundImage:stretchableButtonImage forState:UIControlStateNormal];
	
	commonData *sharedData = [commonData sharedData];
	
	self.settingsArray = [NSArray arrayWithObjects:
						   [NSDictionary dictionaryWithObjectsAndKeys:
							@"autoBoot", nameKey,
							@"Boot Default OS", labelKey,
							@"switch", typeKey,
							self.switchCtl, viewKey,
							nil],
						   [NSDictionary dictionaryWithObjectsAndKeys:
							@"timeout", nameKey,
							@"Timeout", labelKey,
							@"labelWithVar", typeKey,
							self.labelWithVar, viewKey,
							nil],
						   [NSDictionary dictionaryWithObjectsAndKeys:
							@"timeoutSlider", nameKey,
							@"", labelKey,
							@"slider", typeKey,
							self.sliderCtl, viewKey,
							nil],
						   [NSDictionary dictionaryWithObjectsAndKeys:
							@"advanced", nameKey,
							@"Advanced", labelKey,
							@"link", typeKey,
							self.linkButton, viewKey,
							nil],
						  nil];
	
	sliderCtl.value = [sharedData.opibTimeout intValue] / 1000;	
	labelWithVar.text = [NSString stringWithFormat:@"%d", [sharedData.opibTimeout intValue] / 1000];
	labelWithVar.text = [labelWithVar.text stringByAppendingString:@" Seconds"];
	
	switch ([sharedData.opibDefaultOS intValue]) {
		case 0:
			iphoneosImage.alpha = 1.0;
			iphoneosLabel.alpha = 1.0;
			break;
		case 1:
			androidImage.alpha = 1.0;
			androidLabel.alpha = 1.0;
			break;
		case 2:
			consoleImage.alpha = 1.0;
			consoleLabel.alpha = 1.0;
			break;
			
		default:
			iphoneosImage.alpha = 1.0;
			iphoneosLabel.alpha = 1.0;
			NSLog(@"Default OS setting invalid. Defaulting to iPhone OS.");
	}
	
	if(([sharedData.opibTimeout intValue]/1000)==0){
		switchCtl.on = NO;
		sliderCtl.enabled = NO;
	} else {
		switchCtl.on = YES;
		sliderCtl.enabled = YES;
	}
	
	
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	commonData *sharedData = [commonData sharedData];
	
	sliderCtl.value = [sharedData.opibTimeout intValue] / 1000;	
	labelWithVar.text = [NSString stringWithFormat:@"%d", [sharedData.opibTimeout intValue] / 1000];
	labelWithVar.text = [labelWithVar.text stringByAppendingString:@" Seconds"];
	
	switch ([sharedData.opibDefaultOS intValue]) {
		case 0:
			iphoneosImage.alpha = 1.0;
			iphoneosLabel.alpha = 1.0;
			androidImage.alpha = 0.4;
			androidLabel.alpha = 0.4;
			consoleImage.alpha = 0.4;
			consoleLabel.alpha = 0.4;
			break;
		case 1:
			iphoneosImage.alpha = 0.4;
			iphoneosLabel.alpha = 0.4;
			androidImage.alpha = 1.0;
			androidLabel.alpha = 1.0;
			consoleImage.alpha = 0.4;
			consoleLabel.alpha = 0.4;
			break;
		case 2:
			iphoneosImage.alpha = 0.4;
			iphoneosLabel.alpha = 0.4;
			androidImage.alpha = 0.4;
			androidLabel.alpha = 0.4;
			consoleImage.alpha = 1.0;
			consoleLabel.alpha = 1.0;
			break;
			
		default:
			iphoneosImage.alpha = 1.0;
			iphoneosLabel.alpha = 1.0;
			androidImage.alpha = 0.4;
			androidLabel.alpha = 0.4;
			consoleImage.alpha = 0.4;
			consoleLabel.alpha = 0.4;
			NSLog(@"Default OS setting invalid. Defaulting to iPhone OS.");
	}
	
	if(([sharedData.opibTimeout intValue]/1000)==0){
		switchCtl.on = NO;
		sliderCtl.enabled = NO;
	} else {
		switchCtl.on = YES;
		sliderCtl.enabled = YES;
	}
}

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
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[switchCtl release];
    switchCtl = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [settingsArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	cell = [self.tableView dequeueReusableCellWithIdentifier:nameKey];

	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nameKey];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
	cell.textLabel.text = [[self.settingsArray objectAtIndex: indexPath.row] valueForKey:labelKey];
			
	UIControl *control = [[self.settingsArray objectAtIndex: indexPath.row] valueForKey:viewKey];
	[cell.contentView addSubview:control];
	
	return cell;
}

//Switch toggle function
- (UISwitch *)switchCtl
{
    if (switchCtl == nil)
    {
        CGRect frame = CGRectMake(198.0, 9.0, 94.0, 27.0);
        switchCtl = [[UISwitch alloc] initWithFrame:frame];
        [switchCtl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        switchCtl.backgroundColor = [UIColor clearColor];
		
		[switchCtl setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];
    }
    return switchCtl;
}

//Label with corresponding variable display
- (UILabel *)labelWithVar
{
	if (labelWithVar == nil) {
		CGRect frame = CGRectMake(200.0, 8.0, 94.0, 29.0);
		labelWithVar = [[UILabel alloc] initWithFrame:frame];
	}
	labelWithVar.textAlignment = UITextAlignmentRight;
	labelWithVar.text = @"X Seconds";
	return labelWithVar;
}

//Full width slider
- (UISlider *)sliderCtl
{
    if (sliderCtl == nil) 
    {
        CGRect frame = CGRectMake(10.0, 12.0, 280.0, 7.0);
        sliderCtl = [[UISlider alloc] initWithFrame:frame];
        [sliderCtl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        sliderCtl.backgroundColor = [UIColor clearColor];
        
        sliderCtl.minimumValue = 3.0;
        sliderCtl.maximumValue = 30.0;
        sliderCtl.continuous = YES;
        sliderCtl.value = 10.0;
		sliderCtl.enabled = NO;
    }
    return sliderCtl;
}

//Button linking to view
- (UIButton *)linkButton
{
	if (linkButton == nil)
	{
		// create a UIButton (UIButtonTypeDetailDisclosure)
		linkButton = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain];
		linkButton.frame = CGRectMake(265.0, 8.0, 25.0, 25.0);
		[linkButton setTitle:@"Advanced" forState:UIControlStateNormal];
		linkButton.backgroundColor = [UIColor clearColor];
		[linkButton addTarget:self action:@selector(loadAdvanced:) forControlEvents:UIControlEventTouchUpInside];
	}
	return linkButton;
}

//Switch Action
- (void)switchAction:(id)sender
{
	commonData *sharedData = [commonData sharedData];
	
	if(switchCtl.on) {
		sliderCtl.enabled = YES;
		sharedData.opibTimeout = [NSString stringWithFormat:@"%1.0f", (sliderCtl.value * 1000)];
	} else {
		sliderCtl.enabled = NO;
		sharedData.opibTimeout = @"0";
	}
}

- (void)sliderAction:(id)sender
{
	commonData *sharedData = [commonData sharedData];
	labelWithVar.text = [NSString stringWithFormat:@"%1.0f", sliderCtl.value];
	labelWithVar.text = [labelWithVar.text stringByAppendingString:@" Seconds"];
	sliderCtl.value = round(1.0f * sliderCtl.value);
	
	sharedData.opibTimeout = [NSString stringWithFormat:@"%1.0f", (sliderCtl.value * 1000)];
}

- (void)loadAdvanced:(id)sender
{
	AdvancedViewController *advancedView = [[AdvancedViewController alloc] initWithNibName:@"AdvancedViewController" bundle:nil];
	[self.navigationController pushViewController:advancedView animated:YES];
	[advancedView release];
}

/*
// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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


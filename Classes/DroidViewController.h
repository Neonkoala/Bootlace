//
//  DroidViewController.h
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commonData.h"
#import "commonFunctions.h"


@interface DroidViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>  {
	UITableView *tableView;
	NSArray *tableSections;
	NSArray *tableRows;
	UIActivityIndicatorView *cfuSpinner;
	UIButton *latestVersionButton;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *tableSections;
@property (nonatomic, retain) NSArray *tableRows;
@property (nonatomic, retain) UIActivityIndicatorView *cfuSpinner;
@property (nonatomic, retain) IBOutlet UIButton *latestVersionButton;

- (IBAction)checkForUpdatesManual:(id)sender;
- (void)initInstallData;
- (void)callUpdate;
- (void)callUpdateManual;

@end

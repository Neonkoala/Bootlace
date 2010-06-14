//
//  DroidViewController.h
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "UIGlassButton.h"
#import "commonData.h"
#import "commonFunctions.h"


@interface DroidViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>  {
	UITableView *tableView;
	NSMutableArray *tableRows;
	NSOperationQueue *viewInitQueue;
	UIActivityIndicatorView *cfuSpinner;
	UIButton *latestVersionButton;
	UIGlassButton *installIdroidButton;
	UIGlassButton *removeIdroidButton;
	UIButton *installIdroidImage;
	UIButton *removeIdroidImage;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *tableRows;
@property (nonatomic, retain) NSOperationQueue *viewInitQueue;
@property (nonatomic, retain) UIActivityIndicatorView *cfuSpinner;
@property (nonatomic, retain) UIGlassButton *installIdroidButton;
@property (nonatomic, retain) UIGlassButton *removeIdroidButton;
@property (nonatomic, retain) IBOutlet UIButton *latestVersionButton;
@property (nonatomic, retain) IBOutlet UIButton *installIdroidImage;
@property (nonatomic, retain) IBOutlet UIButton *removeIdroidImage;

- (IBAction)checkForUpdatesManual:(id)sender;
- (IBAction)installIdroid:(id)sender;
- (IBAction)upgradeIdroid:(id)sender;
- (IBAction)removeIdroid:(id)sender;
- (void)callUpdate;
- (void)callInstall;
- (void)callUpgrade;
- (void)callRemove;
- (void)refreshUpdate;
- (void)refreshStatus;

@end

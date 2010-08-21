//
//  DroidViewController.h
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright Nick Dawson 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <UIKit/UIGlassButton.h>
#import "commonData.h"
#import "commonFunctions.h"
#import "installClass.h"

@class installClass;
@class commonFunctions;

@interface DroidViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>  {
	installClass *installInstance;
	commonFunctions *commonInstance;
	
	UITableView *tableView;
	NSMutableArray *tableRows;
	NSOperationQueue *viewInitQueue;
	UIActivityIndicatorView *cfuSpinner;
	UIProgressView *installProgress;
	UIButton *latestVersionButton;
	UIGlassButton *installIdroidButton;
	UIGlassButton *removeIdroidButton;
	UIButton *installIdroidImage;
	UIButton *removeIdroidImage;
}

@property (nonatomic, retain) installClass *installInstance;
@property (nonatomic, retain) commonFunctions *commonInstance;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *tableRows;
@property (nonatomic, retain) NSOperationQueue *viewInitQueue;
@property (nonatomic, retain) UIActivityIndicatorView *cfuSpinner;
@property (nonatomic, retain) UIProgressView *installProgress;
@property (nonatomic, retain) UIGlassButton *installIdroidButton;
@property (nonatomic, retain) UIGlassButton *removeIdroidButton;
@property (nonatomic, retain) IBOutlet UIButton *latestVersionButton;
@property (nonatomic, retain) IBOutlet UIButton *installIdroidImage;
@property (nonatomic, retain) IBOutlet UIButton *removeIdroidImage;

- (IBAction)checkForUpdatesManual:(id)sender;
- (IBAction)upgradeIdroid:(id)sender;
- (IBAction)installPress:(id)sender;
- (IBAction)removePress:(id)sender;
- (void)installIdroid;
- (void)removeIdroid;
- (void)callUpdate;
- (void)callInstall;
- (void)callUpgrade;
- (void)callRemove;
- (void)refreshUpdate;
- (void)refreshStatus;

@end

//
//  OpeniBootViewController.h
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commonData.h"
#import "commonFunctions.h"
#import "OpeniBootClass.h"
#import "OpeniBootConfigureViewController.h"


@interface OpeniBootViewController : UIViewController {
	commonFunctions *commonInstance;
	OpeniBootClass *opibInstance;
	
	NSOperationQueue *viewInitQueue;
	
	UIBarButtonItem *opibLoadingButton;
	UIBarButtonItem *opibRefreshButton;
	UILabel *opibVersionLabel;
	UILabel *opibReleaseDateLabel;
	UIGlassButton *opibInstall;
	UIGlassButton *opibConfigure;
	UIActivityIndicatorView *cfuSpinner;
}

@property (nonatomic, retain) NSOperationQueue *viewInitQueue;

@property (nonatomic, retain) UIBarButtonItem *opibLoadingButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *opibRefreshButton;
@property (nonatomic, retain) IBOutlet UILabel *opibVersionLabel;
@property (nonatomic, retain) IBOutlet UILabel *opibReleaseDateLabel;
@property (nonatomic, retain) IBOutlet UIGlassButton *opibInstall;
@property (nonatomic, retain) IBOutlet UIGlassButton *opibConfigure;
@property (nonatomic, retain) UIActivityIndicatorView *cfuSpinner;

- (IBAction)opibRefreshTap:(id)sender;
- (IBAction)opibInstallTap:(id)sender;
- (IBAction)opibConfigureTap:(id)sender;

- (void)opibUpdateCheck;
- (void)opibDoInstall;
- (void)switchButtons;

@end

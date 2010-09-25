//
//  OpeniBootViewController.h
//  BootlaceV2
//
//  Created by Neonkoala on 25/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commonFunctions.h"
#import "OpeniBootConfigureViewController.h"


@interface OpeniBootViewController : UIViewController {
	UIGlassButton *opibInstall;
	UIGlassButton *opibConfigure;

}

@property (nonatomic, retain) IBOutlet UIGlassButton *opibInstall;
@property (nonatomic, retain) IBOutlet UIGlassButton *opibConfigure;

- (IBAction)opibInstallTap:(id)sender;
- (IBAction)opibConfigureTap:(id)sender;

@end

//
//  DroidAdvancedViewController.h
//  BootlaceV2
//
//  Created by Neonkoala on 23/08/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commonData.h"
#import "commonFunctions.h"
#import "installClass.h"

@class commonFunctions;
@class installClass;

@interface DroidAdvancedViewController : UIViewController <UIActionSheetDelegate> {
	installClass *installInstance;
	commonFunctions *commonInstance;
	
	UIGlassButton *multitouchInstall;
	UIGlassButton *wifiInstall;
}

@property (nonatomic, retain) installClass *installInstance;
@property (nonatomic, retain) commonFunctions *commonInstance;

@property (nonatomic, retain) IBOutlet UIGlassButton *multitouchInstall;
@property (nonatomic, retain) IBOutlet UIGlassButton *wifiInstall;

- (IBAction)extractMultitouch:(id)sender;
- (IBAction)downloadWifi:(id)sender;
- (void)dumpZephyr;
- (void)getWifi;

@end

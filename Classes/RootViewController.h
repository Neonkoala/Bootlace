//
//  RootViewController.h
//  Bootlace
//
//  Created by Neonkoala on 14/05/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import <UIKit/UIKit.h>


@interface RootViewController : UIViewController {
	UIView *aboutView;
	UIBarButtonItem *backButton;
	UIBarButtonItem *aboutButton;
	UIBarButtonItem *settingsButton;
}

@property (nonatomic, retain) IBOutlet UIView *aboutView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *aboutButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsButton;

- (IBAction)aboutTap:(id)sender;
- (IBAction)settingsTap:(id)sender;
- (IBAction)rebootToAndroid:(id)sender;
- (IBAction)rebootToConsole:(id)sender;

@end

//
//  SettingsViewController.h
//  Bootlace
//
//  Created by Neonkoala on 11/05/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AdvancedViewController.h"
#import "commonData.h"
#import "commonFunctions.h"

@interface SettingsViewController : UITableViewController {
	NSArray *settingsArray;
	
	IBOutlet UIButton *applyButton;
	IBOutlet UILabel *iphoneosLabel;
	IBOutlet UIButton *iphoneosImage;
	IBOutlet UILabel *androidLabel;
	IBOutlet UIButton *androidImage;
	IBOutlet UILabel *consoleLabel;
	IBOutlet UIButton *consoleImage;
	
	UISwitch *switchCtl;
	UILabel *labelWithVar;
	UISlider *sliderCtl;
	UIButton *linkButton;
}

@property (nonatomic, retain) NSArray *settingsArray;
@property (nonatomic, retain, readonly) UIButton *applyButton;
@property (nonatomic, retain, readonly) UILabel *iphoneosLabel;
@property (nonatomic, retain, readonly) UIButton *iphoneosImage;
@property (nonatomic, retain, readonly) UILabel *androidLabel;
@property (nonatomic, retain, readonly) UIButton *androidImage;
@property (nonatomic, retain, readonly) UILabel *consoleLabel;
@property (nonatomic, retain, readonly) UIButton *consoleImage;
@property (nonatomic, retain, readonly) UISwitch *switchCtl;
@property (nonatomic, retain, readonly) UILabel *labelWithVar;
@property (nonatomic, retain, readonly) UISlider *sliderCtl;
@property (nonatomic, retain, readonly) UIButton *linkButton;

- (IBAction) tapIphoneos:(id)sender;
- (IBAction) tapAndroid:(id)sender;
- (IBAction) tapConsole:(id)sender;
- (IBAction) tapApply:(id)sender;

@end

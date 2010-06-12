//
//  SettingsViewController.h
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commonData.h"
#import "commonFunctions.h"


@interface SettingsViewController : UITableViewController {
	NSArray *tableSections;
	NSArray *tableRows;
}

@property (nonatomic, retain) NSArray *tableSections;
@property (nonatomic, retain) NSArray *tableRows;

@end

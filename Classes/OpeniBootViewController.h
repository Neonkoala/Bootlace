//
//  OpeniBootViewController.h
//  BootlaceV2
//
//  Created by Neonkoala on 23/09/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpeniBootInstallViewController.h"
#import "OpeniBootConfigureViewController.h"


@interface OpeniBootViewController : UITableViewController {
	NSMutableArray *tableRows;

}

@property (nonatomic, retain) NSMutableArray *tableRows;

@end

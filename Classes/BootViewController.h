//
//  BootViewController.h
//  Bootlace
//
//  Created by Neonkoala on 07/06/2010.
//  Copyright 2010 Neonkoala.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commonData.h"
#import "commonFunctions.h"


@interface BootViewController : UIViewController {
	UIView *quickBootAboutView;
	UIBarButtonItem *doneButton;
	UIBarButtonItem *flipButton;
}

@property (nonatomic, retain) IBOutlet UIView *quickBootAboutView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *flipButton;

- (void)flipAction:(id)sender;

@end

//
//  BootlaceAppDelegate.h
//  Bootlace
//
//  Created by Neonkoala on 11/05/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "commonData.h"
#import "commonFunctions.h"
#import <UIKit/UIKit.h>

@interface BootlaceAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end


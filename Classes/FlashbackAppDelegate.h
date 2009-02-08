//
//  FlashbackAppDelegate.h
//  Flashback
//
//  Created by Stuart Carnie on 1/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmulationViewController;

@interface FlashbackAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	EmulationViewController		*emulationController;
	UITabBarController			*mainController;
}

@property (nonatomic, retain) IBOutlet UIWindow					*window;
@property (nonatomic, retain) IBOutlet UITabBarController		*mainController;
@property (nonatomic, retain) IBOutlet EmulationViewController	*emulationController;

@end


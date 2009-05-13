//
//  ControlPanelViewController.h
//  Flashback
//
//  Created by Stuart Carnie on 4/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SaveGameBrowserController;
struct iPhoneStub;
@class ImageBarControl;
@class CreditsViewController;
@class EmulationViewController;
@class SideMenuController;

@interface ControlPanelViewController : UIViewController {
	BOOL							_isOpen;
	ImageBarControl					*_imageBar;
	SaveGameBrowserController		*_gameList;
	CreditsViewController			*_credits;
	BOOL							_isCreditsInitialized;
	iPhoneStub						*_stub;
	BOOL							_reloadTable;
	
	UILabel							*_caption;
	
	EmulationViewController			*_emulationController;
	SideMenuController				*_sidePanel;
	BOOL							_itemsVisible;
}

@property(nonatomic, assign)			iPhoneStub					*stub;
@property(nonatomic, retain)			EmulationViewController		*emulationController;
@property(nonatomic, retain)			SideMenuController			*sidePanel;
@property(nonatomic)					BOOL						itemsVisible;

@property(nonatomic, retain) IBOutlet	CreditsViewController		*credits;
@property(nonatomic, retain) IBOutlet	SaveGameBrowserController	*gameList;
@property(nonatomic, retain) IBOutlet	UILabel						*caption;

- (IBAction)hideShowControlPanel:(id)sender;

@end

#define kControlPanelWidth					406
#define kControlPanelFrameNormal			CGRectMake(453, 0, kControlPanelWidth, 320)
#define kControlPanelFrameFullScreen		CGRectMake(480, 0, kControlPanelWidth, 320)
#define kControlPanelOpenFrame				CGRectMake(73, 0, kControlPanelWidth, 320)


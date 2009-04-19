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

@interface ControlPanelViewController : UIViewController {
	BOOL							_isOpen;
	ImageBarControl					*_imageBar;
	SaveGameBrowserController		*_gameList;
	CreditsViewController			*_credits;
	iPhoneStub						*_stub;
	BOOL							_reloadTable;
	
	UILabel							*_caption;
}

@property(nonatomic, assign)			iPhoneStub					*stub;
@property(nonatomic, retain) IBOutlet	CreditsViewController		*credits;
@property(nonatomic, retain) IBOutlet	SaveGameBrowserController	*gameList;
@property(nonatomic, retain) IBOutlet	UILabel						*caption;

- (IBAction)hideShowControlPanel:(id)sender;

@end

#define kControlPanelWidth					406
#define kControlPanelFrame					CGRectMake(453, 0, kControlPanelWidth, 320)
#define kControlPanelOpenFrame				CGRectMake(73, 0, kControlPanelWidth, 320)


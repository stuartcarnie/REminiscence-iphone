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

@interface ControlPanelViewController : UIViewController {
	BOOL							_isOpen;
	ImageBarControl					*_imageBar;
	SaveGameBrowserController		*_gameList;
	iPhoneStub						*_stub;
	BOOL							_reloadTable;
}

@property(nonatomic, assign)		iPhoneStub *stub;

- (IBAction)hideShowControlPanel:(id)sender;

@end

#define kControlPanelWidth					406
#define kControlPanelFrame					CGRectMake(453, 0, kControlPanelWidth, 320)
#define kControlPanelOpenFrame				CGRectMake(73, 0, kControlPanelWidth, 320)


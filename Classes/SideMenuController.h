//
//  SideMenuController.h
//  Flashback
//
//  Created by Stuart Carnie on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

class iPhoneStub;

@interface SideMenuController : UIViewController {
	iPhoneStub						*_stub;
	UIButton						*_fullScreen;
}

@property(nonatomic, assign)			iPhoneStub					*stub;
@property(nonatomic, retain) IBOutlet	UIButton					*fullScreen;

- (IBAction)restartGame:(id)sender;
- (IBAction)toggleFullScreen:(UIButton*)sender;

@end

#define kSidePanelWidth					93
#define kSidePanelFrameHidden			CGRectMake(-kSidePanelWidth, 0, kSidePanelWidth, 320)
#define kSidePanelFramePartial			CGRectMake(-kSidePanelWidth + 15, 0, kSidePanelWidth, 320)
#define kSidePanelFrameVisible			CGRectMake(0, 0, kSidePanelWidth, 320)

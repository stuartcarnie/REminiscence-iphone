//
//  ControlPanelViewController.h
//  Flashback
//
//  Created by Stuart Carnie on 4/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ControlPanelViewController : UIViewController {
	BOOL			_isOpen;
}

-(IBAction)hideShowControlPanel:(id)sender;

@end

#define kControlPanelFrame					CGRectMake(453, 0, 406, 320)
#define kControlPanelOpenFrame				CGRectMake(73, 0, 406, 320)


//
//  GameControlsView.h
//  Flashback
//
//  Created by Stuart Carnie on 3/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

class CJoyStick;
class PlayerInput;

@interface GameControlsView : UIView {
	PlayerInput							*playerInput;
	CJoyStick							*TheJoyStick;
}

@property (nonatomic, assign) PlayerInput		*playerInput;
@property (nonatomic, assign) CJoyStick			*TheJoyStick;

-(IBAction)fireButton:(UIButton*)sender;
-(IBAction)itemsButton:(id)sender;
-(IBAction)optionsButton:(id)sender;

@end

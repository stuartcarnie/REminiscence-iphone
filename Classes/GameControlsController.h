//
//  GameControlsController.h
//  Flashback
//
//  Created by Stuart Carnie on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

class CJoyStick;
class PlayerInput;
class iPhoneStub;

@interface GameControlsController : UIViewController {
	PlayerInput							*playerInput;
	CJoyStick							*TheJoyStick;
	iPhoneStub							*systemStub;
	id									_delegate;
}

@property (nonatomic, assign)			PlayerInput		*playerInput;
@property (nonatomic, assign)			CJoyStick		*TheJoyStick;
@property (nonatomic, assign)			iPhoneStub		*systemStub;
@property (nonatomic, assign)			id				delegate;

- (IBAction)fireButton:(UIButton*)sender;
- (IBAction)fireButtonUp:(UIButton*)sender;
- (IBAction)itemsButton:(id)sender;
- (IBAction)optionsButton:(id)sender;

@end

@protocol GameControlsDelegate <NSObject>
@optional
- (void)didSelectMenuButton;
@end
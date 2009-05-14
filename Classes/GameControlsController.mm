//
//  GameControlsController.mm
//  Flashback
//
//  Created by Stuart Carnie on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameControlsController.h"
#import "JoyStick.h"
#import "debug.h"
#import "iPhoneStub.h"

enum tagFireButtons {
	FireShift = 1,
	FireSpace,
	FireTab,
	FireEnter,
	FireOptions
};

@interface GameControlsController()

- (void)setFireButton:(tagFireButtons)button toState:(FireButtonState)state;

@end


@implementation GameControlsController

- (void)fireButton:(UIButton*)sender {
	[self setFireButton:(tagFireButtons)sender.tag toState:FireButtonDown];
}

- (void)fireButtonUp:(UIButton*)sender {
	[self setFireButton:(tagFireButtons)sender.tag toState:FireButtonUp];
}

- (void)setFireButton:(tagFireButtons)button toState:(FireButtonState)state {
	switch(button) {
		case FireShift:
			TheJoyStick->setButtonOneState(state);
			break;
		case FireSpace:
			TheJoyStick->setButton2State(state);
			break;
		case FireEnter:
			TheJoyStick->setButton4State(state);
			break;
	}	
}

- (IBAction)itemsButton:(id)sender {
	playerInput->backspace = true;
}

- (IBAction)optionsButton:(id)sender {
	if ([_delegate respondsToSelector:@selector(didSelectMenuButton)])
		[_delegate didSelectMenuButton];
}

- (void)dealloc {
    [super dealloc];
}

@synthesize playerInput, TheJoyStick, systemStub;
@synthesize delegate=_delegate;

@end

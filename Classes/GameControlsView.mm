//
//  GameControlsView.m
//  Flashback
//
//  Created by Stuart Carnie on 3/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameControlsView.h"
#import "systemstub.h"
#import "JoyStick.h"
#import "debug.h"

@implementation GameControlsView

@synthesize playerInput, TheJoyStick;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

enum tagFireButtons {
	FireShift = 1,
	FireSpace,
	FireTab,
	FireEnter,
	FireOptions
};

-(IBAction)fireButton:(UIButton*)sender {
	FireButtonState state = (FireButtonState)sender.state;
	DLog(@"state = %d", state);
	
	switch(sender.tag) {
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

-(IBAction)itemsButton:(id)sender {
	DLog(@"items button");
	playerInput->backspace = true;
}

-(IBAction)optionsButton:(id)sender {
	playerInput->escape = true;
	
}

- (void)dealloc {
    [super dealloc];
}


@end

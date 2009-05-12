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

@implementation GameControlsController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

enum tagFireButtons {
	FireShift = 1,
	FireSpace,
	FireTab,
	FireEnter,
	FireOptions
};

- (IBAction)fireButton:(UIButton*)sender {
	FireButtonState state = (FireButtonState)sender.state;
	
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

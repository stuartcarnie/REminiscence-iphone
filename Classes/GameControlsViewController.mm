//
//  GameControlsViewController.mm
//  Another World
//
//  Created by Stuart Carnie on 1/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameControlsViewController.h"
#import "systemstub.h"

@implementation GameControlsViewController

@synthesize playerInput;

- (IBAction)quickLoad {
	playerInput->stateSlot = slotNumber.selectedSegmentIndex + 1;
	playerInput->load = true;
}

- (IBAction)quickSave {
	playerInput->stateSlot = slotNumber.selectedSegmentIndex + 1;
	playerInput->save = true;
}

- (IBAction)enter {
	playerInput->enter = true;
}

- (IBAction)restart {
	//playerInput->restart = true;
}
@end

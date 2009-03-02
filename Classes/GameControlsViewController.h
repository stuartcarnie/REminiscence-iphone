//
//  GameControlsViewController.h
//  Another World
//
//  Created by Stuart Carnie on 1/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

class PlayerInput;

@interface GameControlsViewController : UIViewController {
	PlayerInput						*playerInput;
	IBOutlet UISegmentedControl		*slotNumber;
}

@property (nonatomic)	PlayerInput		*playerInput;

- (IBAction)quickLoad;
- (IBAction)quickSave;
- (IBAction)options;
- (IBAction)restart;

@end

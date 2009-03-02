//
//  EmulationViewController.h
//  Another World
//
//  Created by Stuart Carnie on 1/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

class Game;
class iPhoneStub;
@class	DisplayView;
@class InputControllerView;
@class JoystickView;
@class JoystickViewLandscape;

enum tagEmulatorState {
	EmulatorNotStarted,
	EmulatorPaused,
	EmulatorRunning
};

@interface EmulationViewController : UIViewController {
	// Emulator
	Game						*engine;
	iPhoneStub					*systemStub;
	NSThread					*emulationThread;
	tagEmulatorState			emulatorState;
	
	DisplayView					*displayView;
	JoystickView				*joystickView;
	InputControllerView			*inputController;
	JoystickViewLandscape		*landscapeJoystickView;

	// landscape views
	UIImageView					*fullControlsImage;
	
	// Layout state information
	UIInterfaceOrientation		layoutOrientation;		// The orientation of the current layout
}

@property (nonatomic, retain)	DisplayView				*displayView;
@property (nonatomic, retain)	InputControllerView		*inputController;
@property (nonatomic, retain)	JoystickView			*joystickView;
@property (nonatomic, retain)	JoystickViewLandscape	*landscapeJoystickView;
@property (nonatomic, retain)	UIImageView				*fullControlsImage;

- (void)pause;
- (void)resume;

- (void)loadDefaultGame;
- (void)saveDefaultGame;

@end

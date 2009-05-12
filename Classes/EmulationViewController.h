/* 
 Flashback for iPhone - Flashback interpreter
 Copyright (C) 2009 Stuart Carnie
 See gpl.txt for license information.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>

class Game;
class iPhoneStub;
@class DisplayView;
@class InputControllerView;
@class JoystickViewLandscape;
@class ControlPanelViewController;
@class GameControlsController;
@class SideMenuController;

enum tagEmulatorState {
	EmulatorNotStarted,
	EmulatorPaused,
	EmulatorRunning
};

@interface EmulationViewController : UIViewController {
	BOOL						_isFullScreen;
	
	// Emulator
	Game						*engine;
	iPhoneStub					*systemStub;
	NSThread					*emulationThread;
	tagEmulatorState			emulatorState;
	
	// control panel views
	ControlPanelViewController	*_controlPanel;
	SideMenuController			*_sideMenuPanel;
	
	// normal / fullscreen views
	DisplayView					*displayView;
	InputControllerView			*inputController;
	JoystickViewLandscape		*landscapeJoystickView;
	UIImageView					*overlayFullScreen;
	
	// normal views
	UIImageView					*overlayNormal;
	GameControlsController		*normalControls;
	
	// fullscreen views
	GameControlsController		*fullScreenControls;

	// Layout state information
	UIInterfaceOrientation		layoutOrientation;		// The orientation of the current layout
	BOOL						_dontSave;
}

@property (nonatomic, retain)	DisplayView							*displayView;
@property (nonatomic, retain)	InputControllerView					*inputController;
@property (nonatomic, retain)	JoystickViewLandscape				*landscapeJoystickView;
@property (nonatomic, retain)	IBOutlet ControlPanelViewController	*controlPanel;
@property (nonatomic, retain)	IBOutlet SideMenuController			*sideMenuPanel;
@property (nonatomic, retain)	IBOutlet GameControlsController		*fullScreenControls;
@property (nonatomic, retain)	IBOutlet GameControlsController		*normalControls;

- (void)pause;
- (void)resume;
- (void)quit;

- (void)loadDefaultGame;
- (void)saveDefaultGame;

@end

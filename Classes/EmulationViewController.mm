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

#import "EmulationViewController.h"
#import "FlashbackConfig.h"
#import "game.h"
#import "iPhoneStub.h"
#import "util.h"

#import "DisplayView.h"
#import "InputControllerView.h"
#import "JoystickViewLandscape.h"
#import "GameControlsView.h"
#import "ControlPanelViewController.h"

#import "CocoaUtility.h"

#import "debug.h"

#import "file.h"
#import "video.h"


@interface EmulationViewController(PrivateImplementation)

- (void)startEmulator;
- (void)runEmulator;
- (void)loadDefaultState;

@end


@implementation EmulationViewController

@synthesize displayView, inputController, landscapeJoystickView, gameControlsView;
@synthesize controlPanel = _controlPanel;

const double kControlsWidth					= 95;
const double kSkinTop						= 6;

// landscape frames
#define kDisplayFrameLandscapeFullScreen	CGRectMake(kControlsWidth, kSkinTop, 352, 308)
#define kGameControlsFrame					CGRectMake(0, 0, kControlsWidth, 320)
#define kInputFrameLandscape				CGRectMake(kControlsWidth, 0, 480 - kControlsWidth, 320)
#define kJoystickViewFrameLandscape			CGRectMake(0, 0, 480 - kControlsWidth, 320)
#define degreesToRadian(x)					(M_PI  * x / 180.0)

// miscellaneous constants
const double kDefaultAnimationDuration					= 250.0 / 1000.0;
const double kDefaultControlsOverlayAnimationDuration	= 100.0 / 1000.0;	// 100 ms


static Version detectVersion(const char *dataPath) {
	static struct {
		const char *filename;
		Version ver;
	} checkTable[] = {
		{ "ENGCINE.BIN", VER_EN },
		{ "FR_CINE.BIN", VER_FR },
		{ "GERCINE.BIN", VER_DE },
		{ "SPACINE.BIN", VER_SP }
	};
	for (uint8 i = 0; i < ARRAYSIZE(checkTable); ++i) {
		File f;
		if (f.open(checkTable[i].filename, dataPath, "rb")) {
			return checkTable[i].ver;
		}
	}
	error("Unable to find data files, check that all required files are present");
	return (Version)-1;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	static char dataPath[512], documentsPath[512];
	[DATA_FOLDER getCString:dataPath maxLength:sizeof(dataPath) encoding:[NSString defaultCStringEncoding]];
	strncpy(documentsPath, [DOCUMENTS_FOLDER cStringUsingEncoding:[NSString defaultCStringEncoding]], sizeof(documentsPath));

	Version ver = detectVersion(dataPath);
	if (ver == -1) {
		return;
	}
	
	g_debugMask = DBG_INFO; // DBG_LOGIC | DBG_BANK | DBG_VIDEO | DBG_SER | DBG_SND
	systemStub = static_cast<iPhoneStub*> (SystemStub_create());
	engine = new Game(systemStub, dataPath, documentsPath, ver);
	emulatorState = EmulatorNotStarted;
	
	// create all the views
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.backgroundColor = [UIColor blackColor];
	
	displayView = [[DisplayView alloc] initWithFrame:kDisplayFrameLandscapeFullScreen];
	self.displayView.stub = systemStub;
	[view addSubview:self.displayView];
	
	overlay = [UIImageView newViewFromImageResource:@"overlay_merged.png"];
	[view addSubview:overlay];
	
	inputController = [[InputControllerView alloc] initWithFrame:kInputFrameLandscape];
	self.inputController.TheJoyStick = &systemStub->TheJoyStick;
	[view addSubview:self.inputController];
	
	landscapeJoystickView = [[JoystickViewLandscape alloc] initWithFrame:kJoystickViewFrameLandscape];
	[self.inputController addSubview:self.landscapeJoystickView];
	self.inputController.delegate = self.landscapeJoystickView;
	
	[[NSBundle mainBundle] loadNibNamed:@"GameControlsView" owner:self options:nil];
	gameControlsView.frame = kGameControlsFrame;
	gameControlsView.systemStub  = systemStub;
	gameControlsView.TheJoyStick = &systemStub->TheJoyStick;
	gameControlsView.playerInput = &systemStub->_pi;
	
	[view addSubview:self.gameControlsView];
	
	_controlPanel.view.frame = kControlPanelFrame;
	[view addSubview:_controlPanel.view];
	
	self.view = view;
	view.isUserInteractionEnabled = YES;
    [view release];	
	
	self.view.center = CGPointMake(160, 240);
	self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
	self.view.bounds = CGRectMake(0, 0, 480, 320);	
}

- (void)viewDidAppear:(BOOL)animated {
	[self startEmulator];
}

- (void)startEmulator {
	if (emulatorState == EmulatorPaused) {
		return;//[self resumeEmulator];
	} else if (emulatorState == EmulatorNotStarted) {
		if (engine->hasDefaultGameState()) {
			engine->autoLoadDefaultGameState();
		}

		emulationThread = [[NSThread alloc] initWithTarget:self selector:@selector(runEmulator) object:nil];
		[emulationThread start];
		[self.displayView startTimer];
	}
}

- (void)runEmulator {
	emulatorState = EmulatorRunning;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0.7];
	engine->run();
	[pool release];
}

#pragma mark Emulator State

- (void)pause {
}

- (void)resume {
}

#pragma mark State Management

- (void)loadDefaultGame {
	systemStub->_pi.stateSlot	= Game::DEFAULT_SAVE_SLOT;
	systemStub->_pi.load		= true;
	while (systemStub->_pi.load) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 20.0/1000.0, false);	
	}
}

- (void)saveDefaultGame {
	if (emulatorState == EmulatorNotStarted)
		return;
	
	systemStub->_pi.stateSlot	= Game::DEFAULT_SAVE_SLOT;
	systemStub->_pi.save		= true;
	while (systemStub->_pi.save)
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 20.0/1000.0, false);	
}

- (void)dealloc {
	[overlay release];
    [super dealloc];
}


@end

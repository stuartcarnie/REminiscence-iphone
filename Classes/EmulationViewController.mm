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
#import "GameNotifications.h"

#import "DisplayView.h"
#import "InputControllerView.h"
#import "JoystickViewLandscape.h"
#import "ControlPanelViewController.h"
#import "SideMenuController.h"
#import "GameControlsController.h"

#import "CocoaUtility.h"

#import "debug.h"

#import "file.h"
#import "video.h"

#import "UserDefaults.h"

@interface EmulationViewController(PrivateImplementation)

- (void)startEmulator;
- (void)runEmulator;
- (void)loadDefaultState;

- (void)configureFullScreen;
- (void)configureNormal;

- (void)gameUINotification;
- (void)userDefaultsDidChange;
@end


@implementation EmulationViewController

@synthesize displayView, inputController, landscapeJoystickView, fullScreenControls, normalControls;
@synthesize controlPanel=_controlPanel, sideMenuPanel=_sideMenuPanel;

const double kControlsWidth					= 95;
const double kSkinTop						= 6;

// landscape frames for normal view
#define kDisplayFrameLandscapeNormal			CGRectMake(kControlsWidth, kSkinTop, 352, 308)
#define kInputFrameLandscapeNormal				CGRectMake(kControlsWidth, 0, 480 - kControlsWidth, 320)
#define kJoystickViewFrameLandscapeNormal		CGRectMake(0, 0, 480 - kControlsWidth, 320)

// landscape frames for full screen view
#define kControlsWidthFullScreen				95
#define kDisplayFrameLandscapeFullScreen		CGRectMake(0, 0, 480, 320)
#define kInputFrameLandscapeFullScreen			CGRectMake(kControlsWidthFullScreen, 0, 480 - kControlsWidthFullScreen, 320)
#define kJoystickViewFrameLandscapeFullScreen	CGRectMake(0, 0, 480 - kControlsWidthFullScreen, 320)

#define degreesToRadian(x)						(M_PI  * x / 180.0)

// miscellaneous constants
const double kDefaultAnimationDuration					= 250.0 / 1000.0;
const double kDefaultControlsOverlayAnimationDuration	= 100.0 / 1000.0;	// 100 ms


static Version detectVersion(const char *lang, const char *dataPath) {
	static struct {
		const char *lang;
		const char *filename;
		Version ver;
	} checkTable[] = {
		{ "en", "ENGCINE.BIN", VER_EN },
		{ "fr", "FR_CINE.BIN", VER_FR },
		{ "de", "GERCINE.BIN", VER_DE },
		{ "es", "SPACINE.BIN", VER_SP }
	};
	
	// first attempt to find the chosen language
	for (uint8 i=0; i<ARRAYSIZE(checkTable); i++) {
		if (strcmp(lang, checkTable[i].lang) == 0) {
			File f;
			if (f.open(checkTable[i].filename, dataPath, "rb")) {
				return checkTable[i].ver;
			}
		}
	}
	
	// otherwise find the first language
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

	NSString* lang = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingLanguage];
	Version ver = detectVersion([lang UTF8String], dataPath);
	if (ver == -1) {
		return;
	}
	
	_dontSave = NO;
	g_debugMask = DBG_INFO;
	systemStub = static_cast<iPhoneStub*> (SystemStub_create());
	engine = new Game(systemStub, dataPath, documentsPath, ver);
	emulatorState = EmulatorNotStarted;
	
	// create all the views
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.backgroundColor = [UIColor blackColor];
	
	displayView = [[DisplayView alloc] initWithFrame:CGRectZero];
	self.displayView.stub = systemStub;
	[view addSubview:self.displayView];
	
	overlayFullScreen = [UIImageView newViewFromImageResource:@"fullscreen_border.png"];
	[view addSubview:overlayFullScreen];
	
	overlayNormal = [UIImageView newViewFromImageResource:@"overlay_merged.png"];
	[view addSubview:overlayNormal];
	
	inputController = [[InputControllerView alloc] initWithFrame:CGRectZero];
	self.inputController.TheJoyStick = &systemStub->TheJoyStick;
	[view addSubview:self.inputController];
	
	landscapeJoystickView = [[JoystickViewLandscape alloc] initWithFrame:CGRectZero];
	[self.inputController addSubview:self.landscapeJoystickView];
	self.inputController.delegate = self.landscapeJoystickView;
	

	[[NSBundle mainBundle] loadNibNamed:@"FullScreenGameControls" owner:self options:nil];
	fullScreenControls.systemStub  = systemStub;
	fullScreenControls.TheJoyStick = &systemStub->TheJoyStick;
	fullScreenControls.playerInput = &systemStub->_pi;
	[view addSubview:fullScreenControls.view];
	
	[[NSBundle mainBundle] loadNibNamed:@"NormalGameControls" owner:self options:nil];
	normalControls.systemStub  = systemStub;
	normalControls.TheJoyStick = &systemStub->TheJoyStick;
	normalControls.playerInput = &systemStub->_pi;
	[view addSubview:normalControls.view];
	
	_sideMenuPanel.view.frame = kSidePanelFrameHidden;
	_sideMenuPanel.stub = systemStub;
	[view addSubview:_sideMenuPanel.view];
	
	_controlPanel.stub = systemStub;
	_controlPanel.emulationController = self;
	_controlPanel.sidePanel = _sideMenuPanel;
	[view addSubview:_controlPanel.view];
	
	_isFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingFullScreen];
	
	if (_isFullScreen) {
		[self configureFullScreen];
	} else {
		[self configureNormal];
	}
	
	self.view = view;
	view.isUserInteractionEnabled = YES;
    [view release];	
	
	self.view.center = CGPointMake(160, 240);
	self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
	self.view.bounds = CGRectMake(0, 0, 480, 320);
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(gameUINotification) 
                                                 name:kGameUINotification 
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(userDefaultsDidChange) 
                                                 name:NSUserDefaultsDidChangeNotification 
                                               object:nil];
}

- (void)userDefaultsDidChange {
	BOOL newFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingFullScreen];
	if (newFullScreen != _isFullScreen) {
		_isFullScreen = newFullScreen;
		if (_isFullScreen)
			[self configureFullScreen];
		else
			[self configureNormal];
	}
}

- (void)gameUINotification {
	UIMessage event;
   
	while (systemStub->dequeueMessage(&event)) {
		SystemStub::tagUIPhase phase = event.phase;
		BOOL itemsVisible = phase == SystemStub::PHASE_START;
		_controlPanel.itemsVisible = itemsVisible;

		// ignored if not full screen
		if (!_isFullScreen) continue;
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:kDefaultAnimationDuration];
		
		if (itemsVisible) {
			_controlPanel.view.frame = kControlPanelFrameNormal;
			_sideMenuPanel.view.frame = kSidePanelFramePartial;
		} else {
			_controlPanel.view.frame = kControlPanelFrameFullScreen;
			_sideMenuPanel.view.frame = kSidePanelFrameHidden;
		}
		
		[UIView commitAnimations];
	}
}

- (void)configureFullScreen {
	overlayNormal.hidden = YES;
	overlayFullScreen.hidden = NO;
	normalControls.view.hidden = YES;
	fullScreenControls.view.hidden = NO;
	
	displayView.frame = kDisplayFrameLandscapeFullScreen;
	inputController.frame = kInputFrameLandscapeFullScreen;
	landscapeJoystickView.frame = kJoystickViewFrameLandscapeFullScreen;
	_controlPanel.view.frame = kControlPanelFrameFullScreen;
	
	fullScreenControls.view.alpha = [[NSUserDefaults standardUserDefaults] doubleForKey:kSettingControlsTransparency];
}

- (void)configureNormal {
	overlayNormal.hidden = NO;
	overlayFullScreen.hidden = YES;
	normalControls.view.hidden = NO;
	fullScreenControls.view.hidden = YES;

	displayView.frame = kDisplayFrameLandscapeNormal;
	inputController.frame = kInputFrameLandscapeNormal;
	landscapeJoystickView.frame = kJoystickViewFrameLandscapeNormal;
	_controlPanel.view.frame = kControlPanelFrameNormal;
	_sideMenuPanel.view.frame = kSidePanelFrameHidden;
}

- (void)didSelectMenuButton {
	[_controlPanel hideShowControlPanel:self]; 
}

- (void)viewDidAppear:(BOOL)animated {
	[self startEmulator];
}

- (void)startEmulator {
	if (emulatorState == EmulatorPaused) {
		return;
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
	if (!systemStub->_pi.quit) {
		// user chose quit from main menu
		_dontSave = YES;
		[[UIApplication sharedApplication] performSelector:@selector(terminate)];
	}
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
	if (emulatorState == EmulatorNotStarted || _dontSave)
		return;
	
	systemStub->_pi.stateSlot	= Game::DEFAULT_SAVE_SLOT;
	systemStub->_pi.save		= true;
	while (systemStub->_pi.save)
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 20.0/1000.0, false);	
}

- (void)quit {
	if (systemStub)
		systemStub->_pi.quit		= true;
}

- (void)dealloc {
	[overlayNormal release];
    [super dealloc];
}


@end

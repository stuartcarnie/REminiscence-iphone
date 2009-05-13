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
- (void)doHelpOverlay:(id)sender;

// lazy loading methods
- (UIButton*)fullScreenItemsButton;
- (UIButton*)normalItemsButton;

- (void)readUserDefaults;

- (void)setNormalControlsHidden:(BOOL)hidden;
- (void)setFullScreenControlsHidden:(BOOL)hidden;

@end


@implementation EmulationViewController

@synthesize displayView, inputController, landscapeJoystickView, fullScreenControls, normalControls;
@synthesize controlPanel=_controlPanel, sideMenuPanel=_sideMenuPanel;

const double kControlsWidth					= 95;
const double kSkinTop						= 6;

// frames for either view
#define kItemsButtonFrame						CGRectMake(0, 0, 110, 50)

// landscape frames for normal view
#define kDisplayFrameLandscapeNormal			CGRectMake(kControlsWidth, kSkinTop, 352, 308)
#define kInputFrameLandscapeNormal				CGRectMake(kControlsWidth, 0, 480 - kControlsWidth, 320)
#define kJoystickViewFrameLandscapeNormal		CGRectMake(0, 0, 480 - kControlsWidth, 320)
#define kHelpButtonCentreNormal					CGPointMake(400, 285)
#define kItemsButtonCentreNormal				CGPointMake(386, 30)

// landscape frames for full screen view
#define kControlsWidthFullScreen				95
#define kDisplayFrameLandscapeFullScreen		CGRectMake(0, 0, 480, 320)
#define kInputFrameLandscapeFullScreen			CGRectMake(kControlsWidthFullScreen, 0, 480 - kControlsWidthFullScreen, 320)
#define kJoystickViewFrameLandscapeFullScreen	CGRectMake(0, 0, 480 - kControlsWidthFullScreen, 320)
#define kHelpButtonCentreFullScreen				CGPointMake(420, 290)
#define kItemsButtonCentreFullScreen			CGPointMake(404, 24)

#define degreesToRadian(x)						(M_PI  * x / 180.0)

#define kDefaultControlsAlpha					0.25

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
	
	// FIXME: French version not working
	// first attempt to find the chosen language
	/*for (uint8 i=0; i<ARRAYSIZE(checkTable); i++) {
		if (strcmp(lang, checkTable[i].lang) == 0) {
			File f;
			if (f.open(checkTable[i].filename, dataPath, "rb")) {
				return checkTable[i].ver;
			}
		}
	}*/
	
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
	
	// read user defaults
	[self readUserDefaults];
	
	// create all the views
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.backgroundColor = [UIColor blackColor];
	
	displayView = [[DisplayView alloc] initWithFrame:CGRectZero];
	self.displayView.stub = systemStub;
	[view addSubview:self.displayView];
	
	overlayFullScreen = [UIImageView newViewFromImageResource:@"fullscreen_border.png"];
	overlayFullScreen.hidden = YES;
	[view addSubview:overlayFullScreen];
	
	overlayNormal = [UIImageView newViewFromImageResource:@"overlay_merged.png"];
	overlayNormal.hidden = YES;
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
	fullScreenControls.view.hidden = YES;
	[view addSubview:fullScreenControls.view];
	
	[[NSBundle mainBundle] loadNibNamed:@"NormalGameControls" owner:self options:nil];
	normalControls.systemStub  = systemStub;
	normalControls.TheJoyStick = &systemStub->TheJoyStick;
	normalControls.playerInput = &systemStub->_pi;
	normalControls.view.hidden = YES;
	[view addSubview:normalControls.view];
			
	// create buttons
	helpButton = [[UIButton newButtonWithImage:@"fullscreen_btn_help.png" andSelectedImage:nil] retain];
	[helpButton addTarget:self action:@selector(doHelpOverlay:) forControlEvents:UIControlEventTouchUpInside];
	helpButton.alpha = 0.0;
	[view addSubview:helpButton];

	_sideMenuPanel.view.frame = kSidePanelFrameHidden;
	_sideMenuPanel.stub = systemStub;
	[view addSubview:_sideMenuPanel.view];

	_controlPanel.stub = systemStub;
	_controlPanel.emulationController = self;
	_controlPanel.sidePanel = _sideMenuPanel;
	[view addSubview:_controlPanel.view];
			
	self.view = view;
	view.isUserInteractionEnabled = YES;
    [view release];	

	_isFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingFullScreen];
	if (_isFullScreen) {
		[self configureFullScreen];
	} else {
		[self configureNormal];
	}
	
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

- (void)readUserDefaults {
	_controlsAlpha = [[NSUserDefaults standardUserDefaults] doubleForKey:kSettingControlsTransparency];
}
	
- (void)doHelpOverlay:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kDefaultAnimationDuration];

	currentHelpOverlay.alpha = !currentHelpOverlay.alpha;
	
	[UIView commitAnimations];
}

- (void)userDefaultsDidChange {
	BOOL newFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingFullScreen];
	if (newFullScreen != _isFullScreen) {
		_isFullScreen = newFullScreen;
		currentHelpOverlay.alpha = 0;
		if (_isFullScreen) {			
			[self setNormalControlsHidden:YES];
			[self configureFullScreen];
		}
		else {
			[self setFullScreenControlsHidden:YES];
			[self configureNormal];
		}
	}
	
	[self readUserDefaults];
}

- (void)gameUINotification {
	UIMessage event;
   
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kDefaultAnimationDuration];

	while (systemStub->dequeueMessage(&event)) {
		SystemStub::tagUIPhase phase = event.phase;
		BOOL itemsVisible = phase == SystemStub::PHASE_START;
		_controlPanel.itemsVisible = itemsVisible;

		if (itemsVisible) {
			// show help
			helpButton.alpha = 0.5;
		} else {
			helpButton.alpha = 0.0;
		}

		// ignored if not full screen
		if (!_isFullScreen) continue;
				
		if (itemsVisible) {
			_controlPanel.view.frame = kControlPanelFrameNormal;
			_sideMenuPanel.view.frame = kSidePanelFramePartial;
		} else {
			_controlPanel.view.frame = kControlPanelFrameFullScreen;
			_sideMenuPanel.view.frame = kSidePanelFrameHidden;
		}
	}

	[UIView commitAnimations];
}

- (void)setNormalControlsHidden:(BOOL)hidden {
	overlayNormal.hidden = hidden;
	normalControls.view.hidden = hidden;
	[self normalItemsButton].hidden = hidden;	
}

- (void)setFullScreenControlsHidden:(BOOL)hidden {
	overlayFullScreen.hidden = hidden;
	fullScreenControls.view.hidden = hidden;
	[self fullScreenItemsButton].hidden = hidden;
}

- (void)configureFullScreen {
	[self setFullScreenControlsHidden:NO];
	
	displayView.frame = kDisplayFrameLandscapeFullScreen;
	inputController.frame = kInputFrameLandscapeFullScreen;
	landscapeJoystickView.frame = kJoystickViewFrameLandscapeFullScreen;
	_controlPanel.view.frame = kControlPanelFrameFullScreen;	
	helpButton.center = kHelpButtonCentreFullScreen;
	
	fullScreenControls.view.alpha = _controlsAlpha;
	currentHelpOverlay = [self fullScreenHelpOverlay];
}

- (void)configureNormal {
	[self setNormalControlsHidden:NO];

	displayView.frame = kDisplayFrameLandscapeNormal;
	inputController.frame = kInputFrameLandscapeNormal;
	landscapeJoystickView.frame = kJoystickViewFrameLandscapeNormal;
	_controlPanel.view.frame = kControlPanelFrameNormal;
	_sideMenuPanel.view.frame = kSidePanelFrameHidden;

	helpButton.center = kHelpButtonCentreNormal;
	currentHelpOverlay = [self normalHelpOverlay];
}

- (UIImageView*)normalHelpOverlay {
	if (!_normalHelpOverlay) {
		_normalHelpOverlay = [UIImageView newViewFromImageResource:@"help_overlay_normal.png"];
		_normalHelpOverlay.alpha = 0;
		_normalHelpOverlay.userInteractionEnabled = YES;
		[self.view insertSubview:_normalHelpOverlay belowSubview:helpButton];
	}
	return _normalHelpOverlay;
}

- (UIImageView*)fullScreenHelpOverlay {
	if (!_fullScreenHelpOverlay) {
		_fullScreenHelpOverlay = [UIImageView newViewFromImageResource:@"help_overlay_fullscreen.png"];
		_fullScreenHelpOverlay.alpha = 0;
		_fullScreenHelpOverlay.userInteractionEnabled = YES;
		[self.view insertSubview:_fullScreenHelpOverlay belowSubview:helpButton];
	}
	return _fullScreenHelpOverlay;
}

- (UIButton*)fullScreenItemsButton {
	if (!_fullScreenItemsButton) {
		_fullScreenItemsButton = [[UIButton newButtonWithImage:@"fullscreen_btn_items.png" andSelectedImage:nil] retain];
		_fullScreenItemsButton.frame = kItemsButtonFrame;
		_fullScreenItemsButton.center = kItemsButtonCentreFullScreen;
		_fullScreenItemsButton.alpha = _controlsAlpha + _controlsAlpha * 0.3f;
		[_fullScreenItemsButton addTarget:fullScreenControls action:@selector(itemsButton:) forControlEvents:UIControlEventTouchUpInside];
		[self.view insertSubview:_fullScreenItemsButton aboveSubview:fullScreenControls.view];		
	}
	return _fullScreenItemsButton;
}

- (UIButton*)normalItemsButton {
	if (!_normalItemsButton) {
		_normalItemsButton = [[UIButton newButtonWithImage:@"fullscreen_btn_items.png" andSelectedImage:nil] retain];
		_normalItemsButton.frame = kItemsButtonFrame;
		_normalItemsButton.center = kItemsButtonCentreNormal;
		_normalItemsButton.alpha = _controlsAlpha + _controlsAlpha * 0.3f;
		[_normalItemsButton addTarget:normalControls action:@selector(itemsButton:) forControlEvents:UIControlEventTouchUpInside];
		[self.view insertSubview:_normalItemsButton aboveSubview:fullScreenControls.view];		
	}
	return _normalItemsButton;
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

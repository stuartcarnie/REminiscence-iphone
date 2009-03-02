//
//  EmulationViewController.m
//  Another World
//
//  Created by Stuart Carnie on 1/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EmulationViewController.h"
#include "game.h"
#include "iPhoneStub.h"
#include "util.h"

#import "DisplayView.h"
#import "InputControllerView.h"
#import "JoystickView.h"
#import "GameControlsViewController.h"

#import "CocoaUtility.h"

#import "debug.h"

#import "file.h"
#import "video.h"


@interface EmulationViewController(PrivateImplementation)

- (void)startEmulator;
- (void)runEmulator;
- (void)loadDefaultState;

- (void)rotateToPortrait;
- (void)rotateToLandscape;
- (void)didRotate;

- (void)showControlsOverlay;
- (void)hideControlsOverlay;
- (void)displayControlsOverlay:(BOOL)display;

@end


@implementation EmulationViewController

@synthesize displayView, inputController, joystickView, fullControlsImage;

const int kHeaderBarHeight					= 16;
const int kPortraitSkinHeight				= 265;

const int kInputAreaTop						= kPortraitSkinHeight + 1;

#define kDisplayFramePortrait				CGRectMake(32, 0, Video::GAMESCREEN_W, Video::GAMESCREEN_H)
#define kJoystickViewFramePortrait			CGRectMake(0, kInputAreaTop, 320, 200)
#define kInputFramePortrait					CGRectMake(0, kInputAreaTop, 320, 480 - kInputAreaTop)

// tabbar
#define kTabBarVisible						CGRectMake(0, 0, 320, 480)
#define kTabBarNotVisible					CGRectMake(0, 0, 320, 480 + 48)

// landscape frames
#define kFullControlsOverlayFrameLandscape	CGRectMake(10, 10, 459, 300)
#define kDisplayFrameLandscapeFullScreen	CGRectMake(80, 0, 320, 320);

// miscellaneous constants
const double kDefaultAnimationDuration					= 250.0 / 1000.0;
const double kDefaultControlsOverlayAnimationDuration	= 100.0 / 1000.0;	// 100 ms

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

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
	return VER_EN;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	static char dataPath[512], documentsPath[512];
	strncpy(dataPath, [[[NSBundle mainBundle] bundlePath] cStringUsingEncoding:[NSString defaultCStringEncoding]], sizeof(dataPath));
	strncpy(documentsPath, [DOCUMENTS_FOLDER cStringUsingEncoding:[NSString defaultCStringEncoding]], sizeof(documentsPath));

	Version ver = detectVersion(dataPath);
	g_debugMask = DBG_INFO; // DBG_LOGIC | DBG_BANK | DBG_VIDEO | DBG_SER | DBG_SND
	systemStub = static_cast<iPhoneStub*> (SystemStub_create());
	engine = new Game(systemStub, dataPath, documentsPath, ver);
	emulatorState = EmulatorNotStarted;
	
	// create all the views
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	UIView *view = [[UIView alloc] initWithFrame:frame];
	view.backgroundColor = [UIColor blackColor];
	
	self.displayView = [[DisplayView alloc] initWithFrame:kDisplayFramePortrait];
	self.displayView.stub = systemStub;
	[view addSubview:self.displayView];
	
	self.joystickView = [[JoystickView alloc] initWithFrame:kJoystickViewFramePortrait];
	[view addSubview:self.joystickView];
	
	self.inputController = [[InputControllerView alloc] initWithFrame:kInputFramePortrait];
	self.inputController.delegate = self.joystickView;
	self.inputController.TheJoyStick = &systemStub->TheJoyStick;
	[view addSubview:self.inputController];

	self.fullControlsImage = [[UIImageView alloc] initWithImage:[UIImage imageFromResource:@"fullcontrols_overlay.png"]];
	self.fullControlsImage.alpha = 0.0;
	self.fullControlsImage.frame = kFullControlsOverlayFrameLandscape;
	[view addSubview:self.fullControlsImage];
	
	self.view = view;
	view.isUserInteractionEnabled = YES;
    [view release];	
	
	GameControlsViewController *gcs = [self.tabBarController.viewControllers objectAtIndex:1];
	gcs.playerInput = &systemStub->_pi;
	
	
	// monitor device rotation
	layoutOrientation				= (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];

	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRotate)
												 name:@"UIDeviceOrientationDidChangeNotification" 
											   object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[self startEmulator];
}

- (void)startEmulator {
	if (emulatorState == EmulatorPaused) {
		return;//[self resumeEmulator];
	} else if (emulatorState == EmulatorNotStarted) {
		emulationThread = [[NSThread alloc] initWithTarget:self selector:@selector(runEmulator) object:nil];
		[emulationThread start];
		[self.displayView startTimer];
		//[self performSelector:@selector(loadDefaultGame) withObject:nil afterDelay:0.25];
	}
}

- (void)runEmulator {
	emulatorState = EmulatorRunning;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0.7];
	engine->run();
	[pool release];
}

#pragma mark Rotation handlers

#define degreesToRadian(x) (M_PI  * x / 180.0)

- (void)didRotate {
	if (self.tabBarController.selectedViewController != self)
		return;
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (!UIDeviceOrientationIsValidInterfaceOrientation(orientation) || layoutOrientation == (UIInterfaceOrientation)orientation)
		return;
	
	layoutOrientation = (UIInterfaceOrientation)orientation;
	
	[UIView beginAnimations:@"rotate" context:nil];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kDefaultAnimationDuration];
	
	self.view.center = CGPointMake(160, 240);
	
	if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
		self.tabBarController.view.frame = kTabBarNotVisible;
		
		if (layoutOrientation == UIInterfaceOrientationLandscapeLeft) {
			self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
		} else {
			self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
		}
		self.view.bounds = CGRectMake(0, 0, 480, 320);
		
		[self rotateToLandscape];
	} else {
		self.tabBarController.view.frame = kTabBarVisible;
		self.view.transform = CGAffineTransformIdentity;
		self.view.bounds = CGRectMake(0, 0, 320, 480);
		
		[self rotateToPortrait];
	}
	[UIView commitAnimations];
}

- (void)rotateToPortrait {
	self.displayView.frame			= kDisplayFramePortrait;
	[self.displayView setNeedsLayout];
	
	self.joystickView.alpha			= 1.0;
	self.inputController.frame		= kInputFramePortrait;
}

- (void)rotateToLandscape {
	self.displayView.frame			= kDisplayFrameLandscapeFullScreen;
	[self.displayView setNeedsLayout];
		
	// hide joystick
	self.joystickView.alpha			= 0.0;
	
	self.inputController.frame		= CGRectMake(0, 0, 480, 320);
}

- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	if (!UIInterfaceOrientationIsLandscape(layoutOrientation))
		return;
	
	if ([animationID isEqual:@"rotate"]) {		
		[self displayControlsOverlay:YES];
		
		// hide overlay after 2 seconds
		[self performSelector:@selector(hideControlsOverlay) withObject:nil afterDelay:2.0];
	}
}

- (void)showControlsOverlay {
	[self displayControlsOverlay:YES];
}

- (void)hideControlsOverlay {
	[self displayControlsOverlay:NO];
}

- (void)displayControlsOverlay:(BOOL)display {
	DLog(@"Displaying landscape controller layout");
	
	self.fullControlsImage.frame = kFullControlsOverlayFrameLandscape;
	[UIView beginAnimations:@"overlay-open" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:kDefaultControlsOverlayAnimationDuration];
	
	self.fullControlsImage.alpha = display ? 1.0 : 0.0;
	[UIView commitAnimations];	
}

#pragma mark Emulator State

- (void)pause {
}

- (void)resume {
}

#pragma mark State Management

- (void)loadDefaultGame {
	systemStub->_pi.stateSlot	= 99;
	systemStub->_pi.load		= true;
	while (systemStub->_pi.load)
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 20.0/1000.0, false);	
}

- (void)saveDefaultGame {
	systemStub->_pi.stateSlot	= 99;
	systemStub->_pi.save		= true;
	while (systemStub->_pi.save)
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 20.0/1000.0, false);	
}

- (void)dealloc {
    [super dealloc];
}


@end

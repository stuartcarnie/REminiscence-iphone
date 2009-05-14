//
//  ControlPanelViewController.m
//  Flashback
//
//  Created by Stuart Carnie on 4/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ControlPanelViewController.h"
#import "ImageBarControl.h"
#import "SaveGameBrowserController.h"
#import "CreditsViewController.h"
#import "iPhoneStub.h"
#import "EmulationViewController.h"
#import "SideMenuController.h"
#import "UserDefaults.h"
#import "InGameHelpController.h"
#import "ValidationCheck.h"

const double kDefaultAnimationDuration					= 250.0 / 1000.0;
const NSString *kSaveGameCaption						= @"Select a slot to SAVE game";
const NSString *kLoadGameCaption						= @"Select a slot to LOAD game";

// text color: #33cc00

@interface ControlPanelViewController()

- (void)valueChanged:(ImageBarControl*)sender;

@end

@implementation ControlPanelViewController

@synthesize stub=_stub, credits=_credits, gameList=_gameList, caption=_caption;
@synthesize emulationController=_emulationController, sidePanel=_sidePanel;
@synthesize inGameHelp=_inGameHelp;
@synthesize itemsVisible=_itemsVisible;

enum {
	TabSave,
	TabLoad,
	TabHelp,
//	TabSettings,
	TabInfo
};

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSArray *items = [NSArray arrayWithObjects:
					  @"console_save_off.png", @"console_save_on.png", 
					  @"console_load_off.png", @"console_load_on.png",
					  @"console_help_off.png", @"console_help_on.png", 
					  //@"console_settings_off.png", @"console_settings_on.png",
					  @"console_info_off.png", @"console_info_on.png", nil];
	_imageBar = [[ImageBarControl alloc] initWithItems:items];
	[self.view addSubview:_imageBar];
	_imageBar.center = CGPointMake(kControlPanelWidth/2, 285);
	[_imageBar addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	[_imageBar release];
	
	_gameList.view.frame = kSaveGameViewFrame;
	_gameList.delegate = self;
	[self.view addSubview:_gameList.view];
	
	self.caption.text = kSaveGameCaption;
}

- (void)didSelectSaveGame:(SaveGameFileInfo*)info {
	check3(180);
	NSInteger sel = _imageBar.selectedSegmentIndex;
	if (sel == 0) { 
		// save
		_stub->_pi.stateSlot = info.slot;
		_stub->_pi.save = true;
		_reloadTable = YES;
		[info clearInfo];
	} else if (sel = 1) {
		// load
		_stub->_pi.stateSlot = info.slot;
		_stub->_pi.load = true;
	}
	
	// hide items, and allow load / save to continue
	if (_itemsVisible)
		_stub->_pi.backspace = true;
	
	[self hideShowControlPanel:self];
}

- (IBAction)hideShowControlPanel:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kDefaultAnimationDuration];
	
	if (_isOpen) {
		[self.sidePanel viewWillDisappear:YES];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingFullScreen]) {
			if (_itemsVisible) {
				self.sidePanel.view.frame = kSidePanelFramePartial;
				self.view.frame = kControlPanelFrameNormal;
			} else {
				self.sidePanel.view.frame = kSidePanelFrameHidden;
				self.view.frame = kControlPanelFrameFullScreen;
			}
		} else {
			self.view.frame = kControlPanelFrameNormal;
			self.sidePanel.view.frame = kSidePanelFrameHidden;
		}
	} else {
		[self.sidePanel viewWillAppear:YES];
		self.view.frame = kControlPanelOpenFrame;
		self.sidePanel.view.frame = kSidePanelFrameVisible;
		if (_reloadTable) {
			[_gameList.tableView reloadData];
			_reloadTable = NO;
		}
	}
	_isOpen = !_isOpen;
	
	[UIView commitAnimations];
}

#define kHelpInfoViewFrame					CGRectMake(52, 43, 316, 200)

- (void)valueChanged:(ImageBarControl*)sender {
	// hide all the views
	if (_isInGameHelpInitialized)
		_inGameHelp.view.hidden = YES;
	if (_isCreditsInitialized)
		_credits.view.hidden = YES;
	self.credits.view.hidden = YES;
	self.gameList.view.hidden = YES;
	self.caption.hidden = YES;
	
	switch (sender.selectedSegmentIndex) {
		case TabSave:	// save
			self.caption.text = kSaveGameCaption;
			self.gameList.view.hidden = NO;
			self.caption.hidden = NO;
			break;
			
		case TabLoad:	// load
			self.caption.text = kLoadGameCaption;
			self.gameList.view.hidden = NO;
			self.caption.hidden = NO;
			break;
			
		case TabHelp: // help
			if (!_isInGameHelpInitialized) {
				_inGameHelp.view.frame = kHelpInfoViewFrame;
				[self.view addSubview:_inGameHelp.view];
				[_inGameHelp viewDidAppear:NO];
				_isInGameHelpInitialized = YES;
			}
			_inGameHelp.view.hidden = NO;
			break;
			
		//case TabSettings: // settings
		//	break;
			
		case TabInfo:	// info
			if (!_isCreditsInitialized) {
				_credits.view.frame = kHelpInfoViewFrame;
				[self.view addSubview:_credits.view];
				_isCreditsInitialized = YES;
			}
			[self.credits.textView scrollRangeToVisible:NSMakeRange(210, 1)];
			self.credits.view.hidden = NO;
			break;
	}
}

- (void)setSidePanel:(SideMenuController*)value {
	if (value == _sidePanel)
		return;

	[value retain];
	
	_sidePanel.controlPanel = nil;
	[_sidePanel release];
	
	_sidePanel = value;
	_sidePanel.controlPanel = self;
}

- (void)dealloc {
	self.gameList = nil;
	self.credits = nil;
    [super dealloc];
}


@end

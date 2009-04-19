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

const double kDefaultAnimationDuration					= 250.0 / 1000.0;
const NSString *kSaveGameCaption						= @"Select a slot to SAVE game";
const NSString *kLoadGameCaption						= @"Select a slot to LOAD game";

// text color: #33cc00

@interface ControlPanelViewController()

- (void)valueChanged:(ImageBarControl*)sender;

@end

@implementation ControlPanelViewController

@synthesize stub=_stub, credits=_credits, gameList=_gameList, caption=_caption;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSArray *items = [NSArray arrayWithObjects:
					  @"btn_save.png", @"btn_save_active.png", 
					  @"btn_load.png", @"btn_load_active.png",
					  @"btn_info.png", @"btn_info_active.png", nil];
	_imageBar = [[ImageBarControl alloc] initWithItems:items];
	[self.view addSubview:_imageBar];
	_imageBar.center = CGPointMake(kControlPanelWidth/2, 285);
	[_imageBar addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	[_imageBar release];
	
	_gameList.view.frame = kSaveGameViewFrame;
	_gameList.delegate = self;
	[self.view addSubview:_gameList.view];
	
	self.caption.text = kSaveGameCaption;
	
	_credits.view.frame = kSaveGameViewFrame;
	_credits.view.hidden = YES;
	[self.view addSubview:_credits.view];
}

- (void)didSelectSaveGame:(SaveGameFileInfo*)info {
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
	
	[self hideShowControlPanel:self];
}

- (IBAction)hideShowControlPanel:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kDefaultAnimationDuration];
	
	if (_isOpen) {
		self.view.frame = kControlPanelFrame;
	} else {		
		self.view.frame = kControlPanelOpenFrame;
		if (_reloadTable) {
			[_gameList.tableView reloadData];
			_reloadTable = NO;
		}
	}
	_isOpen = !_isOpen;
	
	[UIView commitAnimations];
}

- (void)valueChanged:(ImageBarControl*)sender {
	BOOL hideCredits = YES;
	
	switch (sender.selectedSegmentIndex) {
		case 0:	// save
			self.caption.text = kSaveGameCaption;
			break;
		case 1:	// load
			self.caption.text = kLoadGameCaption;
			break;
		case 2:	// info
			hideCredits = NO;
			[self.credits.textView scrollRangeToVisible:NSMakeRange(210, 1)];
			break;
	}
	
	// TODO: these should be in their own parent views, so that it's easier to toggle
	self.credits.view.hidden = hideCredits;
	self.gameList.view.hidden = !hideCredits;
	self.caption.hidden = !hideCredits;
}

- (void)dealloc {
	self.gameList = nil;
	self.credits = nil;
    [super dealloc];
}


@end

//
//  GameControlsView.m
//  Flashback
//
//  Created by Stuart Carnie on 3/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GameControlsView.h"
#import "JoyStick.h"
#import "debug.h"
#import "iPhoneStub.h"
#import "GameNotifications.h"
#import "CocoaUtility.h"

@interface GameControlsView()

- (void)gameUINotification;

@end

@implementation GameControlsView

@synthesize playerInput, TheJoyStick, systemStub;
@synthesize fire=_fire, gun=_gun, items=_items, use=_use, menu=_menu;

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(gameUINotification) 
												 name:kGameUINotification 
											   object:nil];
	
	
	// load additional buttons
	_selectImage = [[UIImage imageFromResource:@"btn_select.png"] retain];
	_scoreImage = [[UIImage imageFromResource:@"btn_score.png"] retain];
	_skipImage = [[UIImage imageFromResource:@"btn_skip.png"] retain];
	_itemsImage = [[_items imageForState:UIControlStateNormal] retain];
	_useImage = [[_use imageForState:UIControlStateNormal] retain];
}

#define kUIControlStateAll		(UIControlStateNormal | UIControlStateHighlighted | UIControlStateSelected)
		
- (void)gameUINotification {
	UIMessage event;
	
	while (systemStub->dequeueMessage(&event)) {
		SystemStub::tagUIPhase phase = event.phase;
		BOOL enabled = phase == SystemStub::PHASE_END;
		double alpha = enabled ? 1.0 : 0.2;
		
		SystemStub::tagUINotification msg = event.msg;
		switch (msg) {
			case SystemStub::NOTIFY_INVENTORY:
				self.fire.alpha = alpha;
				self.fire.enabled = enabled;
				self.gun.alpha = alpha;
				self.gun.enabled = enabled;
				self.menu.alpha = alpha;
				self.menu.enabled = enabled;
				break;
				
			case SystemStub::NOTIFY_CUTSCENE:
				self.fire.alpha = alpha;
				self.fire.enabled = enabled;
				self.gun.alpha = alpha;
				self.gun.enabled = enabled;
				self.use.alpha = alpha;
				self.use.enabled = enabled;
				self.menu.alpha = alpha;
				self.menu.enabled = enabled;
				break;
				
			case SystemStub::NOTIFY_OPTIONS:
			case SystemStub::NOTIFY_ABORT_CONTINUE:
				self.fire.alpha = alpha;
				self.fire.enabled = enabled;
				self.gun.alpha = alpha;
				self.gun.enabled = enabled;
				self.items.alpha = alpha;
				self.items.enabled = enabled;
				self.menu.alpha = alpha;
				self.menu.enabled = enabled;
				break;
							
		}
		
		switch (msg) {
			case SystemStub::NOTIFY_INVENTORY:
				if (phase == SystemStub::PHASE_START) {
					[_items setImage:_selectImage forStates:kUIControlStateAll];
					[_use setImage:_scoreImage forStates:kUIControlStateAll];
				} else {
					[_items setImage:_itemsImage forStates:kUIControlStateAll];
					[_use setImage:_useImage forStates:kUIControlStateAll];
				}
				break;

			case SystemStub::NOTIFY_CUTSCENE:
				if (phase == SystemStub::PHASE_START) {
					[_items setImage:_skipImage forStates:kUIControlStateAll];
				} else {
					[_items setImage:_itemsImage forStates:kUIControlStateAll];
				}
				break;
				
			case SystemStub::NOTIFY_ABORT_CONTINUE:
			case SystemStub::NOTIFY_OPTIONS:
				if (phase == SystemStub::PHASE_START) {
					[_use setImage:_selectImage forStates:kUIControlStateAll];
				} else {
					[_use setImage:_useImage forStates:kUIControlStateAll];
				}
				break;
		}
	}
}

enum tagFireButtons {
	FireShift = 1,
	FireSpace,
	FireTab,
	FireEnter,
	FireOptions
};

-(IBAction)fireButton:(UIButton*)sender {
	FireButtonState state = (FireButtonState)sender.state;
	DLog(@"state = %d", state);
	
	switch(sender.tag) {
		case FireShift:
			TheJoyStick->setButtonOneState(state);
			break;
		case FireSpace:
			TheJoyStick->setButton2State(state);
			break;
		case FireEnter:
			TheJoyStick->setButton4State(state);
			break;
	}
}

-(IBAction)itemsButton:(id)sender {
	DLog(@"items button");
	playerInput->backspace = true;
}

-(IBAction)optionsButton:(id)sender {
	playerInput->escape = true;
	
}

- (void)dealloc {
	self.fire = nil;
	self.gun = nil;
	self.items = nil;
	self.use = nil;
	self.menu = nil;
	
	[_selectImage release];
	[_scoreImage release];
	[_skipImage release];
	[_itemsImage release];
	[_useImage release];
    [super dealloc];
}


@end

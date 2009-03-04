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

#import "InputControllerView.h"
#import "CGVector.h"
#import "JoyStick.h"
#import "debug.h"

@interface InputControllerView(PrivateMethods)

- (void)calculateDPadState;
- (void)setDPadState:(TouchStickDPadState)state;
- (void)onFireButton:(UIButton*)sender;

@end

@implementation InputControllerView

enum tagFireButtons {
	FireShift = 1,
	FireSpace,
	FireTab,
	FireEnter
};

@synthesize delegate, TheJoyStick;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		const int width = 70;
		const int height = 35;
		int y = 22;
		int spacing = height + 5;
		int x = (width / 2) + 10;
		
		UIButton *fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		fb.frame = CGRectMake(0, 0, width, height);
		fb.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[fb setTitle:@"Shift" forState:UIControlStateNormal];
		[self addSubview:fb];
		fb.center = CGPointMake(x, y);
		fb.tag = FireShift;
		[fb addTarget:self action:@selector(onFireButton:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchUpInside];
		
		y += spacing;
		fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		fb.frame = CGRectMake(0, 0, width, height);		
		fb.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[fb setTitle:@"Space" forState:UIControlStateNormal];
		[self addSubview:fb];
		fb.center = CGPointMake(x, y);
		fb.tag = FireSpace;
		[fb addTarget:self action:@selector(onFireButton:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchUpInside];

		y += spacing;
		fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		fb.frame = CGRectMake(0, 0, width, height);
		fb.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[fb setTitle:@"Tab" forState:UIControlStateNormal];
		[self addSubview:fb];
		fb.center = CGPointMake(x, y);
		fb.tag = FireTab;
		[fb addTarget:self action:@selector(onFireButton:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchUpInside];
		
		y += spacing;
		fb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		fb.frame = CGRectMake(0, 0, width, height);
		fb.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
		[fb setTitle:@"Enter" forState:UIControlStateNormal];
		[self addSubview:fb];
		fb.center = CGPointMake(x, y);
		fb.tag = FireEnter;
		[fb addTarget:self action:@selector(onFireButton:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchUpInside];
		
        // Initialization code
		_deadZone = 20.0f;	// radius, in pixels of the dead zone.
		_trackingStick = NO;
		_stickVector = new CGVector2D();
    }
    return self;
}

- (void)setDelegate:(id<InputControllerChangedDelegate>)theDelegate {
	delegate = theDelegate;
}

- (void)setTheJoyStick:(CJoyStick*)stick {
	TheJoyStick = stick;
}

- (void)onFireButton:(UIButton*)sender {
	FireButtonState state = (FireButtonState)sender.state;
	DLog(@"state = %d", state);
		
	switch(sender.tag) {
		case FireShift:
			TheJoyStick->setButtonOneState(state);
			break;
		case FireSpace:
			TheJoyStick->setButton2State(state);
			break;
		case FireTab:
			TheJoyStick->setButton3State(state);
			break;
		case FireEnter:
			TheJoyStick->setButton4State(state);
			break;
	}
}

- (void)layoutSubviews {
	CGPoint origin = self.frame.origin;
	CGSize size = self.frame.size;
	UIInterfaceOrientation current = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
	if (UIInterfaceOrientationIsLandscape(current)) {
		//button.frame = CGRectMake(0, 0, kButtonWidthLandscape, self.frame.size.height);
	} else {
		//button.frame = CGRectMake(0, 0, kButtonWidthPortrait, self.frame.size.height);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	DLog([NSString stringWithFormat:@"InputController down %@", touch]);
	
	_stickCenter = [touch locationInView:self];
	_stickVector->x = _stickVector->y = 0;
	
	[self setDPadState:DPadCenter];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {	
	UITouch *touch = [touches anyObject];
	DLog([NSString stringWithFormat:@"InputController move %@", touch]);
	_stickLocation = [touch locationInView:self];
	_stickVector->UpdateFromPoints(_stickCenter, _stickLocation);
	[self calculateDPadState];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	DLog([NSString stringWithFormat:@"InputController up %@", [touches anyObject]]);
	_stickVector->x = _stickVector->y = 0;
	[self setDPadState:DPadCenter];
}

- (void)dealloc {
	delete _stickVector;
    [super dealloc];
}

- (void)calculateDPadState {
	if (_stickVector->length() <= _deadZone) {
		[self setDPadState:DPadCenter];
		return;
	}
	
	CGFloat angle = _stickVector->angle();
	if (angle < 0) angle = 360 + angle;
	
	const CGFloat deg = 22.5;
	TouchStickDPadState dPadState;
	
	if (angle <= 0 + deg || angle > 360 - deg)
		dPadState = DPadRight;
	else if (angle <= 45 + deg && angle > 45 - deg)
		dPadState = DPadDownRight;
	else if (angle <= 90 + deg && angle > 90 - deg)
		dPadState = DPadDown;
	else if (angle <= 135 + deg && angle > 135 - deg)
		dPadState = DPadDownLeft;
	else if (angle <= 180 + deg && angle > 180 - deg)
		dPadState = DPadLeft;
	else if (angle <= 225 + deg && angle > 225 - deg)
		dPadState = DPadUpLeft;
	else if (angle <= 270 + deg && angle > 270 - deg)
		dPadState = DPadUp;
	else if (angle <= 315 + deg && angle > 315 - deg)
		dPadState = DPadUpRight;
	else
		dPadState = DPadCenter;

	[self setDPadState:dPadState];
}

- (void)setDPadState:(TouchStickDPadState)state {
	TouchStickDPadState oldState = TheJoyStick->dPadState();
	if (oldState != state) {
		TheJoyStick->setDPadState(state);
		[delegate joystickStateChanged:state];
	}
}


@end

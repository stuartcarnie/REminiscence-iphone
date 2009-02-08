/*
 Frodo, Commodore 64 emulator for the iPhone
 Copyright (C) 2007, 2008 Stuart Carnie
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

#import "JoystickView.h"
#import "debug.h"

@interface JoystickView(PrivateMembers)

- (UIImageView*)createViewFromImageNamed:(NSString*)name;

@end


@implementation JoystickView

/*
enum TouchStickDPadState {
	DPadCenter,
	DPadUp,
	DPadUpRight,
	DPadRight,
	DPadDownRight,
	DPadDown,
	DPadDownLeft,
	DPadLeft,
	DPadUpLeft
};
*/

static char* joystick_files[] = {
	"idle.png",
	"up.png",
	"right_up.png",
	"right.png",
	"right_down.png",
	"down.png",
	"left_down.png",
	"left.png",
	"left_up.png"
};

static char* firebutton_files[] = {
	"firebutton.png", "firebutton_active.png"
};

const int kJoystickTop			= 2;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.userInteractionEnabled = NO;
		
		background = [self createViewFromImageNamed:@"bg.png"];
        [self addSubview:background];

		for (int i = 0; i < sizeof(joystick_files) / sizeof(joystick_files[0]); i++) {
			joystick_images[i] = [UIImage imageNamed:[NSString stringWithCString:joystick_files[i]]]; 
		}

		for (int i = 0; i < sizeof(firebutton_files) / sizeof(firebutton_files[0]); i++) {
			firebutton_images[i] = [UIImage imageNamed:[NSString stringWithCString:firebutton_files[i]]]; 
		}
		
		fireButton = [[UIImageView alloc] initWithFrame:CGRectMake(10, kJoystickTop, 123, 153)];
		fireButton.image = firebutton_images[0];
		[self addSubview:fireButton];

		joystick = [[UIImageView alloc] initWithFrame:CGRectMake(140, kJoystickTop-5, 182, 168)];
		joystick.image = joystick_images[0];
		[self addSubview:joystick];
}
    return self;
}

- (UIImageView*)createViewFromImageNamed:(NSString*)name {
	UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
	return view;
}

- (void)joystickStateChanged:(TouchStickDPadState)state {
	DLog(@"JoystickView state changed: %d", state);
	
	joystick.image = joystick_images[state];
}

- (void)fireButton:(FireButtonState)state {
	DLog(@"JoystickView state changed: %d", state);
	
	fireButton.image = firebutton_images[state];
}

- (void)dealloc {
    [super dealloc];
}


@end

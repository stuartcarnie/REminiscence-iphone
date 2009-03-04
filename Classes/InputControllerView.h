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
#import "CGVector.h"
#import "JoyStick.h"

@protocol InputControllerChangedDelegate

- (void)joystickStateChanged:(TouchStickDPadState)state;
- (void)fireButton:(FireButtonState)state;

@end

@interface InputControllerView : UIView {
	CGPoint								_stickCenter;
	CGPoint								_stickLocation;
	CGVector2D							*_stickVector;
	BOOL								_trackingStick;
	CJoyStick							*TheJoyStick;
	
	float								_deadZone;		// represents the deadzone radius, where the DPad state will be considered DPadCenter
	
	id<InputControllerChangedDelegate>	delegate;
}

@property (nonatomic, assign)	id<InputControllerChangedDelegate>	delegate;
@property (nonatomic)			CJoyStick							*TheJoyStick;

@end

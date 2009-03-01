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

enum FireButtonState {
	FireButtonUp,
	FireButtonDown
};

class CJoyStick  {
public:
	CJoyStick() {
		_joystickState.state = 0;
	}
	
	TouchStickDPadState		dPadState() { return _joystickState.dPad; }
	FireButtonState			buttonOneState() { return _joystickState.button1; }
	FireButtonState			button2State() { return _joystickState.button2; }
	FireButtonState			button3State() { return _joystickState.button3; }
	FireButtonState			button4State() { return _joystickState.button4; }
	
	void					setDPadState(TouchStickDPadState value) { _joystickState.dPad = value; }
	void					setButtonOneState(FireButtonState value) { _joystickState.button1 = value; }
	void					setButton2State(FireButtonState value) { _joystickState.button2 = value; }
	void					setButton3State(FireButtonState value) { _joystickState.button3 = value; }
	void					setButton4State(FireButtonState value) { _joystickState.button4 = value; }

private:
	union {
		struct {
			TouchStickDPadState	dPad:4;

			FireButtonState		button1:1;
			FireButtonState		button2:1;
			FireButtonState		button3:1;
			FireButtonState		button4:1;
		};
		unsigned int state;
	} _joystickState;

};
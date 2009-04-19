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

#include "systemstub.h"
#include "util.h"
#include <CoreFoundation/CFDate.h>
#import <Foundation/Foundation.h>

#import "iPhoneStub.h"
#import "video.h"
#import "GameNotifications.h"
#import "NSNotificationAdditions.h"
#import "CNSRecursiveLock.h"
#import "FlashbackConfig.h"

double iPhoneStub::time_start = CFAbsoluteTimeGetCurrent();

const int kBytesPerPixel			= 2;
const int kBitsPerComponent			= 5;
const unsigned int kFormat			= kCGBitmapByteOrder16Little | kCGImageAlphaNoneSkipFirst;

void iPhoneStub::init(const char *title, uint16 w, uint16 h) {
	memset(&_pi, 0, sizeof(_pi));
	
	// create indexed color palette
	CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
	
	imageBuffer = (uint*)malloc(Video::GAMESCREEN_W * Video::GAMESCREEN_H * kBytesPerPixel + 16);
	context = CGBitmapContextCreate(imageBuffer, 
									Video::GAMESCREEN_W, Video::GAMESCREEN_H, kBitsPerComponent, 
									Video::GAMESCREEN_W * kBytesPerPixel, rgbColorSpace, kFormat);
	
	CFRelease(rgbColorSpace);
	
	_lock = [NSRecursiveLock new];
}

void iPhoneStub::destroy() {
	free(imageBuffer);
	imageBuffer = NULL;
	[_lock release];
	_lock = nil;
}

void iPhoneStub::uiNotification(tagUINotification msg, tagUIPhase phase) {
	CNSRecursiveLock autolock(_lock);
	
	UIMessage event = { msg, phase };
	_events.push(event);
	[[NSNotificationCenter defaultCenter] postNotificationOnMainThreadWithName:kGameUINotification object:nil];
}

bool iPhoneStub::dequeueMessage(UIMessage *event) {
	CNSRecursiveLock autolock(_lock);
	if (_events.size()) {
		*event = _events.front();
		_events.pop();
		return true;
	}
	
	return false;
}

void iPhoneStub::setPalette(const uint8 *pal, uint16 n) {
	assert(n <= 256);
	for (int i = 0; i < n; ++i) {
		uint8 r = pal[i * 3 + 0];
		uint8 g = pal[i * 3 + 1];
		uint8 b = pal[i * 3 + 2];
		
		palette2[i].r = r >> 3;
		palette2[i].g = g >> 3;
		palette2[i].b = b >> 3;
	}
}

void iPhoneStub::setPaletteEntry(uint8 i, const Color *c) {
	uint8 r = (c->r << 2) | (c->r & 3);
	uint8 g = (c->g << 2) | (c->g & 3);
	uint8 b = (c->b << 2) | (c->b & 3);
	palette2[i].r = r >> 3;
	palette2[i].g = g >> 3;
	palette2[i].b = b >> 3;
}

void iPhoneStub::getPaletteEntry(uint8 i, Color *c) {
	c->r = palette2[i].r;
	c->g = palette2[i].g;
	c->b = palette2[i].b;
//	c->r = palette2[i].r << 3;
//	c->g = palette2[i].g << 3;
//	c->b = palette2[i].b << 3;
}

void iPhoneStub::setOverscanColor(uint8 i) {
	_overscanColor = i;
}

void iPhoneStub::copyRect(int16 x, int16 y, uint16 w, uint16 h, const uint8 *buf, uint32 pitch) {
	// extend the dirty region by 1 pixel for scalers accessing 'outer' pixels
	--x;
	--y;
	w += 2;
	h += 2;
	
	if (x < 0) {
		x = 0;
	}
	if (y < 0) {
		y = 0;
	}
	if (x + w > Video::GAMESCREEN_W) {
		w = Video::GAMESCREEN_W - x;
	}
	if (y + h > Video::GAMESCREEN_H) {
		h = Video::GAMESCREEN_H - y;
	}
	
	CGRect br = CGRectMake(x, y, w, h);
	
	uint16 *p = (uint16 *)imageBuffer + y * Video::GAMESCREEN_W + x;
	buf += y * pitch + x;
	
	uint16* _pal = (uint16*)&palette2;

#if !TARGET_IPHONE_SIMULATOR
	struct {
		int pinc;
		int bufinc;
	} incs = { (Video::GAMESCREEN_W - w), (pitch - w) };

	asm volatile (
				  "ldr	r0, [%5]		\n\t"		// pinc
				  "ldr	r1, [%5, #4]	\n\t"		// bufinc
				  "pld	[%3]			\n\t"

				  ".align 4		\n\t"
				  "0:	\n\t"						// outer loop
				  "mov	r2, %4	\n\t"
				  
				  ".align 4		\n\t"
				  "1:	\n\t"						// inner loop
				  "ldrb	r3, [%3], #1	\n\t"
				  "mov r3, r3, LSL #1	\n\t"
				  "ldrh r3, [%2, r3]	\n\t"
				  "strh r3, [%1], #2	\n\t"
				  
				  "subs r2, r2, #1	\n\t"
				  "bne 1b	\n\t"					// inner loop end
				  
				  "add %1, %1, r0, LSL #1	\n\t"
				  "add %3, %3, r1	\n\t"
				  
				  "subs %0, %0, #1 \n\t"
				  "bne 0b"							// outer loop end
				  : 
				  : "r" (h), "r" (p), "r" (_pal), "r" (buf), "r" (w), "r" (&incs)
				  : "memory", "r0", "r1", "r2", "r3", "cc"
	);
#else
	uint32 hh = h;
	while (hh--) {
		uint32 ww = w;
		do {
			*p++ = _pal[*buf++];
		} while (--ww);
		p += (Video::GAMESCREEN_W - w);
		buf += (pitch - w);
	}
#endif
	if (_pi.dbgMask & PlayerInput::DF_DBLOCKS) {
		drawRect(&br, 0xE7, (uint16 *)imageBuffer + Video::GAMESCREEN_W + 1, Video::GAMESCREEN_W * 2);
	}
}

void iPhoneStub::drawRect(CGRect *rect, uint8 color, uint16 *dst, uint16 dstPitch) {
	uint16* _pal = (uint16*)&palette2;
	dstPitch >>= 1;
	int x1 = rect->origin.x;
	int y1 = rect->origin.y;
	int x2 = rect->origin.x + rect->size.width - 1;
	int y2 = rect->origin.y + rect->size.height - 1;
	assert(x1 >= 0 && x2 < Video::GAMESCREEN_W && y1 >= 0 && y2 < Video::GAMESCREEN_H);
	for (int i = x1; i <= x2; ++i) {
		*(dst + y1 * dstPitch + i) = *(dst + y2 * dstPitch + i) = _pal[color];
	}
	for (int j = y1; j <= y2; ++j) {
		*(dst + j * dstPitch + x1) = *(dst + j * dstPitch + x2) = _pal[color];
	}
}

void iPhoneStub::saveScreenShot(uint8 slot) {
	NSString *fileName = [DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"rs-savegame-%02d.png", slot]];
	CGImageRef img = GetImageBuffer();
	
	NSData *data = UIImagePNGRepresentation([UIImage imageWithCGImage:img]);
	[data writeToFile:fileName atomically:NO];
	
	CFRelease(img);
}

void iPhoneStub::updateScreen(uint8 shakeOffset) {
	hasImageChanged = YES;
}

void iPhoneStub::processEvents() {
	switch (TheJoyStick.dPadState()) {
		case DPadCenter:
			_pi.dirMask = 0;
			break;
			
		case DPadUp:
			_pi.dirMask = PlayerInput::DIR_UP;
			break;
			
		case DPadUpRight:
			_pi.dirMask = PlayerInput::DIR_UP | PlayerInput::DIR_RIGHT;
			break;
			
		case DPadRight:
			_pi.dirMask = PlayerInput::DIR_RIGHT;
			break;
			
		case DPadDownRight:
			_pi.dirMask = PlayerInput::DIR_DOWN | PlayerInput::DIR_RIGHT;
			break;
			
		case DPadDown:
			_pi.dirMask = PlayerInput::DIR_DOWN;
			break;
			
		case DPadDownLeft:
			_pi.dirMask = PlayerInput::DIR_DOWN | PlayerInput::DIR_LEFT;
			break;
			
		case DPadLeft:
			_pi.dirMask = PlayerInput::DIR_LEFT;
			break;
			
		case DPadUpLeft:
			_pi.dirMask = PlayerInput::DIR_UP | PlayerInput::DIR_LEFT;
			break;
	}
	
	_pi.shift = TheJoyStick.buttonOneState() == FireButtonDown;
	_pi.space = TheJoyStick.button2State() == FireButtonDown;
	_pi.enter = TheJoyStick.button4State() == FireButtonDown;
	
	// run for 10ms
	CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10.0/1000.0, false);
}

void iPhoneStub::sleep(uint32 duration) {
	usleep(duration * 1000);
}

uint32 iPhoneStub::getTimeStamp() {
	double now = CFAbsoluteTimeGetCurrent();
	now = now - time_start;
	return (uint32)(now * 1000UL);
}

void iPhoneStub::AudioCallbackHandler(uint8 *buf, uint32 *size) {
	audioCallback(audioCallbackParam, audioCallbackBuffer, AUDIO_CALLBACK_BUFFER_SIZE);
	int16* dst = (int16*)buf;
	int8*  src = (int8*)audioCallbackBuffer;
	int i = (*size >> 1);
	do {
		*dst++ = (int16)*src++ * 128;
	} while (--i);
}

void iPhoneStub::startAudio(AudioCallback callback, void *param) {
	_audio				= new CAudioUnitQueueManager(this, (double)SOUND_SAMPLE_RATE, MonoSound);
	audioCallback		= callback;
	audioCallbackParam	= param;
	audioCallbackBuffer = (uint8*)malloc(AUDIO_CALLBACK_BUFFER_SIZE);
	_audio->start();
}

void iPhoneStub::stopAudio() {
	_audio->stop();
	free(audioCallbackBuffer);
	delete _audio;
}

uint32 iPhoneStub::getOutputSampleRate() {
	return SOUND_SAMPLE_RATE;
}

void *iPhoneStub::createMutex() {
	return NULL;
}

void iPhoneStub::destroyMutex(void *mutex) {
}

void iPhoneStub::lockMutex(void *mutex) {
}

void iPhoneStub::unlockMutex(void *mutex) {
}

SystemStub* SystemStub_create() {
	return new iPhoneStub();
}
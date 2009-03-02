/*
 *  OSX_Stub.cpp
 *  Another World
 *
 *  Created by Stuart Carnie on 1/3/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */


#include "systemstub.h"
#include "util.h"
#include <CoreFoundation/CFDate.h>
#import <Foundation/Foundation.h>

#import "iPhoneStub.h"
#import "video.h"

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
}

void iPhoneStub::destroy() {
	free(imageBuffer);
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

const float kGammaCorrectionCurve = 1/1.8f;

inline Color gammaCorrection(const Color *c) {
	Color result;
	float r = c->r / 255.0;
	float g = c->g / 255.0;
	float b = c->b / 255.0;
	result.r = MIN(pow(r, kGammaCorrectionCurve), 1.0) * 255.99;
	result.g = MIN(pow(g, kGammaCorrectionCurve), 1.0) * 255.99;
	result.b = MIN(pow(b, kGammaCorrectionCurve), 1.0) * 255.99;
	return result;
}

void iPhoneStub::setPaletteEntry(uint8 i, const Color *c) {
	uint8 r = (c->r << 2) | (c->r & 3);
	uint8 g = (c->g << 2) | (c->g & 3);
	uint8 b = (c->b << 2) | (c->b & 3);
	palette2[i].r = r >> 3;
	palette2[i].g = g >> 3;
	palette2[i].b = b >> 3;
	
	//Color gammaCorrected = gammaCorrection(c);
	//palette2[i].r = gammaCorrected.r >> 3;
	//palette2[i].g = gammaCorrected.g >> 3;
	//palette2[i].b = gammaCorrected.b >> 3;
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
	
	uint16 *p = (uint16 *)imageBuffer + (y + 1) * Video::GAMESCREEN_W + (x + 1);
	buf += y * pitch + x;
	
	uint16* _pal = (uint16*)&palette2;
	
	while (h--) {
		for (int i = 0; i < w; ++i) {
			p[i] = _pal[buf[i]];
		}
		p += Video::GAMESCREEN_W;
		buf += pitch;
	}
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
	_pi.backspace = TheJoyStick.button3State() == FireButtonDown;
	_pi.enter = TheJoyStick.button4State() == FireButtonDown;
	
	// TODO: Improve this using a message queue
	// reset the other fire buttons to up state
	//TheJoyStick.setButton2State(FireButtonUp);
	TheJoyStick.setButton3State(FireButtonUp);
	//TheJoyStick.setButton4State(FireButtonUp);
	
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
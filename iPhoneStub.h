/*
 *  iPhoneStub.h
 *  Another World
 *
 *  Created by Stuart Carnie on 1/3/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "systemstub.h"
#import <Foundation/Foundation.h>
#import "JoyStick.h"
#import "AudioUnitQueueManager.h"

@class	TimerHandler;

struct iPhoneStub : SystemStub, CallbackHandler {
	enum {
		SOUND_SAMPLE_RATE			= 44100,
#if TARGET_IPHONE_SIMULATOR
		AUDIO_CALLBACK_BUFFER_SIZE	= 512,
#else
		AUDIO_CALLBACK_BUFFER_SIZE	= 2048,
#endif
	};
	
	iPhoneStub() {}
	virtual void init(const char *title, uint16 w, uint16 h);
	virtual void destroy();

	virtual void setPalette(const uint8 *pal, uint16 n);
	virtual void setPaletteEntry(uint8 i, const Color *c);
	virtual void getPaletteEntry(uint8 i, Color *c);
	virtual void setOverscanColor(uint8 i);
	virtual void copyRect(int16 x, int16 y, uint16 w, uint16 h, const uint8 *buf, uint32 pitch);
	virtual void updateScreen(uint8 shakeOffset);
	
	virtual void processEvents();
	virtual void sleep(uint32 duration);
	virtual uint32 getTimeStamp();
	
	virtual void startAudio(AudioCallback callback, void *param);
	virtual void stopAudio();
	virtual uint32 getOutputSampleRate();
	
	virtual void *createMutex();
	virtual void destroyMutex(void *mutex);
	virtual void lockMutex(void *mutex);
	virtual void unlockMutex(void *mutex);
	
	virtual void AudioCallbackHandler(uint8 *buf, uint32 *size);
	
	CGImageRef GetImageBuffer() { return CGBitmapContextCreateImage(context); }
	
	BOOL			hasImageChanged;
	CJoyStick		TheJoyStick;
	
private:
	void drawRect(CGRect *rect, uint8 color, uint16 *dst, uint16 dstPitch);
	
	uint8					_overscanColor;
	static double			time_start;
	uint					*imageBuffer;
	CGContextRef			context;
	CAudioUnitQueueManager	*_audio;
	AudioCallback			audioCallback;
	void*					audioCallbackParam;
	uint8*					audioCallbackBuffer;

#pragma pack(push,1)
	struct ColorPalette2 {
		unsigned char b:5;
		unsigned char g:5;
		unsigned char r:5;
	} palette2[256];
#pragma pack(pop)
};

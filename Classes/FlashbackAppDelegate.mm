//
//  FlashbackAppDelegate.m
//  Flashback
//
//  Created by Stuart Carnie on 1/6/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "FlashbackAppDelegate.h"
#import "EmulationViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "debug.h"
#import "iPhoneStub.h"

@implementation FlashbackAppDelegate

@synthesize window, mainController, emulationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	[window addSubview:mainController.view];
    [window makeKeyAndVisible];
	
	OSStatus res = AudioSessionInitialize(NULL, NULL, NULL, NULL);
	UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
	res = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	Float32 preferredBufferSize = 2048.0 / (Float32)iPhoneStub::SOUND_SAMPLE_RATE;
	res = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, 
								  sizeof(preferredBufferSize), &preferredBufferSize);
	if (res != 0)
		DLog(@"Error setting audio buffer duration"); 
	else
		DLog(@"successfully set audio buffer duration");
	
	res = AudioSessionSetActive(true);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	DLog(@"Application received applicationDidBecomeActive message");
	[self.emulationController resume];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	DLog(@"Application received applicationWillResignActive message");
	[self.emulationController pause];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	DLog(@"Application received terminate message");
	[self.emulationController saveDefaultGame];
}



- (void)dealloc {
    [window release];
    [super dealloc];
}


@end

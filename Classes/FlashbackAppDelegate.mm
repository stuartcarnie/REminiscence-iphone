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

#import "FlashbackAppDelegate.h"
#import "EmulationViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "debug.h"
#import "iPhoneStub.h"
#import "FlurryAPI.h"

@implementation FlashbackAppDelegate

@synthesize window, emulationController;

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[FlurryAPI startSession:@"5QKBV2QBJCEMCVQ9743Z"];

	FlashbackDataLoader *loader = [FlashbackDataLoader new];
	if ([loader checkStatus]) {
		[window addSubview:emulationController.view];
		[window makeKeyAndVisible];
	} else {
		InstallView *view = [[InstallView alloc] initWithFrame:[window frame]];
		[window addSubview:view];
		[window makeKeyAndVisible];
		[view startWithDelegate:self andLoader:loader];
		[view release];
	}

	[loader release];
	
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

- (void)didFinishInstallView {
	[window addSubview:emulationController.view];
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
	[self.emulationController quit];
}

- (void)dealloc {
	self.emulationController = nil;
    [window release];
    [super dealloc];
}


@end

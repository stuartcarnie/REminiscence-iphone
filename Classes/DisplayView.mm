//
//  DisplayView.mm
//  Another World
//
//  Created by Stuart Carnie on 1/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DisplayView.h"
#import "iPhoneStub.h"
#import <QuartzCore/QuartzCore.h>

@interface DisplayView() 

- (void)updateScreen;
@end

@implementation DisplayView

@synthesize stub;

const double kFramesPerSecond = 20;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = YES;
		_framesPerSecond = kFramesPerSecond;
    }
    return self;
}

- (void)startTimer {
	_timer = [NSTimer scheduledTimerWithTimeInterval:(1 / _framesPerSecond) target:self selector:@selector(updateScreen) userInfo:nil repeats:YES];
}

- (void)stopTimer {
	[_timer invalidate];
	_timer = nil;
}

- (void)updateScreen {
	if (stub->hasImageChanged) {
		CALayer *layer = self.layer;
		CGImageRef image = stub->GetImageBuffer();
		layer.contents = (id)image;
		layer.contentsRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
		CFRelease(image);
		stub->hasImageChanged = NO;
	}
}

- (void)dealloc {
    [super dealloc];
}


@end

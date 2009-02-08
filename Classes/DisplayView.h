//
//  DisplayView.h
//  Another World
//
//  Created by Stuart Carnie on 1/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

class iPhoneStub;

@interface DisplayView : UIView {
	NSTimer			*_timer;
	iPhoneStub		*stub;
	double			_framesPerSecond;
}

@property (nonatomic) iPhoneStub	*stub;

- (void)startTimer;
- (void)stopTimer;

@end

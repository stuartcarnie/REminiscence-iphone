//
//  SplashView.m
//  Flashback
//
//  Created by Stuart Carnie on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InstallView.h"
#import "CocoaUtility.h"
#import "UIApplication-Network.h"

const double kAnimationDuration		= 500.0 / 1000.0;
const double kImageDisplayTime		= 1.5;

@interface InstallView()

- (void)showImageNamed:(NSString*)image;
- (void)beginDownload;
- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context;

- (void)createInstallSheet;

@end

@implementation InstallView

#define degreesToRadian(x) (M_PI  * x / 180.0)
#define kLandscapeTransform CGAffineTransformRotate(CGAffineTransformIdentity, degreesToRadian(90.0))

- (void)startWithDelegate:(id<InstallViewDelegate>)theDelegate andLoader:(FlashbackDataLoader*)theLoader {
	_animating = YES;
	self.transform = kLandscapeTransform;
	delegate = theDelegate;
	loader = [theLoader retain];
	[self showImageNamed:@"splash01.png"];
}

- (void)showImageNamed:(NSString*)image {
	if (previous) {
		[previous removeFromSuperview];
		previous = current;
	}
	
	current = [UIImageView newViewFromImageResource:image];
	current.alpha = 0.0;
	current.center = CGPointMake(160, 240);
	[self addSubview:current];
	
	[UIView beginAnimations:image context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kAnimationDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	current.alpha = 1.0;
	previous.alpha = 0.0;
	
	[UIView commitAnimations];
}

- (void)beginDownload {
	_animating = NO;
	if (![UIApplication hasNetworkConnection]) {
		[[[[UIAlertView alloc] initWithTitle:@"No Network" 
									 message:@"You'll need an active network connection to download the game data." 
									delegate:nil 
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];

		[self showImageNamed:@"splash01.png"];
		return;
	}
	// begin checking / downloading
	[self createInstallSheet];
	[loader downloadFromURL:nil progressDelegate:self inBackground:YES];
}

- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	if (!_animating)
		return;
	
	if ([animationID isEqual:@"splash01.png"]) {
		[self performSelector:@selector(showImageNamed:) withObject:@"splash02.png" afterDelay:kImageDisplayTime];
	} else if ([animationID isEqual:@"splash02.png"]) {
		[self performSelector:@selector(showImageNamed:) withObject:@"splash03.png" afterDelay:kImageDisplayTime];
	} else if ([animationID isEqual:@"splash03.png"]) {
		[self performSelector:@selector(showImageNamed:) withObject:@"splash04.png" afterDelay:kImageDisplayTime];
	} else {
		[self beginDownload];
	}
}

- (void)createInstallSheet {
	label = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, 330, 20)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.opaque = NO;	
	[self addSubview:label];
	[label release];
	
	progbar = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0f, 330.0f, 320.0f, 20.0f)];
	[progbar setProgressViewStyle: UIProgressViewStyleDefault]; 
	[self addSubview:progbar];
	[progbar release];
}

- (void)setProgress:(float)value {
	[progbar setProgress:value];
}

- (void)setMessage:(NSString*)message {
	label.text = message;
}

- (void)didFinish:(BOOL)status {
	if (!status) {
		[[[[UIAlertView alloc] initWithTitle:@"Error" 
									 message:@"Unable to download game data.\nPlease try again later." 
									delegate:nil 
						   cancelButtonTitle:@"OK" 
						   otherButtonTitles:nil] autorelease] show];
		[self showImageNamed:@"splash01.png"];
	} else {
		[self removeFromSuperview];
		[delegate didFinishInstallView];
	}
}

- (void)dealloc {
	[loader release];
    [super dealloc];
}


@end

//
//  SplashView.m
//  Flashback
//
//  Created by Stuart Carnie on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InstallView.h"
#import "CocoaUtility.h"

const double kAnimationDuration = 500.0 / 1000.0;

@interface InstallView()

-(void)step1;
-(void)step2;
-(void)step3;
-(void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context;

- (void)createInstallSheet;

@end

@implementation InstallView

#define degreesToRadian(x) (M_PI  * x / 180.0)
#define kLandscapeTransform CGAffineTransformRotate(CGAffineTransformIdentity, degreesToRadian(90.0))

-(void)startWithDelegate:(id<InstallViewDelegate>)theDelegate andLoader:(FlashbackDataLoader*)theLoader {
	self.transform = kLandscapeTransform;
	delegate = theDelegate;
	loader = [theLoader retain];
	[self step1];
}

-(void)step1 {
	UIView *view = [UIImageView newViewFromImageResource:@"splash01.png"];
	//view.transform = kLandscapeTransform;
	view.alpha = 0.0;
	view.center = CGPointMake(160, 240);
	[self addSubview:view];
	
	[UIView beginAnimations:@"splash.step1" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kAnimationDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	view.alpha = 1.0;
	
	[UIView commitAnimations];
}

-(void)step2 {
	UIView *view = [UIImageView newViewFromImageResource:@"splash02.png"];
	//view.transform = kLandscapeTransform;
	view.alpha = 0.0;
	view.center = CGPointMake(160, 240);
	[self addSubview:view];
	
	[UIView beginAnimations:@"splash.step2" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kAnimationDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	view.alpha = 1.0;
	[[[self subviews] objectAtIndex:0] setAlpha:0.0];
	
	[UIView commitAnimations];
}

-(void)step3 {
	// begin checking / downloading
	[self createInstallSheet];
	[loader downloadFromURL:nil progressDelegate:self inBackground:YES];
}

- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(void *)context {
	if ([animationID isEqual:@"splash.step1"]) {
		[self performSelector:@selector(step2) withObject:nil afterDelay:3.0];
	} else {
		[self step3];
	}
}

- (void)createInstallSheet {
	label = [[UILabel alloc] initWithFrame:CGRectMake(0, 270, 300, 20)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.opaque = NO;	
	[self addSubview:label];
	[label release];
	
	progbar = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0f, 300.0f, 320.0f, 20.0f)];
	[progbar setProgressViewStyle: UIProgressViewStyleDefault]; 
	[self addSubview:progbar];
	[progbar release];
}

- (void)setProgress:(float)current {
	[progbar setProgress:current];
}

- (void)setMessage:(NSString*)message {
	label.text = message;
}

- (void)didFinish:(BOOL)status {
	//[installSheet dismissWithClickedButtonIndex:0 animated:NO];
	[self removeFromSuperview];
	[delegate didFinishInstallView];
}

- (void)dealloc {
	[loader release];
    [super dealloc];
}


@end

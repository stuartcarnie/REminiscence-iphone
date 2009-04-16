//
//  SplashView.h
//  Flashback
//
//  Created by Stuart Carnie on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashbackDataLoader.h"

@protocol InstallViewDelegate

-(void)didFinishInstallView;

@end

@class FlashbackDataLoader;

@interface InstallView : UIView<MMProgressReport> {
	UILabel								*label;
	UIProgressView						*progbar;
	id<InstallViewDelegate>				delegate;
	FlashbackDataLoader					*loader;
}

-(void)startWithDelegate:(id<InstallViewDelegate>)theDelegate andLoader:(FlashbackDataLoader*)theLoader;

@end

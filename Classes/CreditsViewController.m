//
//  CreditsView.m
//  Flashback
//
//  Created by Stuart Carnie on 4/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CreditsViewController.h"


@implementation CreditsViewController

@synthesize textView=_textView;

- (void)dealloc {
	self.textView = nil;
    [super dealloc];
}


@end

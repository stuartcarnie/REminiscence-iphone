//
//  ControlPanelViewController.m
//  Flashback
//
//  Created by Stuart Carnie on 4/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ControlPanelViewController.h"

const double kDefaultAnimationDuration					= 250.0 / 1000.0;


@implementation ControlPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(IBAction)hideShowControlPanel:(id)sender {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:kDefaultAnimationDuration];
	
	if (_isOpen) {
		self.view.frame = kControlPanelFrame;
	} else {		
		self.view.frame = kControlPanelOpenFrame;
	}
	_isOpen = !_isOpen;
	
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

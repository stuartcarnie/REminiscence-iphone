//
//  InGameHelpController.m
//  Flashback
//
//  Created by Stuart Carnie on 5/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InGameHelpController.h"


@implementation InGameHelpController

- (void)viewDidAppear:(BOOL)animated {
	UIWebView *webView = (UIWebView*)self.view;
	[webView setBackgroundColor:[UIColor clearColor]];
	[webView setOpaque:NO];
	NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"InGameHelp.html"]]];
	[webView loadRequest:req];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
}


@end

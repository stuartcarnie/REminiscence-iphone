//
//  SideMenuController.mm
//  Flashback
//
//  Created by Stuart Carnie on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SideMenuController.h"
#import "iPhoneStub.h"
#import "UserDefaults.h"

@interface SideMenuController()
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@implementation SideMenuController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	_fullScreen.selected = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingFullScreen];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		self.stub->_pi.abort = true;
		self.stub->_pi.backspace = true;	// exit items screen
	}
}

- (IBAction)restartGame:(id)sender {
	[[[[UIAlertView alloc] initWithTitle:@"Confirm"
								message:@"Are you sure you wish to restart?" 
							   delegate:self 
					   cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] autorelease] show];
}

- (void)viewWillDisappear:(BOOL)animated {
	BOOL newValue = _fullScreen.selected;
	[[NSUserDefaults standardUserDefaults] setBool:newValue forKey:kSettingFullScreen];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)toggleFullScreen:(UIButton*)sender {
	sender.selected = !sender.selected;
}

- (void)dealloc {
    [super dealloc];
}

@synthesize stub=_stub, fullScreen=_fullScreen;

@end

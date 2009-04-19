//
//  CreditsView.h
//  Flashback
//
//  Created by Stuart Carnie on 4/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreditsViewController : UIViewController {
	UITextView			*_textView;
}

@property(nonatomic, retain) IBOutlet	UITextView		*textView;

@end

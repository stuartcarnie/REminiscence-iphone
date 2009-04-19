//
//  SaveGameBrowserController.h
//  Flashback
//
//  Created by Stuart Carnie on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveGameCell.h"
#import "SaveGameFileInfo.h"

@interface SaveGameBrowserController : UITableViewController {
	IBOutlet SaveGameCell			*__newcell;
	
	NSArray							*_files;
	id								_delegate;
}

@property(nonatomic, assign)		id		delegate;

@end

#define kSaveGameViewFrame					CGRectMake(52, 45, 316, 196)

/////////////////////////////////////////////////////

@protocol SaveGameBrowserControllerDelegate <NSObject>

@optional

- (void)didSelectSaveGame:(SaveGameFileInfo*)info;

@end

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
	NSDateFormatter					*_dateFormat;
}

@property(nonatomic, assign)		id		delegate;

@end

#define kSaveGameViewFrame					CGRectMake(52, 67, 316, 174)

/////////////////////////////////////////////////////

@protocol SaveGameBrowserControllerDelegate <NSObject>

@optional

- (void)didSelectSaveGame:(SaveGameFileInfo*)info;

@end

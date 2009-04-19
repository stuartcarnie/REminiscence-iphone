//
//  SaveGameBrowserController.m
//  Flashback
//
//  Created by Stuart Carnie on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SaveGameBrowserController.h"
#import "SaveGameFileInfo.h"

@interface SaveGameBrowserController()

- (SaveGameCell*)getNewCell;

@end

@implementation SaveGameBrowserController

@synthesize delegate=_delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

	_files = [SaveGameFileInfo newGameList];
	_dateFormat = [NSDateFormatter new];
	[_dateFormat setDateFormat:@"hh:mm a, MM-dd"];
}

- (SaveGameCell*)getNewCell {
	[[NSBundle mainBundle] loadNibNamed:@"SaveGameCell" owner:self options:nil];
	return __newcell;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_files count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SaveGameCell *cell = (SaveGameCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self getNewCell];
    }
	    
    // Set up the cell...
	SaveGameFileInfo *info = [_files objectAtIndex:[indexPath row]];
	cell.title.text = info.title;
	if (info.saveDate)
		cell.saveDate.text = [_dateFormat stringFromDate:info.saveDate];
	else
		cell.saveDate.text = [NSString string];
	
	cell.slotNumber.text = [NSString stringWithFormat:@"%02d", info.slot];
	cell.screenShot = info.screenShot;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	SaveGameFileInfo *info = [_files objectAtIndex:[indexPath row]];
	if ([_delegate respondsToSelector:@selector(didSelectSaveGame:)]) {
		[_delegate didSelectSaveGame:info];
	}
}

- (void)dealloc {
	[_files release];
    [super dealloc];
}


@end


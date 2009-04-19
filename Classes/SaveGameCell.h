//
//  SaveGameCell.h
//  Flashback
//
//  Created by Stuart Carnie on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreenShotImageFrame	CGRectMake(15, 4, 55, 55)

@interface SaveGameCell : UITableViewCell {
	IBOutlet UIImageView	*_saveImage;
	UILabel					*_title;
	UILabel					*_saveDate;
	UILabel					*_slotNumber;
}

@property(nonatomic, assign) IBOutlet UIImage		*screenShot;
@property(nonatomic, retain) IBOutlet UILabel		*title;
@property(nonatomic, retain) IBOutlet UILabel		*saveDate;
@property(nonatomic, retain) IBOutlet UILabel		*slotNumber;

@end

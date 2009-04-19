//
//  SaveGameCell.m
//  Flashback
//
//  Created by Stuart Carnie on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SaveGameCell.h"


@implementation SaveGameCell

@synthesize title=_title, saveDate=_saveDate, slotNumber=_slotNumber;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}

- (UIImage*)screenShot {
	return _saveImage.image;
}

- (void)setScreenShot:(UIImage*)value {
	_saveImage.image = value;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end

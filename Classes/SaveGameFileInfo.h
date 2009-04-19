//
//  SaveGameFileInfo.h
//  Flashback
//
//  Created by Stuart Carnie on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SaveGameFileInfo : NSObject {
	NSString		*_title;
	NSUInteger		_level;
	NSDate			*_saveDate;
	NSString		*_fileName;
	BOOL			_empty;
	NSUInteger		_slot;
	UIImage			*_screenShot;
	BOOL			_reload;
}

/*! returns a list of all SaveGameFileInfo instances
 */
+ (NSArray*)newGameList;

@property(nonatomic, retain)	NSString*	fileName;
@property(nonatomic)			BOOL		empty;
@property(nonatomic)			NSUInteger	slot;
@property(nonatomic, retain)	NSString*	title;
@property(nonatomic, retain)	NSDate*		saveDate;
@property(nonatomic, readonly)	UIImage*	screenShot;

- (void)clearInfo;


@end

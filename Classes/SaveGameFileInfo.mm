//
//  SaveGameFileInfo.m
//  Flashback
//
//  Created by Stuart Carnie on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SaveGameFileInfo.h"
#import "FlashbackConfig.h"
#import "file.h"
#import "game.h"
#import "CocoaUtility.h"

@interface SaveGameFileInfo()

- (id)initFromFile:(NSString*)fileName andSlot:(NSUInteger)slot;
- (void)reloadInfo;

@end

@implementation SaveGameFileInfo

@synthesize fileName=_fileName, empty=_empty, slot=_slot, title=_title, saveDate=_saveDate;

+ (NSArray*)newGameList {
	NSMutableArray *files = [NSMutableArray new];
	for(int i=1; i<kMaxGameSlots; i++) {
		NSString *file = [NSString stringWithFormat:@"rs-savegame-%02d.state", i];
		SaveGameFileInfo *fileInfo = [[SaveGameFileInfo alloc] initFromFile:file andSlot:i];
		[files addObject:fileInfo];
		[fileInfo release];
	}
	return files;
}

- (id)initFromFile:(NSString*)fileName andSlot:(NSUInteger)slot {
	self = [super init];
	
	self.fileName = fileName;
	_slot = slot;
	[self clearInfo];
		
	return self;
}

- (void)clearInfo {
	self.title = @"Empty";
	self.empty = YES;	
	_reload = YES;
}

- (void)reloadInfo {
	if (!_reload) return;
	
	self.title = @"Empty";
	self.empty = YES;

	File f(true);
	if (!f.open([self.fileName UTF8String], [DOCUMENTS_FOLDER UTF8String], "rb")) {
		return;
	}
		
	uint32 id = f.readUint32BE();
	if (id != 'FBSV') {
		return;
	}
	
	uint16 ver = f.readUint16BE();
	if (ver != 2) {
		return;
	}
	
	char hdrdesc[32];
	f.read(hdrdesc, sizeof(hdrdesc));
	int level = -1, room = -1;
	
	if (sscanf(hdrdesc, "level=%d room=%d", &level, &room) == 2) {
		self.title = [NSString stringWithFormat:@"Level %d", level];
	}
	
	NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:self.fileName] 
																		  error:nil];
	self.saveDate = [attr valueForKey:NSFileModificationDate];
	self.empty = NO;
	if (_screenShot) {
		[_screenShot release];
		_screenShot = nil;
	}
	_reload = NO;
}

- (NSString*)title {
	if (_reload) [self reloadInfo];
	
	return _title;
}

- (NSDate*)saveDate {
	if (_reload) [self reloadInfo];
	
	return _saveDate;
}

- (UIImage*)screenShot {
	if (_reload) [self reloadInfo];
	if (_empty) return nil;
	
	if (!_screenShot) {
		_screenShot = [UIImage imageFromFile:[DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"rs-savegame-%02d.png", _slot]]];
	}
	return _screenShot;
}

@end

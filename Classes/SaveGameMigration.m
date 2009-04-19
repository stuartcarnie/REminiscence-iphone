/*
 *  SaveGameMigration.c
 *  Flashback
 *
 *  Created by Stuart Carnie on 4/18/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include "SaveGameMigration.h"
#include "FlashbackConfig.h"

@implementation SaveGameMigration

+ (void)migrateSaveGames {
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	NSArray *extensions = [[NSArray alloc] initWithObjects:@"state", nil];
	NSDirectoryEnumerator *direnum = [mgr enumeratorAtPath:DOCUMENTS_FOLDER];
	NSArray *fileNames = [[direnum allObjects] pathsMatchingExtensions:extensions];
	NSUInteger i = 1;
	for(NSString *file in fileNames) {
		if ([file hasPrefix:@"rs-level"]) {
			NSString *newFile = [DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"rs-savegame-%02d.state", i++]];
			[mgr movePath:[DOCUMENTS_FOLDER stringByAppendingPathComponent:file] toPath:newFile handler:nil];
		}
	}
}

@end

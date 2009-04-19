//
//  FlashbackDataLoader.h
//  Flashback
//
//  Created by Stuart Carnie on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashbackConfig.h"

@protocol MMProgressReport;

@interface FlashbackDataLoader : NSObject {
	id<MMProgressReport>	delegate;
	NSArray					*_urls;
}

/*! Check if the Flashback data exists in Documents/data and is valid
 */
- (BOOL)checkStatus;

/*! Download game data file from specified URL
 */
- (BOOL)downloadFromURL:(NSURL*)url progressDelegate:(id<MMProgressReport>)delegate inBackground:(BOOL)inBackground;

@end

@protocol MMProgressReport

- (void)setProgress:(float)value;
- (void)setMessage:(NSString*)message;
- (void)didFinish:(BOOL)status;

@end


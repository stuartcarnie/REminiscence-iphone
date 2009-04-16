//
//  FlashbackDataLoader.m
//  Flashback
//
//  Created by Stuart Carnie on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FlashbackDataLoader.h"
#import <Foundation/NSThread.h>
#import "LiteUnzip.h"

#define DATA_FILE [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.zip"]
#define kEstimatedDataFileSizeInBytes	3045299

/*! Handles downloading the url list
 */
@interface MMURLList : NSObject {
	BOOL		_dataDone;
	NSArray		*_urls;
	FlashbackDataLoader	*_loader;
}

-(id)initWithLoader:(FlashbackDataLoader*)loader;
-(NSArray*)getURLs;

@end

/*! Handles downloading the data.zip file
 */
@interface MMDownloadDataFile : NSObject {
	BOOL				_dataDone;
	NSOutputStream		*_dataFile;
	FlashbackDataLoader	*_loader;
	long long			_expectedBytes;
	BOOL				_usingEstimatedBytes;
	long long			_downloadedBytes;
}

-(id)initWithLoader:(FlashbackDataLoader*)loader;
-(BOOL)getDataFromURL:(NSURL*)url;

@end

@interface FlashbackDataLoader()

-(NSURL*)findURL;
-(void)doDownloadFromURL:(NSURL*)url;
-(BOOL)extractDataFile;

-(void)doSetProgress:(NSNumber*)current;
-(void)doSetMessage:(NSString*)message;
-(void)doDidFinish:(NSNumber*)status;

@end

@implementation FlashbackDataLoader

-(BOOL)checkStatus {
	NSFileManager *mgr = [NSFileManager defaultManager];
	
	if (![mgr fileExistsAtPath:DATA_FOLDER])
		return NO;
	
	return YES;
}

-(BOOL)downloadFromURL:(NSURL*)url progressDelegate:(id<MMProgressReport>)theDelegate inBackground:(BOOL)inBackground {
	delegate = theDelegate;
	
	NSFileManager *mgr = [NSFileManager defaultManager];
	if ([mgr fileExistsAtPath:DATA_FOLDER]) {
		// clear old data folder
		[mgr removeItemAtPath:DATA_FOLDER error:nil];
	}
	
	if (inBackground)
		[self performSelectorInBackground:@selector(doDownloadFromURL:) withObject:url];
	else
		[self doDownloadFromURL:url];
	
	return NO;
}

#pragma mark -
#pragma mark Private Methods

- (void)doSetProgress:(NSNumber*)current {
	[delegate setProgress:[current floatValue]];
}

- (void)doSetMessage:(NSString*)message {
	[delegate setMessage:message];
}

-(void)doDidFinish:(NSNumber*)status {
	[delegate didFinish:[status boolValue]];
}


-(void)doDownloadFromURL:(NSURL*)url {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (url == nil)
		url = [self findURL];
	
	NSLog(@"Getting data from %@", url);
	
	MMDownloadDataFile *down = [[MMDownloadDataFile alloc] initWithLoader:self];
	BOOL res = [down getDataFromURL:url];
	[down release];
	
	if (res) {
		// successful download, extract data
		res = [self extractDataFile];
	}
	
	[pool release];
	
	[self performSelectorOnMainThread:@selector(doDidFinish:) withObject:[NSNumber numberWithBool:res] waitUntilDone:NO];
}

#define cStringToNSStringNoCopy(x)	[[NSString alloc] initWithBytesNoCopy:x length:strlen(x) encoding:NSASCIIStringEncoding freeWhenDone:NO]
#define cStringToNSString(x)		[[NSString alloc] initWithBytes:x length:strlen(x) encoding:NSASCIIStringEncoding]

-(BOOL)extractDataFile {
	[self performSelectorOnMainThread:@selector(doSetProgress:) withObject:[NSNumber numberWithFloat:0.0] waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(doSetMessage:) withObject:@"Extracting Data" waitUntilDone:NO];

	HUNZIP huz;
	char pathChars[PATH_MAX + 1];
	[DATA_FILE getCString:pathChars maxLength:sizeof(pathChars) encoding:[NSString defaultCStringEncoding]];
	DWORD result = UnzipOpenFile(&huz, pathChars, NULL);
	if (result != ZR_OK)
		return NO;
	
	result = NO;
	ZIPENTRY	ze;
	DWORD		numitems;
	
	// Find out how many items are in the archive.
	ze.Index = (DWORD)-1;
	if ((UnzipGetItem(huz, &ze))) goto errorExit;
	numitems = ze.Index;
	
	// Unzip each item, using the name stored (in the zip) for that item.
	for (ze.Index = 0; ze.Index < numitems; ze.Index++) {		
		[self performSelectorOnMainThread:@selector(doSetProgress:) withObject:[NSNumber numberWithFloat:(float)ze.Index / (float)numitems] waitUntilDone:NO];

		if (UnzipGetItem(huz, &ze))
			break;
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSString *name = cStringToNSStringNoCopy(ze.Name);
		NSString *fileName = [DOCUMENTS_FOLDER stringByAppendingPathComponent:name];
		UnzipItemToFile(huz, [fileName cStringUsingEncoding:[NSString defaultCStringEncoding]], &ze);
		[name release];
		
		[pool release];
	}
	
	[self performSelectorOnMainThread:@selector(doSetProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
	result = YES;
	
errorExit:
	UnzipClose(huz);
	return result;
}

#define kFlashbackDataURLs	@"http://flashback.manomio.com/index.php/iphone/url_plist/"

-(NSURL*)findURL {
	MMURLList *list  = [[MMURLList alloc] initWithLoader:self];
	_urls = [[list getURLs] retain];
	[list release];
	return [NSURL URLWithString:[_urls objectAtIndex:0]];
}

-(void)dealloc {
	[_urls release];
	[super dealloc];
}

@end

#pragma mark -
#pragma mark MMURLList implementation

@implementation MMURLList

-(id)initWithLoader:(FlashbackDataLoader*)loader {
	self = [super init];
	_loader = loader;
	return self;
}

-(NSArray*)getURLs {
	[_loader performSelectorOnMainThread:@selector(doSetProgress:) withObject:[NSNumber numberWithFloat:0.0] waitUntilDone:NO];
	[_loader performSelectorOnMainThread:@selector(doSetMessage:) withObject:@"Downloading URLs" waitUntilDone:NO];
	
	NSURL *url = [NSURL URLWithString:kFlashbackDataURLs];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	
	NSURLConnection *cn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
	_dataDone = NO;
	while(!_dataDone) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, YES);
	}
	
	[cn release];
	
	[_loader performSelectorOnMainThread:@selector(doSetProgress:) withObject:[NSNumber numberWithFloat:1.0] waitUntilDone:NO];
	[_loader performSelectorOnMainThread:@selector(doSetMessage:) withObject:@"Done" waitUntilDone:NO];

	return _urls;
}

#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;	
	_urls = (NSArray *)[[NSPropertyListSerialization propertyListFromData:data 
																mutabilityOption:NSPropertyListMutableContainersAndLeaves 
																		  format:&format 
																errorDescription:&errorDesc] retain];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	_dataDone = YES;
}

- (void)dealloc {
	[_urls release];
	[super dealloc];
}

@end

#pragma mark -
#pragma mark MMDownloadDataFile implementation

@implementation MMDownloadDataFile

-(id)initWithLoader:(FlashbackDataLoader*)loader {
	self = [super init];
	_loader = loader;
	return self;
}

-(BOOL)getDataFromURL:(NSURL*)url {
	_downloadedBytes = 0;
	_expectedBytes = 0;
	_usingEstimatedBytes = NO;
	[_loader performSelectorOnMainThread:@selector(doSetProgress:) withObject:[NSNumber numberWithFloat:0.0] waitUntilDone:NO];
	[_loader performSelectorOnMainThread:@selector(doSetMessage:) withObject:@"Updating Data" waitUntilDone:NO];

	[_dataFile release];
	_dataFile = [[NSOutputStream outputStreamToFileAtPath:DATA_FILE append:NO] retain];
	[_dataFile open];

	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	NSURLConnection *cn = [NSURLConnection connectionWithRequest:req delegate:self];
	[cn start];

	_dataDone = NO;
	while(!_dataDone) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, YES);
	}

	[_dataFile close];
	[_dataFile release];
	_dataFile = nil;

	if (_downloadedBytes == _expectedBytes || _usingEstimatedBytes) {
		[_loader performSelectorOnMainThread:@selector(doSetMessage:) withObject:@"Update complete" waitUntilDone:NO];
		return YES;
	}
	
	[_loader performSelectorOnMainThread:@selector(doSetMessage:) withObject:@"Update Failed" waitUntilDone:NO];
	return NO;
}

#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSUInteger len = [data length];
	_downloadedBytes += len;
	[_loader performSelectorOnMainThread:@selector(doSetMessage:) withObject:[NSString stringWithFormat:@"%@ bytes of about %d received", [NSNumber numberWithInt:_downloadedBytes], _expectedBytes] waitUntilDone:NO];

	float pct = (float)_downloadedBytes / _expectedBytes;
	[_loader performSelectorOnMainThread:@selector(doSetProgress:) withObject:[NSNumber numberWithFloat:pct] waitUntilDone:NO];
	
	//[_dataFile write:[data bytes] maxLength:len];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Failed to retrieve data");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
	_expectedBytes = [response expectedContentLength];
	if (_expectedBytes == NSURLResponseUnknownLength) {
		_usingEstimatedBytes = YES;
		_expectedBytes = kEstimatedDataFileSizeInBytes;
	}
	NSLog(@"Received response, expecting %d bytes", _expectedBytes);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Completed transfer of %d bytes, expected %d", _downloadedBytes, _expectedBytes);
	_dataDone = YES;
}

- (void)dealloc {
	[super dealloc];
}


@end

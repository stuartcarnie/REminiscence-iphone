/*
 *  ValidationCheck.h
 *  C64
 *
 *  Created by Stuart Carnie on 4/3/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import "CocoaUtility.h"
#import "FlurryAPI.h"
#import <objc/runtime.h>

static inline BOOL checkState(NSString *str) {
#if TARGET_IPHONE_SIMULATOR
	return NO;
#else
	static BOOL isBad = NO;
	static BOOL didCheck = NO;
	
	if([[[NSBundle mainBundle] infoDictionary] objectForKey:str] != nil) {
		isBad = YES;
	}
	
	didCheck = YES;
	
	return isBad;
#endif
}

static inline char rot47(char chr) {
	if (chr == ' ') return ' ';
	int ascii = chr;
	ascii += 47;
	if (ascii > 126) ascii -= 94;
	if (ascii < 33) ascii += 94;
	return (char)ascii;
}

static inline NSString* rot47(NSString *inp) {
	int len = [inp length];
	char buf[len+1];
	
	for (NSUInteger i=0; i<len; i++) {
		buf[i] = rot47([inp characterAtIndex:i]); 
	}
	buf[len] = '\0';
	NSMutableString *output = [NSString stringWithCString:buf length:len];
	return output;
}

static inline BOOL check1(NSTimeInterval delay) {
	if (checkState(rot47(@"$:8?6Cx56?E:EJ"))) {
		[FlurryAPI logEvent:@"CHK:1" 
			 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[UIDevice currentDevice] uniqueIdentifier], @"uuid", nil]];
		NSString *method = rot47(@"E6C>:?2E6");
		const char* term = [method cStringUsingEncoding:[NSString defaultCStringEncoding]];
		[[UIApplication sharedApplication] performSelector:sel_getUid(term) withObject:[UIApplication sharedApplication] afterDelay:delay];
		return NO;
	}
	
	return YES;
}

static inline BOOL check2(NSTimeInterval delay) {
	if (checkState(rot47([@"JE:E?65xC6?8:$" reversed]))) {
		[FlurryAPI logEvent:@"CHK:2" 
			 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[UIDevice currentDevice] uniqueIdentifier], @"uuid", nil]];
		NSString *method = rot47([@"6E2?:>C6E" reversed]);
		const char* term = [method cStringUsingEncoding:[NSString defaultCStringEncoding]];
		[[UIApplication sharedApplication] performSelector:sel_getUid(term) withObject:[UIApplication sharedApplication] afterDelay:delay];
		return NO;
	}
	
	return YES;
}

static inline BOOL check3(NSTimeInterval delay) {
	if (checkState(rot47([[@"J E:E  ?65x C6   ?8:$" stringByReplacingOccurrencesOfString:@" " withString:@""] reversed]))) {
		[FlurryAPI logEvent:[@" C  H   K : 3" stringByReplacingOccurrencesOfString:@" " withString:@""]
			 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[UIDevice currentDevice] uniqueIdentifier], @"uuid", nil]];
		NSString *method = rot47([[@"6  E 2  ? :  > C  6 E" stringByReplacingOccurrencesOfString:@" " withString:@""] reversed]);
		const char* term = [method cStringUsingEncoding:[NSString defaultCStringEncoding]];
		[[UIApplication sharedApplication] performSelector:sel_getUid(term) withObject:[UIApplication sharedApplication] afterDelay:delay];
		return NO;
	}
	
	return YES;
}

static inline BOOL check4(NSTimeInterval delay) {
	if (checkState(rot47([@" $ : 8 ? 6 C x 5 6 ? E : E J" stringByReplacingOccurrencesOfString:@" " withString:@""]))) {
		[FlurryAPI logEvent:[@" C H K : 4" stringByReplacingOccurrencesOfString:@" " withString:@""]
			 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[[UIDevice currentDevice] uniqueIdentifier], @"uuid", nil]];
		NSString *method = rot47([@" E 6 C > : ? 2 E 6" stringByReplacingOccurrencesOfString:@" " withString:@""]);
		const char* term = [method cStringUsingEncoding:[NSString defaultCStringEncoding]];
		[[UIApplication sharedApplication] performSelector:sel_getUid(term) withObject:[UIApplication sharedApplication] afterDelay:delay];
		return NO;
	}
	
	return YES;
}

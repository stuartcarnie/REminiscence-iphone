//
//  UIApplication-Network.m
//

#import "UIApplication-Network.h"


@implementation UIApplication (NetworkExtensions)

#define ReachableViaWiFiNetwork		2
#define ReachableDirectWWAN			(1 << 18)
// fast wi-fi connection
+(BOOL)hasActiveWiFiConnection {
	SCNetworkReachabilityFlags	flags;
	SCNetworkReachabilityRef    reachabilityRef;
	BOOL                        gotFlags;
	
	reachabilityRef = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"www.apple.com" UTF8String]);
	if (reachabilityRef) {
		gotFlags = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
		CFRelease(reachabilityRef);
	} else
		gotFlags = 0;
	
	if (!gotFlags) {
		return NO;
	}
	
	if( flags & ReachableDirectWWAN ) {
		return NO;
	}
	
	if( flags & ReachableViaWiFiNetwork ) {
		return YES;
	}
	
	return NO;
}

// any type of internet connection (edge, 3g, wi-fi)
+(BOOL)hasNetworkConnection {
	return [UIApplication hasNetworkConnectionToHost:@"www.apple.com"];
}

+(BOOL)hasNetworkConnectionToHost:(NSString*)hostName {
    SCNetworkReachabilityFlags  flags;
    SCNetworkReachabilityRef	reachabilityRef;
    BOOL                        gotFlags;
    
    reachabilityRef = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [hostName UTF8String]);
    if (reachabilityRef) {
		gotFlags = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
		CFRelease(reachabilityRef);
	} else
		gotFlags = 0;
    
    if (!gotFlags || (flags == 0) ) {
        return NO;
    }
    
    return YES;
}

@end
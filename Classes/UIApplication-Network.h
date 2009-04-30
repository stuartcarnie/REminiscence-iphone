//
//  UIApplication-Network.h
//
//  SystemConfiguration.framework will need to be added to your project
//
//  To use just call as a class function [UIApplication hasNetworkConnection]
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>


@interface UIApplication (NetworkExtensions)

+(BOOL)hasActiveWiFiConnection;     // fast wi-fi connection
+(BOOL)hasNetworkConnection;		// any type of internet connection (edge, 3g, wi-fi)
+(BOOL)hasNetworkConnectionToHost:(NSString*)hostName;

@end

/*******************************************************************************
 *  @file		MKSKRequestHelper.m
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/10/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import "MKSKRequestHelper.h"

@implementation MKSKRequestHelper

+ (NSString*) buildPostDataString:(NSDictionary*)data {
    NSMutableString* postData = [[NSMutableString alloc] init];
    BOOL first = YES;
    for (NSString* key in [data allKeys]) {
        [postData appendFormat:@"%@%@=%@", (!first ? @"&" : @""), key, [data objectForKey:key]];
        first = NO;
    }
    return [postData autorelease];
}

+ (NSURLRequest*) buildRequestWithString:(NSString*)postString forURL:(NSURL*)url {
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:60];
	[theRequest setHTTPMethod:@"POST"];		
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *length = [NSString stringWithFormat:@"%d", [postString length]];
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];	
	
	[theRequest setHTTPBody:[postString dataUsingEncoding:NSASCIIStringEncoding]];
    return theRequest;
}

@end

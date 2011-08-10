/*******************************************************************************
 *  @file		MKSKRequestHelper.h
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/10/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import <Foundation/Foundation.h>

@interface MKSKRequestHelper : NSObject {

}

+ (NSString*) buildPostDataString:(NSDictionary*)data;
+ (NSURLRequest*) buildRequestWithString:(NSString*)postString forURL:(NSURL*)url;

@end

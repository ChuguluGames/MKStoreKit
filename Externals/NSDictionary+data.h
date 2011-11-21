/*******************************************************************************
 *  @file		NSDictionary+data.h
 *  @brief		blind_test 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		11/21/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import <Foundation/Foundation.h>

@interface NSDictionary (NSDictionary_data)

+ (NSDictionary *) dictionaryWithData:(NSData *)data error:(NSError**)error;
+ (NSDictionary *) dictionaryWithData:(NSData *)data;

@end

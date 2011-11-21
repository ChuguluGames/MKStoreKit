/*******************************************************************************
 *  @file		NSDictionary+data.m
 *  @brief		blind_test 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		11/21/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import "NSDictionary+data.h"

@implementation NSDictionary (NSDictionary_data)

+ (NSDictionary *) dictionaryWithData:(NSData *)data error:(NSError**)error
{
    CFErrorRef errorRef = NULL;
	CFPropertyListRef plist =  CFPropertyListCreateWithData(kCFAllocatorDefault,
                                                            (CFDataRef)data,
															kCFPropertyListImmutable,
															NULL,
                                                            &errorRef);
    if (errorRef != NULL && [(id)errorRef isKindOfClass:[NSError class]])
        *error = (NSError*)errorRef;

	if ([(id)plist isKindOfClass:[NSDictionary class]])
		return [(NSDictionary *)plist autorelease];
	if (plist != NULL)
		CFRelease(plist);
    return nil;
}

+ (NSDictionary *) dictionaryWithData:(NSData *)data {
    return [self dictionaryWithData:data error:nil];
}

@end

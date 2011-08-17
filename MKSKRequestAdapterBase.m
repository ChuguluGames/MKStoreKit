/*******************************************************************************
 *  @file		MKSKRequestAdapterBase.m
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/16/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import "MKSKRequestAdapterBase.h"

@implementation MKSKRequestAdapterBase

- (NSString*) description {
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), self];
}

#pragma mark - Memory
- (void) dealloc {
    [_isResponseOK release];
    [_onSuccess release];
    [_onFailure release];
    [super dealloc];
}

#pragma mark - Protocols
#pragma mark <MKSKRequestAdapterProtocol> methods

- (id) initWithBaseURL:(NSString *)baseURL
                  path:(NSString *)path
                  body:(id)body
              delegate:(id<MKSKRequestAdapterDelegate>)delegate
             onSuccess:(void (^)(id))onSuccess
             onFailure:(void (^)(NSError *))onFailure
      checkingResponse:(BOOL (^)(id))isResponseOK {
    if ((self = [super init])) {
        _onSuccess          = [onSuccess copy];
        _onFailure          = [onFailure copy];
        _isResponseOK       = [isResponseOK copy];
        _delegate           = delegate;
    }
    return self;
}

+ (id) requestWithBaseURL:(NSString*)baseURL
                     path:(NSString*)path
                     body:(id)body
                 delegate:(id<MKSKRequestAdapterDelegate>)delegate
                onSuccess:(void (^)(id))onSuccess
                onFailure:(void (^)(NSError *))onFailure
         checkingResponse:(BOOL (^)(id))isResponseOK {
    return [[[[self class] alloc] initWithBaseURL:baseURL
                                             path:path
                                             body:body
                                         delegate:delegate
                                        onSuccess:onSuccess
                                        onFailure:onFailure
                                 checkingResponse:isResponseOK] autorelease];
}

@end

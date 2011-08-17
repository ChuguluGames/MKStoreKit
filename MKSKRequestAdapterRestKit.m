/*******************************************************************************
 *  @file		MKSKRequestRestKit.m
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/16/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import "MKSKRequestAdapterRestKit.h"

@implementation MKSKRequestAdapterRestKit

#pragma mark - Memory
- (void) dealloc {
    [_client release], _client = nil;
    [super dealloc];
}

#pragma mark - Protocols
#pragma mark <MKSKRequestAdapterProtocol> methods
- (id) initWithBaseURL:(NSString*)baseURL
                  path:(NSString*)path
                  body:(id)body
              delegate:(id<MKSKRequestAdapterDelegate>)delegate
             onSuccess:(void (^)(id))onSuccess
             onFailure:(void (^)(NSError *))onFailure
      checkingResponse:(BOOL (^)(id))isResponseOK{
    if ((self = [super initWithBaseURL:baseURL
                                  path:path
                                  body:body
                              delegate:delegate
                             onSuccess:onSuccess
                             onFailure:onFailure
                      checkingResponse:isResponseOK])) {
        if (baseURL)
            _client = [[RKClient alloc] initWithBaseURL:baseURL];
        else {
            _client = [[RKClient sharedClient] retain];
            _client.cachePolicy |= RKRequestCachePolicyLoadIfOffline;
        }
        [self retain];// RKRequest does not retain the delegate (NSURLConnection does)
        [_client post:path params:body delegate:self];
    }
    return self;
}

#pragma mark <RKRequestDelegate> methods

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    BOOL isSuccess = NO;
    id responseData = response.body;
    NSError* parsingError = nil;
    if ([response isOK] && [response isJSON] && (responseData = [response parsedBody:&parsingError]))
        isSuccess = _isResponseOK ? _isResponseOK(responseData) : YES;
    if (isSuccess) {
        if ([_delegate respondsToSelector:@selector(request:didFinishWithData:)])
            responseData = [_delegate request:self didFinishWithData:responseData];
        if (_onSuccess)
            _onSuccess(responseData);
    }
    else if (_onFailure)
        _onFailure(!responseData && parsingError ? parsingError : response.failureError);
    [self release];
}

- (void) request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
    if (_onFailure)
        _onFailure(error);
    [self release];
}

@end

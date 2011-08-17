/*******************************************************************************
 *  @file		MKSKRequest.m
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/16/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import "JSONKit.h"
#import "MKSKRequestAdapterNSURLConnection.h"

@implementation MKSKRequestAdapterNSURLConnection

+ (NSString*) buildPostDataString:(NSDictionary*)data {
    NSMutableString* postData = [[NSMutableString alloc] init];
    BOOL first = YES;
    for (NSString* key in [data allKeys]) {
        [postData appendFormat:@"%@%@=%@", (!first ? @"&" : @""), key, [data objectForKey:key]];
        first = NO;
    }
    return [postData autorelease];
}

+ (NSURLRequest*) buildRequestWithPostString:(NSString*)postString forURL:(NSURL*)url {
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

#pragma mark - Initialization

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
        _receivedData = nil;
        NSURL* url = [NSURL URLWithString:baseURL];
        if (path)
            url = [url URLByAppendingPathComponent:path];
        NSString* postData = nil;
        if ([body isKindOfClass:[NSString class]])
            postData = body;
        else if ([body isKindOfClass:[NSDictionary class]])
            postData = [[self class] buildPostDataString:body];
        NSURLRequest* request = [[self class] buildRequestWithPostString:postData forURL:url];
        _connection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
        [_connection start];
    }
    return self;
}

#pragma mark - Memory

- (void) dealloc {
    [_connection cancel];
    [_connection release], _connection = nil;
    [_receivedData release], _receivedData = nil;
    [super dealloc];
}

#pragma mark - Delegates
#pragma mark <NSURLConnectionDelegate> methods

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{	
    _receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
	[_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    BOOL isSuccess = NO;
    id responseData = nil;
    NSError* parsingError = nil;
    if ((responseData = [_receivedData objectFromJSONDataWithParseOptions:JKParseOptionStrict error:&parsingError]))
        isSuccess = _isResponseOK ? _isResponseOK(responseData) : YES;
    else
        responseData = _receivedData;
    if (isSuccess) {
        if ([_delegate respondsToSelector:@selector(request:didFinishWithData:)])
            responseData = [_delegate request:self didFinishWithData:responseData];
        if (_onSuccess)
            _onSuccess(responseData);
    }
    else if (_onFailure)
        _onFailure(parsingError);
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    if (_onFailure)
        _onFailure(error);
}

@end

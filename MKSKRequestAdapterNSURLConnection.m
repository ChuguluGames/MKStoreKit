/*******************************************************************************
 *  @file		MKSKRequest.m
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/16/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import "NSDictionary+data.h"
#import "MKSKRequestAdapterNSURLConnection.h"

@interface MKSKRequestAdapterNSURLConnection (private)

- (void) setCustomHTTPHeaders:(NSMutableURLRequest*)request;
- (BOOL) isJSON;
- (BOOL) isXML;

@end

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

+ (NSMutableURLRequest*) buildRequestWithPostString:(NSString*)postString forURL:(NSURL*)url {
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:60];
	[theRequest setHTTPMethod:@"POST"];		
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *length = [NSString stringWithFormat:@"%d", [postString length]];
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];	
	
	[theRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return theRequest;
}

#pragma mark - Initialization

- (id) initWithBaseURL:(NSString*)baseURL
                  path:(NSString*)path
                  body:(id)body
              delegate:(id<MKSKRequestAdapterDelegate>)delegate
             onSuccess:(void (^)(id))onSuccess
             onFailure:(void (^)(NSError *))onFailure
     customHTTPHeaders:(NSDictionary *(^)(id))customHTTPHeaders
      checkingResponse:(BOOL (^)(id))isResponseOK{
    if ((self = [super initWithBaseURL:baseURL
                                  path:path
                                  body:body
                              delegate:delegate
                             onSuccess:onSuccess
                             onFailure:onFailure
                     customHTTPHeaders:customHTTPHeaders
                      checkingResponse:isResponseOK])) {
        _receivedData = nil;
        _responseMIMEType = nil;
        NSURL* url = [NSURL URLWithString:baseURL];
        if (path)
            url = [url URLByAppendingPathComponent:path];
        NSString* postData = nil;
        if ([body isKindOfClass:[NSString class]])
            postData = body;
        else if ([body isKindOfClass:[NSDictionary class]])
            postData = [[self class] buildPostDataString:body];
        NSMutableURLRequest* request = [[self class] buildRequestWithPostString:postData forURL:url];
        if (_customHTTPHeaders)
            [self setCustomHTTPHeaders:request];
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

#pragma mark - Helpers

- (void) setCustomHTTPHeaders:(NSMutableURLRequest*)request {
    NSDictionary* headers = _customHTTPHeaders(request.HTTPBody);
    for (NSString* key in [headers allKeys]) {
        id value = [headers objectForKey:key];
        if ([value isKindOfClass:[NSNumber class]])
             value = [value stringValue];
        if ([value isKindOfClass:[NSString class]])
            [request setValue:value forHTTPHeaderField:key];
        else
            NSLog(@"MKStore warning: custom HTTP header %@ is not a string (%@)", key, value);
    }
}

- (BOOL) isXML {
	return (_responseMIMEType &&
			([_responseMIMEType rangeOfString:@"application/xml"
                                      options:(NSCaseInsensitiveSearch | NSAnchoredSearch)].length > 0 ||
             [_responseMIMEType rangeOfString:@"text/xml"
                                      options:(NSCaseInsensitiveSearch | NSAnchoredSearch)].length > 0));
}

- (BOOL) isJSON {
	return (_responseMIMEType &&
			[_responseMIMEType rangeOfString:@"application/json"
                                     options:(NSCaseInsensitiveSearch | NSAnchoredSearch)].length > 0);
}

#pragma mark - Delegates
#pragma mark <NSURLConnectionDelegate> methods

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    _responseMIMEType = [response.MIMEType copy];
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
    if ([self isXML])
        responseData = [NSDictionary dictionaryWithData:_receivedData error:&parsingError];
    else if ([self isJSON])
        responseData = [NSJSONSerialization JSONObjectWithData:_receivedData options:0 error:&parsingError];
    if (responseData != nil)
        isSuccess = _isResponseOK ? _isResponseOK(responseData) : parsingError == nil;
    else
        responseData = _receivedData;
    if (isSuccess) {
        if (_delegate && [_delegate respondsToSelector:@selector(request:didFinishWithData:)])
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

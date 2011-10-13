/*******************************************************************************
 *  @file		MKSKRequestAdapterProtocol.h
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/16/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import <Foundation/Foundation.h>

@protocol MKSKRequestAdapterDelegate;

@protocol MKSKRequestAdapterProtocol <NSObject>

/**
 @param baseURL         remote host address ex: "http://my-inapp-checking.company.com"
 @param path            remote path      ex: "verifyProduct.php", which becomes "http://my-inapp-checking.company.com/verifyProduct.php"
 @param body            dictionary with the data you want to POST
 @param delegate        should be MKSKProduct and/or MKSKSubscriptionProduct
 @param onSuccess       block executed if the sever sends back a valid response (correct status code + JSON mime type + custom validation, see isResponseOK param) , the parameter is the response (dictionary)
 @param onFailure       block executed if response status is not ok OR if the response cannot be parsed (not or malformed JSON) OR if custom validation fails
 @param isResponseOK    custom validation of the JSON response, here you can check if you have all the required fields OR for a custom status from the server
 */

- (id) initWithBaseURL:(NSString*)baseURL 
                  path:(NSString*)path
                  body:(id)body
              delegate:(id<MKSKRequestAdapterDelegate>)delegate
             onSuccess:(void(^)(id))onSuccess
             onFailure:(void(^)(NSError*))onFailure
      checkingResponse:(BOOL(^)(id))isResponseOK;

+ (id) requestWithBaseURL:(NSString*)baseURL 
                     path:(NSString*)path
                     body:(id)body
                 delegate:(id<MKSKRequestAdapterDelegate>)delegate
                onSuccess:(void(^)(id))onSuccess
                onFailure:(void(^)(NSError*))onFailure
         checkingResponse:(BOOL(^)(id))isResponseOK;

@end

@protocol MKSKRequestAdapterDelegate <NSObject>

@optional
/*
 @brief by default should return responseData
 */
- (id) request:(id<MKSKRequestAdapterProtocol>)request didFinishWithData:(id)responseData;

@end
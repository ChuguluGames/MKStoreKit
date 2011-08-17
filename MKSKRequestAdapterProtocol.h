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
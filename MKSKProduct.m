//
//  MKSKProduct.m
//  MKStoreKitDemo
//  Version 4.0
//
//  Created by Mugunth on 04/07/11.
//  Copyright 2011 Steinlogic. All rights reserved.

//  Licensing (Zlib)
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source distribution.

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com

#include <objc/runtime.h>
#import "MKSKConstants.h"
#import "MKSKProduct.h"
#import "MKSKRequestAdapter.h"

@implementation MKSKProduct
@synthesize receipt;
@synthesize productId;

#pragma mark - Initialization

-(id) initWithProductId:(NSString*) aProductId receiptData:(NSData*) aReceipt
{
    if((self = [super init]))
    {
        self.productId = aProductId;
        self.receipt = aReceipt;
    }
    return self;
}

#pragma mark - Memory

- (void) dealloc {
    self.productId = nil;
    self.receipt = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark In-App purchases promo codes support

+ (NSDictionary*) receiptPostData:(NSData*)receipt {
	NSString *receiptDataString = [[NSString alloc] initWithData:receipt 
                                                        encoding:NSASCIIStringEncoding];
    
	NSDictionary *postData = [NSDictionary dictionaryWithObject:receiptDataString forKey:@"receiptdata"];
	[receiptDataString release];
    return postData;
}

+ (NSDictionary*) productForReviewAccessPostData:(NSString*)productId {
    UIDevice *dev       = [UIDevice currentDevice];
    NSString *uniqueID  = nil;
    if (![dev respondsToSelector:@selector(uniqueIdentifier)] || (uniqueID = [dev.uniqueIdentifier retain]) == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ((uniqueID = [[defaults stringForKey:@"uniqueID"] retain]) == nil) {
            CFUUIDRef cfUUID            = CFUUIDCreate(NULL);
            CFStringRef cfUUIDString    = CFUUIDCreateString(NULL, cfUUID);
            uniqueID                    = [(NSString *)cfUUIDString retain];
            CFRelease(cfUUID);
            CFRelease(cfUUIDString);
            [defaults setObject:uniqueID forKey:@"uniqueID"];
            [defaults synchronize];
        }
    }
    NSDictionary* postData = [NSDictionary dictionaryWithObjectsAndKeys:productId, @"productID", uniqueID, @"uniqueID", nil];
    [uniqueID release];
    return postData;
}

+ (BOOL) checkVerificationResponse:(id)response forProductId:(NSString*)productId {
    if (![response isKindOfClass:[NSDictionary class]])
        return NO;
    id responseProductId = [response objectForKey:kMKSKServerResponseProductIdKey];
    return (responseProductId != nil && [responseProductId isKindOfClass:[NSString class]] && [productId isEqualToString:responseProductId]);
}

// This function is only used if you want to enable in-app purchases for free for reviewers
// Read my blog post http://mk.sg/31

+ (void) verifyProductForReviewAccess:(NSString*) productId
                           onComplete:(void (^)(NSNumber*)) completionBlock
                              onError:(void (^)(NSError*)) errorBlock
{
    if (MKSK_PRODUCT_REVIEW_ALLOWED)
    {
        NSDictionary* postData = nil;
        if ([MKStoreManager sharedManager].customProductForReviewAccessPostData)
            postData = [MKStoreManager sharedManager].customProductForReviewAccessPostData(productId);
        else
            postData = [[self class] productForReviewAccessPostData:productId];
        [MKSK_REQUEST_ADAPTER requestWithBaseURL:MKSK_REMOTE_PRODUCT_SERVER
                                            path:MKSK_PRODUCT_VERIFY_PRODUCT_FOR_REVIEW_PATH
                                            body:postData
                                        delegate:nil
                                       onSuccess:completionBlock
                                       onFailure:errorBlock
                                checkingResponse:^(id response) {
                                     return [[self class] checkVerificationResponse:response forProductId:productId];
                                }];
    }
    else
        completionBlock([NSNumber numberWithBool:NO]);
}

- (void) verifyReceiptOnComplete:(void (^)(id)) completionBlock
                         onError:(void (^)(NSError*)) errorBlock
{
    NSDictionary* postData = nil;
    if ([MKStoreManager sharedManager].customReceiptPostData)
        postData = [MKStoreManager sharedManager].customReceiptPostData(self.receipt);
    else
        postData = [[self class] receiptPostData:self.receipt];

    [MKSK_REQUEST_ADAPTER requestWithBaseURL:MKSK_REMOTE_PRODUCT_SERVER
                                        path:MKSK_PRODUCT_VERIFY_RECEIPT_PATH
                                        body:postData
                                    delegate:nil
                                   onSuccess:completionBlock
                                   onFailure:errorBlock
                            checkingResponse:^(id response) {
                                return [[self class] checkVerificationResponse:response forProductId:self.productId];
                            }];
}

@end

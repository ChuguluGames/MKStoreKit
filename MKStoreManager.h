//
//  StoreManager.h
//  MKStoreKit (Version 4.0)
//
//  Created by Mugunth Kumar on 17-Nov-2010.
//  Version 4.0
//  Copyright 2010 Steinlogic. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://mugunthkumar.com
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/1m on how to use this code

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


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKSKConstants.h"
#import "MKStoreObserver.h"
#import "MKStoreKitConfigs.h"
#import "JSONKit.h"
#import "MKStoreManagerDataSource.h"


@interface MKStoreManager : NSObject<SKProductsRequestDelegate> {
    NSMutableArray*         _purchasableObjects;
    NSMutableDictionary*    _subscriptionProducts;
    BOOL                    _productsAvailable;
    BOOL                    _fetchingProductInfo;
    BOOL                    _restoringProducts;
}

@property (nonatomic, copy) BOOL (^customRemoteServerResponseVerification)(id receivedData, NSString* productId);
@property (nonatomic, copy) NSDictionary* (^customHTTPHeaders)(id requestBody);
@property (nonatomic, copy) NSDictionary* (^customReceiptPostData)(NSData* receipt);
@property (nonatomic, copy) NSDictionary* (^customProductForReviewAccessPostData)(NSString* productId);
@property (nonatomic, retain) NSString* remoteProductServer;

@property (nonatomic, readonly) NSMutableArray      *purchasableObjects;
@property (nonatomic, readonly) NSMutableDictionary *subscriptionProducts;

@property (nonatomic, assign) id<MKStoreManagerDataSource> dataSource;
@property (nonatomic, readonly, getter=areProductsAvailable) BOOL productsAvailable;

// These are the methods you will be using in your app
+ (MKStoreManager*)sharedManager;

- (id) initWithDataSource:(id<MKStoreManagerDataSource>)someDataSource;

// this is a static method, since it doesn't require the store manager to be initialized prior to calling
+ (BOOL) isFeaturePurchased:(NSString*) featureId; 
//returns a dictionary with all prices for identifiers
- (NSMutableDictionary *)pricesDictionary;
- (NSMutableArray*) purchasableObjectsDescription;

// use this method to invoke a purchase
- (void) buyFeature:(NSString*) featureId
         onComplete:(void (^)(NSString*)) completionBlock
           onCancel:(void (^)(NSError*)) cancelBlock
            onError:(void (^)(NSError*)) errorBlock;

// use this method to restore a purchase
- (void) restorePreviousTransactionsOnComplete:(void (^)(SKPaymentQueue*)) completionBlock
                                       onError:(void (^)(SKPaymentQueue*, NSError*)) errorBlock;;

- (BOOL) canConsumeProduct:(NSString*) productName quantity:(int) quantity;
- (BOOL) consumeProduct:(NSString*) productName quantity:(int) quantity;
- (BOOL) isSubscriptionActive:(NSString*) featureId;
//for testing proposes you can use this method to remove all the saved keychain data (saved purchases, etc.)
- (BOOL) removeAllKeychainData;

+(void) setObject:(id) object forKey:(NSString*) key;
+(NSNumber*) numberForKey:(NSString*) key;

-(void) restoreCompleted:(SKPaymentQueue*)queue;
-(void) restoreForQueue:(SKPaymentQueue*)queue failedWithError:(NSError*)error;

- (void) requestProductData;
- (void) startVerifyingSubscriptionReceipts;

- (SKProduct *) productForIdentifier:(NSString*)identifier;

@end

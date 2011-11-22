//
//  MKStoreManager.m
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


#import "MKStoreManager.h"
#import "SFHFKeychainUtils.h"
#import "MKSKSubscriptionProduct.h"
#import "MKSKProduct.h"
#import "MKStoreManagerDataSourcePlist.h"

@interface MKStoreManager () //private methods and properties

@property (nonatomic, copy) void (^onTransactionError)(NSError *error);
@property (nonatomic, copy) void (^onTransactionCancelled)(NSError *error);
@property (nonatomic, copy) void (^onTransactionCompleted)(NSString *productId);

@property (nonatomic, copy) void (^onRestoreFailed)(SKPaymentQueue* queue, NSError* error);
@property (nonatomic, copy) void (^onRestoreCompleted)(SKPaymentQueue* queue);

@property (nonatomic, retain) MKStoreObserver *storeObserver;

- (void) requestProductData;
- (void) startVerifyingSubscriptionReceipts;
-(void) rememberPurchaseOfProduct:(NSString*) productIdentifier;
-(void) addToQueue:(NSString*) productId;
@end

@implementation MKStoreManager

@synthesize purchasableObjects = _purchasableObjects;
@synthesize storeObserver = _storeObserver;
@synthesize subscriptionProducts;

@synthesize dataSource;

@synthesize productsAvailable = _productsAvailable;

@synthesize onTransactionError;
@synthesize onTransactionCancelled;
@synthesize onTransactionCompleted;
@synthesize onRestoreFailed;
@synthesize onRestoreCompleted;

@synthesize customRemoteServerResponseVerification;
@synthesize customHTTPHeaders;
@synthesize customReceiptPostData;
@synthesize customProductForReviewAccessPostData;
@synthesize remoteProductServer;

static MKStoreManager* _sharedStoreManager;

- (id) initWithDataSource:(id<MKStoreManagerDataSource>)someDataSource {
    if ((self = [super init])) {
        self.dataSource             = someDataSource;//[MKStoreManagerDataSourcePlist new];
        _purchasableObjects         = [NSMutableArray new];
        _subscriptionProducts       = [NSMutableDictionary new];
        self.storeObserver          = nil;
        self.customRemoteServerResponseVerification = nil;
        self.customReceiptPostData  = nil;
        self.customHTTPHeaders      = nil;
        self.customProductForReviewAccessPostData = nil;
        self.remoteProductServer    = MKSK_REMOTE_PRODUCT_SERVER;
        self.onTransactionCancelled = nil;
        self.onTransactionCompleted = nil;
        self.onRestoreFailed        = nil;
        self.onRestoreCompleted     = nil;
    }
    return self;
}

- (id) init {
    return [self initWithDataSource:nil];
}

- (void) launch {
    if (_storeObserver != nil)
        return;
    NSAssert(self.dataSource != nil, @"MKStoreKit : data source should not be nil", nil);
    _storeObserver = [[MKStoreObserver alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:_storeObserver];
    [self requestProductData];
    [self startVerifyingSubscriptionReceipts];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:_storeObserver];
    self.remoteProductServer = nil;
    self.dataSource = nil;
    self.customRemoteServerResponseVerification = nil;
    self.customHTTPHeaders = nil;
    self.customProductForReviewAccessPostData = nil;
    self.customReceiptPostData = nil;
    [_subscriptionProducts release], _subscriptionProducts = nil;
    [_purchasableObjects release], _purchasableObjects = nil;
    self.storeObserver = nil;
    self.onTransactionCancelled = nil;
    self.onTransactionCompleted = nil;
    self.onRestoreFailed = nil;
    self.onRestoreCompleted = nil;
    [super dealloc];
}

+ (void) dealloc
{
	[_sharedStoreManager release], _sharedStoreManager = nil;
	[super dealloc];
}

+(void) setObject:(id) object forKey:(NSString*) key
{
    NSString *objectString = nil;
    if([object isKindOfClass:[NSData class]])
    {
        objectString = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] autorelease];
    }
    if([object isKindOfClass:[NSNumber class]])
    {       
        objectString = [(NSNumber*)object stringValue];
    }
    NSError *error = nil;
    [SFHFKeychainUtils storeUsername:key 
                         andPassword:objectString
                      forServiceName:kMKSKServiceName
                      updateExisting:YES 
                               error:&error];
    
    if(error)
        NSLog(@"%@", [error localizedDescription]);
}

+ (id) objectForKey:(NSString*)key
{
    NSError *error = nil;
    NSObject *object = [SFHFKeychainUtils getPasswordForUsername:key 
                                                  andServiceName:kMKSKServiceName 
                                                           error:&error];
    if(error)
        NSLog(@"%@", [error localizedDescription]);
    
    return object;
}

+ (NSNumber*) numberForKey:(NSString*) key
{
    return [NSNumber numberWithInteger:[[MKStoreManager objectForKey:key] integerValue]];
}

+(NSData*) dataForKey:(NSString*) key
{
    NSString *str = [MKStoreManager objectForKey:key];
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark Singleton Methods

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
#if TARGET_IPHONE_SIMULATOR
			NSLog(@"You are running in Simulator MKStoreKit runs only on devices");
#else
            _sharedStoreManager = [[self alloc] init];
#endif
        }
    }
    return _sharedStoreManager;
}

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

#if __has_feature (objc_arc)

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;//denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}
#endif

#pragma mark Internal MKStoreKit functions

- (void) restorePreviousTransactionsOnComplete:(void (^)(SKPaymentQueue*)) completionBlock
                                       onError:(void (^)(SKPaymentQueue*, NSError*)) errorBlock
{
    self.onRestoreCompleted = completionBlock;
    self.onRestoreFailed = errorBlock;
    
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void) restoreCompleted:(SKPaymentQueue*)queue
{
    if (self.onRestoreCompleted)
        self.onRestoreCompleted(queue);
    self.onRestoreCompleted = nil;
}

-(void) restoreForQueue:(SKPaymentQueue*)queue failedWithError:(NSError*)error
{
    if (self.onRestoreFailed)
        self.onRestoreFailed(queue, error);
    self.onRestoreFailed = nil;
}

-(void) requestProductData
{
    if (!self.dataSource)
        return;
    NSMutableSet* productsSet = [[NSMutableSet alloc] init];
    [productsSet addObjectsFromArray:[[self.dataSource consumableProducts] allKeys]];
    [productsSet addObjectsFromArray:[self.dataSource nonConsumableProducts]];
    [productsSet addObjectsFromArray:[[self.dataSource subscriptionProducts] allKeys]];

	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:productsSet];
	request.delegate = self;
	[request start];
    [productsSet autorelease];
}
- (BOOL) removeAllKeychainData {
    if (!self.dataSource)
        return NO;

    BOOL isSuccess = YES;

    //loop through all the saved keychain data and remove it
    for (NSString* productId in [[self.dataSource consumableProducts] allKeys])
        if (![SFHFKeychainUtils deleteItemForUsername:productId andServiceName:kMKSKServiceName error:nil])
            isSuccess = NO;
    for (NSString* productId in [self.dataSource nonConsumableProducts])
        if (![SFHFKeychainUtils deleteItemForUsername:productId andServiceName:kMKSKServiceName error:nil])
            isSuccess = NO;
    for (NSString* productId in [[self.dataSource subscriptionProducts] allKeys])
        if (![SFHFKeychainUtils deleteItemForUsername:productId andServiceName:kMKSKServiceName error:nil])
            isSuccess = NO;
    return isSuccess;
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[self.purchasableObjects addObjectsFromArray:response.products];
	
#ifndef NDEBUG
    for (SKProduct* product in self.purchasableObjects) {
        NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
    }
	for (NSString *invalidProduct in response.invalidProductIdentifiers)
		NSLog(@"Problem in iTunes connect configuration for product: %@", invalidProduct);
#endif

	[request autorelease];

	_productsAvailable = YES;    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMKSKProductFetchedNotification 
                                                        object:[NSNumber numberWithBool:_productsAvailable]];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	[request autorelease];

	_productsAvailable = NO;	
    [[NSNotificationCenter defaultCenter] postNotificationName:kMKSKProductFetchedNotification 
                                                        object:[NSNumber numberWithBool:_productsAvailable]];
}

// call this function to check if the user has already purchased your feature
+ (BOOL) isFeaturePurchased:(NSString*) featureId
{    
    return [[MKStoreManager numberForKey:featureId] boolValue];
}

- (BOOL) isSubscriptionActive:(NSString*) featureId
{    
    MKSKSubscriptionProduct *subscriptionProduct = [_subscriptionProducts objectForKey:featureId];
    return [subscriptionProduct isSubscriptionActive];
}

// Call this function to populate your UI
// this function automatically formats the currency based on the user's locale

- (NSMutableArray*) purchasableObjectsDescription
{
	NSMutableArray *productDescriptions = [[NSMutableArray alloc] initWithCapacity:[self.purchasableObjects count]];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    for (SKProduct* product in self.purchasableObjects)
    {
		[numberFormatter setLocale:product.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:product.price];

		// you might probably need to change this line to suit your UI needs
		NSString *description = [NSString stringWithFormat:@"%@ (%@)",[product localizedTitle], formattedString];
		
#ifndef NDEBUG
		NSLog(@"Product - %@", description);
#endif
		[productDescriptions addObject:description];
	}
    [numberFormatter release];
	return [productDescriptions autorelease];
}

/*Call this function to get a dictionary with all prices of all your product identifers 

For example, 
 
NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];

NSString *upgradePrice = [prices objectForKey:@"com.mycompany.upgrade"]

*/
- (NSMutableDictionary *) pricesDictionary {
    NSMutableDictionary *priceDict = [NSMutableDictionary new];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];    
    for (SKProduct* product in self.purchasableObjects)
    {		
		[numberFormatter setLocale:product.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:product.price];
        [priceDict setObject:formattedString forKey:product.productIdentifier];
    }
    [numberFormatter release];
    return [priceDict autorelease];
}

- (void) buyFeature:(NSString*) featureId
         onComplete:(void (^)(NSString*))completionBlock
           onCancel:(void (^)(NSError*)) cancelBlock
            onError:(void (^)(NSError *))errorBlock
{
    self.onTransactionCompleted = completionBlock;
    self.onTransactionCancelled = cancelBlock;
    self.onTransactionError     = errorBlock;

    dispatch_async(dispatch_get_main_queue(), ^{
    [MKSKProduct verifyProductForReviewAccess:featureId
                                   onComplete:^(NSNumber * isAllowed)
     {
         if([isAllowed boolValue])
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Review request approved", @"")
                                                             message:NSLocalizedString(@"You can use this feature for reviewing the app.", @"")
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                                   otherButtonTitles:nil];
             [alert show];
             [alert release];
             
             if(self.onTransactionCompleted)
                 self.onTransactionCompleted(featureId);
         }
         else
         {
             [self addToQueue:featureId];
         }
         
     }
                                      onError:^(NSError* error)
     {
         NSLog(@"Review request cannot be checked now: %@", [error description]);
         [self addToQueue:featureId];
     }];
    });
}

-(void) addToQueue:(NSString*) productId
{
    if ([SKPaymentQueue canMakePayments])
	{
        SKMutablePayment* payment = [SKMutablePayment paymentWithProductIdentifier:productId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In-App Purchasing disabled", @"")
														message:NSLocalizedString(@"Check your parental control settings and try again later", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (BOOL) canConsumeProduct:(NSString*) productIdentifier
{
	return ([[MKStoreManager numberForKey:productIdentifier] integerValue] > 0);
}

- (BOOL) canConsumeProduct:(NSString*) productIdentifier quantity:(NSInteger) quantity
{
	return ([[MKStoreManager numberForKey:productIdentifier] integerValue] >= quantity);
}

- (BOOL) consumeProduct:(NSString*) productIdentifier quantity:(NSInteger)quantity
{
	NSInteger count = [[MKStoreManager numberForKey:productIdentifier] integerValue];
	if(count < quantity)
		return NO;
    count -= quantity;
    [MKStoreManager setObject:[NSNumber numberWithInteger:count] forKey:productIdentifier];
    return YES;
}

- (void) startVerifyingSubscriptionReceipts
{
    if (!self.dataSource)
        return ;

    for(NSString *productId in [[self.dataSource subscriptionProducts] allKeys])
    {
        MKSKSubscriptionProduct *product = [[[MKSKSubscriptionProduct alloc] initWithProductId:productId subscriptionDays:[[[self.dataSource subscriptionProducts] objectForKey:productId] intValue]] autorelease];
        product.receipt = [MKStoreManager dataForKey:productId]; // cached receipt
        
        if(product.receipt)
        {
            [product verifyReceiptOnComplete:^(NSNumber* isActive)
             {
                 if([isActive boolValue] == NO)
                 {
                     [[NSNotificationCenter defaultCenter] postNotificationName:kMKSKSubscriptionsInvalidNotification 
                                                                         object:product.productId];
                     
                     NSLog(@"Subscription: %@ is inactive", product.productId);
                 }
                 else
                 {
                     NSLog(@"Subscription: %@ is active", product.productId);
                 }
             }
                                     onError:^(NSError* error)
             {
                 NSLog(@"Unable to check for subscription validity right now");
             }]; 
        }
        
        [_subscriptionProducts setObject:product forKey:productId];
    }
}

#pragma mark In-App purchases callbacks
// In most cases you don't have to touch these methods
-(void) provideContent:(NSString*) productIdentifier 
            forReceipt:(NSData*) receiptData
{
    MKSKSubscriptionProduct *subscriptionProduct = [_subscriptionProducts objectForKey:productIdentifier];
    if(subscriptionProduct)
    {
        subscriptionProduct.receipt = receiptData;
        [subscriptionProduct verifyReceiptOnComplete:^(NSNumber* isActive)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:kMKSKSubscriptionsPurchasedNotification 
                                                                 object:productIdentifier];

             [MKStoreManager setObject:receiptData forKey:productIdentifier];
         }
                                             onError:^(NSError* error)
         {
             NSLog(@"%@", [error description]);
         }];
    }        
    else
    {
        if(MKSK_USE_REMOTE_PRODUCT_SERVER && MKSK_REMOTE_PRODUCT_MODEL)
        {
            // ping server and get response before serializing the product
            // this is a blocking call to post receipt data to your server
            // it should normally take a couple of seconds on a good 3G connection
            MKSKProduct *thisProduct = [[[MKSKProduct alloc] initWithProductId:productIdentifier receiptData:receiptData] autorelease];

            [thisProduct verifyReceiptOnComplete:self.onTransactionCompleted
                                         onError:^(NSError* error)
             {
                 if(self.onTransactionError)
                     self.onTransactionError(error);
                 else
                     NSLog(@"The receipt could not be verified");
             }];
        }
        else
        {
            [self rememberPurchaseOfProduct:productIdentifier];
            if (self.onTransactionCompleted)
                self.onTransactionCompleted(productIdentifier);
        }
    }
}

- (void) rememberPurchaseOfProduct:(NSString*) productIdentifier
{
    if (!self.dataSource)
        return;
    NSDictionary *allConsumables = [self.dataSource consumableProducts];
    if ([[allConsumables allKeys] containsObject:productIdentifier])
    {
        id thisConsumable                   = [allConsumables objectForKey:productIdentifier];
        NSInteger quantityPurchased         = [self.dataSource quantityForConsumable:thisConsumable];
        NSString* productPurchased          = [self.dataSource nameForConsumable:thisConsumable];

        NSInteger oldCount                  = [[MKStoreManager numberForKey:productPurchased] integerValue];
        NSInteger newCount                  = oldCount + quantityPurchased;	

        [MKStoreManager setObject:[NSNumber numberWithInt:newCount] forKey:productPurchased];
    }
    else
        [MKStoreManager setObject:[NSNumber numberWithBool:YES] forKey:productIdentifier];	
}

- (void) transactionCancelled: (SKPaymentTransaction *)transaction
{
#ifndef NDEBUG
	NSLog(@"User cancelled transaction: %@", [transaction description]);
    NSLog(@"error: %@", transaction.error);
#endif
    if(self.onTransactionCancelled)
        self.onTransactionCancelled(transaction.error);
}

- (void) transactionFailed:(SKPaymentTransaction *)transaction
{
#ifndef NDEBUG
    NSLog(@"Failed transaction: %@", [transaction description]);
    NSLog(@"error: %@", transaction.error);
#endif
    if (self.onTransactionError)
        self.onTransactionError(transaction.error);
}

@end

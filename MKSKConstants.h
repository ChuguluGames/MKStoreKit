/*******************************************************************************
 *  @file		MKSKConstants.h
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/17/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import <Foundation/Foundation.h>

//static NSString* const kMKSKReceiptValidationURL = @"http://192.168.1.116:3000/api/subscription_purchases/verify_subscription";
static NSString* const kMKSKReceiptValidationURL = @"http://tele7jeux-preprod.chugulu.com/api/subscription_purchases/verify_subscription";
//#ifndef NDEBUG
//@"https://sandbox.itunes.apple.com/verifyReceipt";
//#else
//@"https://buy.itunes.apple.com/verifyReceipt";
//#endif

static NSString* const kMKSKReceiptStringKey                   = @"MK_STOREKIT_RECEIPTS_STRING";

static NSString* const kMKSKProductFetchedNotification         = @"MKStoreKitProductsFetched";
static NSString* const kMKSKSubscriptionsPurchasedNotification = @"MKStoreKitSubscriptionsPurchased";
static NSString* const kMKSKSubscriptionsInvalidNotification   = @"MKStoreKitSubscriptionsInvalid";

static NSString* const kMKSKServerResponseProductIdKey         = @"product_id";

static NSString* const kMKSKServiceName                        = @"MKStoreKit";

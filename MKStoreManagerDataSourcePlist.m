/*******************************************************************************
 *  @file		MKStoreManagerDataSourcePlist.m
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/31/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import "MKStoreManagerDataSourcePlist.h"

NSString* const kMKStoreKitConfigPlist                  = @"MKStoreKitConfigs";
NSString* const kMKSKConfigConsumablesKey               = @"Consumables";
NSString* const kMKSKConfigNonConsumablesKey            = @"Non-Consumables";
NSString* const kMKSKConfigSubscriptionsKey             = @"Subscriptions";

NSString* const kMKSKConfigConsumableNameKey            = @"Name";
NSString* const kMKSKConfigConsumableQuantityKey        = @"Count";

@implementation MKStoreManagerDataSourcePlist

- (id) init
{
    if ((self = [super init])) {
        _storeKitItems = [[NSDictionary alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:kMKStoreKitConfigPlist
                                                                                             withExtension:@"plist"]];
    }
    return self;
}

- (void) dealloc
{
    [_storeKitItems release], _storeKitItems = nil;
    [super dealloc];
}

- (NSDictionary*) consumableProducts
{
    return [_storeKitItems objectForKey:kMKSKConfigConsumablesKey];
}

- (NSArray*) nonConsumableProducts
{
    return [_storeKitItems objectForKey:kMKSKConfigNonConsumablesKey];
}

- (NSDictionary*) subscriptionProducts
{
    return [_storeKitItems objectForKey:kMKSKConfigSubscriptionsKey];
}

- (NSString*) nameForConsumable:(id)consumable
{
    return [(NSDictionary*)consumable objectForKey:kMKSKConfigConsumableNameKey];
}

- (NSInteger) quantityForConsumable:(id)consumable
{
    return [[(NSDictionary*)consumable objectForKey:kMKSKConfigConsumableQuantityKey] integerValue];
}

@end

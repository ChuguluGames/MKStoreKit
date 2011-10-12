/*******************************************************************************
 *  @file		MKStoreManagerDataSource.h
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/31/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import <Foundation/Foundation.h>


@protocol MKStoreManagerDataSource <NSObject>

- (NSDictionary*) consumableProducts;
- (NSArray*) nonConsumableProducts;
- (NSDictionary*) subscriptionProducts;

- (NSString*) nameForConsumable:(id)consumable;
- (NSInteger) quantityForConsumable:(id)consumable;

@end

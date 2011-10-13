/*******************************************************************************
 *  @file		MKStoreManagerDataSourcePlist.h
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/31/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import <Foundation/Foundation.h>
#import "MKStoreManagerDataSource.h"

@interface MKStoreManagerDataSourcePlist : NSObject<MKStoreManagerDataSource> {
    NSDictionary*   _storeKitItems;
}

@end

/*******************************************************************************
 *  @file		MKSKRequestAdapterBase.h
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/16/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import <Foundation/Foundation.h>
#import "MKSKRequestAdapterProtocol.h"

@interface MKSKRequestAdapterBase : NSObject<MKSKRequestAdapterProtocol> {
    id<MKSKRequestAdapterDelegate>  _delegate;
    void                            (^_onSuccess)(id);
    void                            (^_onFailure)(NSError*);
    BOOL                            (^_isResponseOK)(id);
}

@end

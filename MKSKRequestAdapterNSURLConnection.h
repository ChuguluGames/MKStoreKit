/*******************************************************************************
 *  @file		MKSKRequest.h
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/16/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import <Foundation/Foundation.h>
#import "MKSKRequestAdapterBase.h"

@interface MKSKRequestAdapterNSURLConnection : MKSKRequestAdapterBase<MKSKRequestAdapterProtocol> {
    NSMutableData*      _receivedData;
    NSURLConnection*    _connection;
    NSString*           _responseMIMEType;
}

@end

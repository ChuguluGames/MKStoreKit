/*******************************************************************************
 *  @file		MKSKRequestAdapter.h
 *  @brief		PlayBoy 
 *  @author		Sergio Kunats
 *  @version	1.0
 *  @date		8/17/11
 *
 *  Copyright 	Chugulu 2009-2011. All rights reserved.
 *******************************************************************************/

#import "MKStoreKitConfigs.h"

#ifdef MKSK_REQUEST_ADAPTER_RESTKIT
#import "MKSKRequestAdapterRestKit.h"
#else
#import "MKSKRequestAdapterNSURLConnection.h"
#endif
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

#undef MKSK_REMOTE_PRODUCT_SERVER
#define MKSK_REMOTE_PRODUCT_SERVER  nil
#define MKSK_REQUEST_ADAPTER        MKSKRequestAdapterRestKit
#import "MKSKRequestAdapterRestKit.h"

#elif defined MKSK_REQUEST_ADAPTER_CUSTOM // put your custom adapter name here

#define MKSK_REQUEST_ADAPTER        MKSKRequestAdapterCustom    // and here
#import "MKSKRequestAdapterCustom.h"      // and here

#else // default adapter

#define MKSK_REQUEST_ADAPTER        MKSKRequestAdapterNSURLConnection
#import "MKSKRequestAdapterNSURLConnection.h"

#endif

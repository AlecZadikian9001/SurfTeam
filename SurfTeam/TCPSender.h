//
//  TCPSender.h
//  SurfTeam
//
//  Created by Alec Zadikian on 10/5/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "Constants.h"

@interface TCPSender : NSObject

+(void)sendData: (NSData*) data onSocket: (GCDAsyncSocket*) socket withTimeout: (NSTimeInterval) timeout tag: (long) tag; //sends data with tag appended and all
+(int)getTagFromData: (NSData*) data; //get the network tag AND modify data to not contain the tag

@end

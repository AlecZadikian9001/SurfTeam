//
//  Server.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ClientHandler.h"
#import "GCDAsyncSocket.h"
#import "ServerAppDelegate.h"

@class ClientHandler;
@interface Server : NSObject

@property(strong, nonatomic) NSMutableArray* clientHandlers;
@property(strong, nonatomic) NSString* password;
@property(strong, nonatomic) ServerAppDelegate* delegate;

//initializes and starts a new server
- (id) initWithDelegate: (ServerAppDelegate*) delegate port: (int) port password: (NSString*) pw;

//dumb data distributer... just resends everything to all users except the sender
- (void)distributeData: (NSData*) data fromClient: (ClientHandler*) client
           withTimeout: (NSTimeInterval)timeout
                   tag: (long) tag;

//stop the server
- (void)close;

@end

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
#import "BrowserWindowEssence.h"

@class ClientHandler;
@interface Server : NSObject

@property(strong, nonatomic) NSMutableArray* clientHandlers;
@property(strong, nonatomic) NSString* password;
@property(strong, nonatomic) ServerAppDelegate* delegate;

//initializes and starts a new server
- (id) initWithDelegate: (ServerAppDelegate*) delegate port: (int) port password: (NSString*) pw;

//simple, dumb, low-level data distributer, passing everything through without any calculation
- (void)distributeData: (NSData*) data fromClient: (ClientHandler*) client
           withTimeout: (NSTimeInterval)timeout
                   tag: (long) tag;

//similar to above but wraps the tag into the data
- (void)distributeDataWithWrappedTag: (NSData*) data fromClient: (ClientHandler*) client
           withTimeout: (NSTimeInterval)timeout
                   tag: (long) tag;

//sends the windows from other clients to the specified client
- (void) sendWindowsToClient: (ClientHandler*) sourceClient;

//kills the specified client handler properly
- (void) killClientHandler: (ClientHandler*) handler;

//stop the server
- (void)close;

@end

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

//simple, dumb, low-level data distributer, passing everything through without any calculation
- (void)distributeData: (NSData*) data fromClient: (ClientHandler*) client
           withTimeout: (NSTimeInterval)timeout
                   tag: (long) tag;

//ask every client to send its windows over, telling the client handlers to be prepared for the information, sending the data to the source userID
- (void) askForWindows: (ClientHandler*) sourceClient;


//stop the server
- (void)close;

@end

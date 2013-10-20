//
//  ClientHandler.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "Server.h"
#import "Constants.h"
#import "TCPSender.h"
#import "BrowserWindowEssence.h"

@class Server;
@interface ClientHandler : NSObject

@property(strong, nonatomic) GCDAsyncSocket* socket;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSMutableArray* windows; //array of BrowserWindowEssence objects
@property(strong, nonatomic) NSMutableArray* cookies;
@property(strong, nonatomic) NSNumber* userID;
@property(strong, nonatomic) NSNumber* isLoggedIn;
@property(weak, nonatomic) Server* server;

@property(strong, nonatomic) BrowserWindowEssence* windowToBeUpdated;
@property(strong, nonatomic) BrowserWindowEssence* receivingWindow;
@property(strong, nonatomic) NSData* receivingCookies;

- (id) initWithServer: (Server*) server socket: (GCDAsyncSocket*) sock;

- (void)disconnectSocketForcibly;
- (void)disconnectSocketGracefully;

@end

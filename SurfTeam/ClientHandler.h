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

- (id) initWithServer: (Server*) server socket: (GCDAsyncSocket*) sock;

- (void)disconnectSocketForcibly;
- (void)disconnectSocketGracefully;

@end

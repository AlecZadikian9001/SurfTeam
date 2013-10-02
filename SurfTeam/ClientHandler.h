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

@class Server;
@interface ClientHandler : NSThread //multithreaded just for user login

@property(strong, nonatomic) GCDAsyncSocket* socket;

- (id) initWithServer: (Server*) server socket: (GCDAsyncSocket*) sock;
- (void)disconnectSocketForcibly: (GCDAsyncSocket*) socket;
- (void)disconnectSocketGracefully: (GCDAsyncSocket*) socket;

@end

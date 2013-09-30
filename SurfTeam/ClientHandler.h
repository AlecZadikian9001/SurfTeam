//
//  ClientHandler.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "Server.h"

@interface ClientHandler : NSObject //delegate for each connected client

- (id) initWithServer: (Server*) server;
- (void)disconnectForcibly: (AsyncSocket*) socket;
- (void)disconnectGracefully: (AsyncSocket*) socket;

@end

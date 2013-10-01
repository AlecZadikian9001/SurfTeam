//
//  Server.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ClientHandler.h"
#import "AsyncSocket.h"

@class ClientHandler;
@interface Server : NSObject

@property(strong, nonatomic) NSMutableArray* clientHandlers;
@property(strong, nonatomic) NSString* password;

- (id) initWithPort: (int) port password: (NSString*) pw;
- (void)distributeData: (NSData*) data fromClient: (ClientHandler*) client
           withTimeout: (NSTimeInterval)timeout
                   tag: (long) tag;
-(void)addLabel: (NSTextField*) label;

@end

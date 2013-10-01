//
//  AppDelegate.m
//  SurfTeam Server
//
//  Created by Alec Zadikian on 9/30/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "AppDelegate.h"
#import "Server.h"

@implementation AppDelegate
@synthesize connectionsLabel;

Server* server;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    server = [[Server alloc] initWithPort: defaultPort password: @"alpine"];
    [server addLabel: connectionsLabel];
}

@end

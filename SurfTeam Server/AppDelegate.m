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
@synthesize numberConnectionsTitle;

Server* server;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    server = [[Server alloc] initWithPort: 9000 password: @"alpine"];
}

+ (void) setNumberConnections: (int) num{
    numberConnectionsTitle.stringValue = [NSString stringWithFormat: @"%d", num];
}

@end

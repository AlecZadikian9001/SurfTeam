//
//  AppDelegate.m
//  SurfTeam Server
//
//  Created by Alec Zadikian on 9/30/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "ServerAppDelegate.h"
#import "Server.h"

@implementation ServerAppDelegate
@synthesize connectionsLabel;
int numberConnected = 0;

Server* server;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    server = [[Server alloc] initWithDelegate: self port: defaultPort password: @"alpine"];
    connectionsLabel.stringValue = @"0";
}

- (void) onClientConnect{
    numberConnected++;
    connectionsLabel.stringValue = [NSString stringWithFormat:@"%d", numberConnected];
}

- (void) onClientDisconnect{
    numberConnected--;
    connectionsLabel.stringValue = [NSString stringWithFormat:@"%d", numberConnected];
}

- (void) onServerBeginOpen{}
- (void) onServerBeginClose{}
- (void) onServerFinishOpen{}
- (void) onServerFinishClose{}

@end

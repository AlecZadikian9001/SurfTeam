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
@synthesize connectionsLabel, progressIndicator, serverToggleButton;
int numberConnected = 0;

Server* server;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    connectionsLabel.stringValue = @"Server Closed";
}

- (IBAction)serverToggle:(NSButton *)sender {
    NSLog(@"Server button pressed; state is %d", (sender.state==NSOnState));
    if (sender.state == NSOffState){
        NSLog(@"User wants to start server.");
        server = [[Server alloc] initWithDelegate: self port: defaultPort password: @"alpine"];
        numberConnected = 0;
        connectionsLabel.stringValue = @"0";
        serverToggleButton.title = @"RUNNING";
    }
    else{
        NSLog(@"User wants to stop server.");
        [server close];
        numberConnected = 0;
        connectionsLabel.stringValue = @"Server Closed";
        serverToggleButton.title = @"STOPPED";
    }
}

- (void) onClientConnect{
    numberConnected++;
    connectionsLabel.stringValue = [NSString stringWithFormat:@"%d", numberConnected];
}

- (void) onClientDisconnect{
    numberConnected--;
    connectionsLabel.stringValue = [NSString stringWithFormat:@"%d", numberConnected];
}

- (void) onServerBeginOpen{
}
- (void) onServerBeginClose{
}
- (void) onServerFinishOpen{
}
- (void) onServerFinishClose{
}

@end

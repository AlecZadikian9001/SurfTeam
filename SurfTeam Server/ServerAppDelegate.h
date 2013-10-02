//
//  AppDelegate.h
//  SurfTeam Server
//
//  Created by Alec Zadikian on 9/30/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ServerAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *connectionsLabel;

- (void) onClientConnect; //called after client has connected
- (void) onClientDisconnect; //called after client has disconnected
- (void) onServerBeginOpen; //called before the server opens
- (void) onServerBeginClose; //called before the server closes
- (void) onServerFinishOpen; //called after the server opens
- (void) onServerFinishClose; //called after the server closes

@end

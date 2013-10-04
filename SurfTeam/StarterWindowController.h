//
//  StarterViewController.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
#import "Constants.h"
#import "BrowserWindowController.h"

@class BrowserWindowController;
@interface StarterWindowController : NSWindowController

//non-web UI for login and collab

@property (weak) IBOutlet NSTextField *serverIPField;
@property (weak) IBOutlet NSTextField *serverPortField;
@property (weak) IBOutlet NSTextField *serverPasswordField;
@property (weak) IBOutlet NSTextField *nameField;

@property (strong, nonatomic) NSMutableDictionary* browserWindows;
@property (strong, nonatomic) GCDAsyncSocket* socket;
@property (strong, nonatomic) NSString* name;

- (IBAction)connectButton:(id)sender;

-(id) initWithWindowNibName:(NSString *)windowNibName;
-(void)insertBrowserWindow: (BrowserWindowController*) window;
-(void) sendWindow: (BrowserWindowController*) window;

@end

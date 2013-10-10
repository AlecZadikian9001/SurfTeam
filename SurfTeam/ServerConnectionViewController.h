//
//  ServerConnectionViewController.h
//  SurfTeam
//
//  Created by Alec Zadikian on 10/6/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
#import "Constants.h"
#import "BrowserWindowController.h"
#import "TCPSender.h"
#import "BrowserWindowEssence.h"

@class BrowserWindowController;
@interface ServerConnectionViewController : NSWindowController

@property (weak) IBOutlet NSTextField *serverIPField;
@property (weak) IBOutlet NSTextField *serverPortField;
@property (weak) IBOutlet NSTextField *serverPasswordField;
@property (weak) IBOutlet NSTextField *nameField;

@property (strong, nonatomic) NSMutableArray* browserWindows;
@property (strong, nonatomic) GCDAsyncSocket* socket;
@property (strong, nonatomic) NSString* name;

- (IBAction)connectButton:(id)sender;

+(ServerConnectionViewController*) defaultStarter;
-(id) initWithWindowNibName:(NSString *)windowNibName;
-(void)insertBrowserWindow: (BrowserWindowController*) window;
-(void) sendWindow: (BrowserWindowController*) window;
-(void) sendWindowUpdate:(BrowserWindowController*) window;

@end

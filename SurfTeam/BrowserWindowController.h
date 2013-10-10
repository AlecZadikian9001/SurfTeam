//
//  WindowController.h
//  SurfTeam
//
//  Created by Alec Zadikian on 10/6/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
#import "Constants.h"
#import "ServerConnectionViewController.h"
#import "IGIsolatedCookieWebView.h"
#import "BrowserWindowEssence.h"

@class ServerConnectionViewController, BrowserWindowEssence;
@interface BrowserWindowController : NSWindowController

@property (strong, nonatomic) ServerConnectionViewController* starter;
@property (strong, nonatomic) NSData* primeTag;
@property (strong, nonatomic) NSString* user;
@property (strong, nonatomic) NSString* url;
@property (weak) IBOutlet IGIsolatedCookieWebView *webView;


- (IBAction)loadPage:(NSTextField *)sender;

- (id)initWithWindow:(NSWindow *)window;
-(id) initWithWindowNibName:(NSString *)windowNibName;
//- (id) initWithEssence: (BrowserWindowEssence*) essence;
- (void) updateFromEssence: (BrowserWindowEssence*) essence;
- (void) addStarter: (ServerConnectionViewController*) st overNetwork: (BOOL) net;

//- (NSWindow *)window; //to kill the method
- (void)saveCookies;
- (void)loadCookies;
- (int) getID;
- (void) setID: (int) i;
- (BOOL) getIsControllable;

- (NSArray*)getCookiesForCurrentURL;

@end

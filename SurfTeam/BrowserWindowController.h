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
#import "WebViewEventKillingWindow.h"

@class ServerConnectionViewController, BrowserWindowEssence, WebViewEventKillingWindow;
@interface BrowserWindowController : NSWindowController

@property (strong, nonatomic) ServerConnectionViewController* starter;
@property (strong, nonatomic) NSData* primeTag;
@property (strong, nonatomic) NSString* user;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSNumber* windowID; //represents integer
@property (strong, nonatomic) NSNumber* isControllable; //represents boolean
@property (strong, nonatomic) NSNumber* isOverridingLoad; //represents boolean
@property (weak) IBOutlet IGIsolatedCookieWebView *webView;
@property (strong, nonatomic) NSString* currentHTML;
@property (weak) IBOutlet NSTextField *urlField;
@property (strong, nonatomic) NSString* scrollPositionJS;
@property (weak) IBOutlet NSButton *userIndicator;
@property (weak) IBOutlet NSButton *controllableIndicator;
@property (unsafe_unretained) IBOutlet WebViewEventKillingWindow *killerWindow;

- (IBAction)loadPage:(NSTextField *)sender;
- (IBAction)forward:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)reloadPage:(id)sender;

- (id) initWithWindow:(NSWindow *)window; //override for debug

- (id) initWithDefaultWindowAndControllable: (BOOL) cont;
- (void) updateFromEssence: (BrowserWindowEssence*) essence;
- (void) onConnect;
- (void) onScroll;

- (void) setCookiesFromData: (NSData*) data;

@end

//
//  BrowserWindowController.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
#import "Constants.h"
#import "StarterWindowController.h"
#import "IGIsolatedCookieWebView.h"

@class StarterWindowController;
@interface BrowserWindowController : NSWindowController
//just the web browser window, can be online or offline!

@property (strong, nonatomic) StarterWindowController* starter;
@property (strong, nonatomic) NSString* owner;
@property (strong, nonatomic) NSString* url;
@property (weak) IBOutlet IGIsolatedCookieWebView *webView;
@property (unsafe_unretained) IBOutlet NSWindow *window;

- (IBAction)loadPage:(NSTextFieldCell *)sender;

- (id) initWithStarter: (StarterWindowController*) st windowID: (int) i;

- (void)saveCookies;
- (void)loadCookies;
- (int) getID;
- (BOOL) getIsControllable;

- (NSArray*)getCookiesForCurrentURL;


@end

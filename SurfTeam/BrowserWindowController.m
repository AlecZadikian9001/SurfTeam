//
//  WindowController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 10/6/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "BrowserWindowController.h"

@interface BrowserWindowController ()

@end

@implementation BrowserWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        url = @"post-initialized URL, unused";
        NSLog(@"BrowserWindowController %p being initialized.", self);
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@synthesize starter, owner, webView, url;

BOOL isControllable, primeTag; //that is, if I own it
int windowID;

- (void) addStarter: (ServerConnectionViewController*) st overNetwork: (BOOL) net{
    NSLog(@"Starter being added to browser window.");
        starter = st;
        primeTag = 0; //to indicate that it is local
        url = @"no url";
        isControllable = !net;
        [starter insertBrowserWindow: self];
}

- (int)     getID{ return windowID; }
- (void)    setID: (int) i{ windowID = i; }
- (BOOL)    getIsControllable{ return isControllable; }

- (IBAction)loadPage:(NSTextField *)sender {
    url = sender.stringValue;
    NSLog(@"Page being loaded, URL: %@", url);
    [webView setMainFrameURL: url];
    [webView reload: self];
    [starter sendWindowUpdate: self];
}

- (NSArray*)getCookiesForCurrentURL
{
    if (!url) return [[NSArray alloc] init];
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:url]];
}

@end

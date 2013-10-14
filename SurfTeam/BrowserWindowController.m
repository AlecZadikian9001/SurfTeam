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

@synthesize starter, user, webView, url, primeTag;

BOOL isControllable; //that is, if I own it
int windowID;

- (id) initWithDefaultWindowAndControllable: (BOOL) cont{
    self = [super initWithWindowNibName:@"BrowserWindowController"];
    if (self){
        isControllable = cont;
        [self showWindow:nil];
        [self.window makeKeyAndOrderFront:nil];
    }
    return self;
    
}

- (void) updateFromEssence: (BrowserWindowEssence*) essence{
    if (essence.owner)      user       = [BrowserWindowEssence stringFromData: essence.owner];
    if (essence.url){       url        = [BrowserWindowEssence stringFromData: essence.url];   [webView setMainFrameURL:  url]; }
    if (essence.primeTag)   primeTag   = essence.primeTag;
    
    if (essence.html){
        NSLog(@"Inserting HTML code into browser window: %@", [[NSString alloc] initWithData:essence.html encoding: NSUTF8StringEncoding]);
        //[webView.mainFrame loadData:essence.html MIMEType: @"text/html" textEncodingName: @"utf-8" baseURL:nil];
        [webView.mainFrame loadHTMLString:
         [[NSString alloc] initWithData:essence.html encoding:NSUTF8StringEncoding]
                        baseURL:nil];
    }
    
    if (essence.scrollPosition){
        //TODO
    }
}

- (int)     getID{ return windowID; }
- (void)    setID: (int) i{ windowID = i; }
- (BOOL)    getIsControllable{ return isControllable; }
- (void)    setIsControllable: (BOOL) cont{ isControllable = cont; }

- (IBAction)loadPage:(NSTextField *)sender {
    url = sender.stringValue;
    NSLog(@"Page on window %d (mem %p) being loaded, URL: %@", windowID, self, url);
    [webView setMainFrameURL: url];
    //[webView reload: self];
    if (starter.socket) [starter sendWindowUpdate: self]; //only if logged in
}

- (NSArray*)getCookiesForCurrentURL
{
    if (!url) return [[NSArray alloc] init];
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:url]];
}

@end

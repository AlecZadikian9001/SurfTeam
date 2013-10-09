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

@synthesize starter, owner, webView, url, primeTag;

BOOL isControllable; //that is, if I own it
int windowID;


- (id) initWithEssence: (BrowserWindowEssence*) essence{
    self = [self init];
    if (self){
        if (essence.owner)      owner       = [BrowserWindowEssence stringFromData: essence.owner];
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking parts!");
        if (essence.url){       url         = [BrowserWindowEssence stringFromData: essence.url];   [webView setMainFrameURL: url]; }
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking parts!");
        if (essence.primeTag)   primeTag    = essence.primeTag;
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking parts!");
        
        if (essence.html){
            NSLog(@"Inserting HTML code into browser window.");
            NSString* html = [BrowserWindowEssence stringFromData: essence.html];
            [webView.mainFrame loadHTMLString: html baseURL: [NSURL URLWithString: url]];
        }
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking parts!");
        
        if (essence.scrollPosition){
            //TODO
        }
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking parts!");
    }
    return self;
}

- (void) updateFromEssence: (BrowserWindowEssence*) essence{
    if (essence.owner)      owner       = [BrowserWindowEssence stringFromData: essence.owner];
    if (essence.url){       url         = [BrowserWindowEssence stringFromData: essence.url];   [webView setMainFrameURL: [NSURL URLWithString: url]]; }
    if (essence.primeTag)   primeTag    = essence.primeTag;
    
    if (essence.html){
        NSLog(@"Inserting HTML code into browser window.");
        NSString* html = [BrowserWindowEssence stringFromData: essence.html];
        [webView.mainFrame loadHTMLString: html baseURL: url];
    }
    
    if (essence.scrollPosition){
        //TODO
    }
}

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

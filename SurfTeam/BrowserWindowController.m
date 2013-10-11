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

/*
 - (NSWindow *)window{
 //THIS METHOD MUST DIE
 NSLog(@"window called in BrowserWindowController instance %p", self);
 return [super window];
 }
 */
- (void)windowDidLoad
{
    [super windowDidLoad];
    // [self addStarter: [ServerConnectionViewController defaultStarter] overNetwork:NO];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@synthesize starter, user, webView, url, primeTag;

BOOL isControllable; //that is, if I own it
int windowID;

/*
- (id) initWithEssence: (BrowserWindowEssence*) essence{
    self = [self init];
    if (self){
        if (essence.owner)      user       = [BrowserWindowEssence stringFromData: essence.owner];
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking owner!");
        if (essence.url){       url         = [BrowserWindowEssence stringFromData: essence.url];   [webView setMainFrameURL: url]; }
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking url!");
        if (essence.primeTag)   primeTag    = essence.primeTag;
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking primetag!");
        
        if (essence.html){
            NSLog(@"Inserting HTML code into browser window.");
            NSString* html = [BrowserWindowEssence stringFromData: essence.html];
            [webView.mainFrame loadHTMLString: html baseURL: [NSURL URLWithString: url]];
            loadData:webdata MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:nil];
        }
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking html!");
        
        if (essence.scrollPosition){
            //TODO
        }
        else NSLog(@"Error in BrowserWindowController when initializing with essence: essence is lacking scroll position!");
    }
    return self;
}
*/
- (void) updateFromEssence: (BrowserWindowEssence*) essence{
    if (essence.owner)      user       = [BrowserWindowEssence stringFromData: essence.owner];
    if (essence.url){       url         = [BrowserWindowEssence stringFromData: essence.url];   [webView setMainFrameURL: [NSURL URLWithString: url]]; }
    if (essence.primeTag)   primeTag    = essence.primeTag;
    
    if (essence.html){
        //NSString* html = [BrowserWindowEssence stringFromData: essence.html];
        NSLog(@"Inserting HTML code into browser window with length %d.", essence.html.length);
        [webView.mainFrame loadData:essence.html MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:nil];
    //    [webView.mainFrame loadHTMLString: html baseURL: url];
    }
    
    if (essence.scrollPosition){
        //TODO
    }
}

- (void) addStarter: (ServerConnectionViewController*) st overNetwork: (BOOL) net{
    NSLog(@"Starter being added to browser window.");
    starter = st;
    isControllable = !net;
    [starter insertBrowserWindow: self];
}

- (int)     getID{ return windowID; }
- (void)    setID: (int) i{ windowID = i; }
- (BOOL)    getIsControllable{ return isControllable; }

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

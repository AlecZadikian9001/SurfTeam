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

@synthesize starter, user, webView, url, primeTag, urlField, windowID, isControllable, currentHTML, isOverridingLoad;
WebPreferences* defaultPreferences;

- (id) initWithDefaultWindowAndControllable: (BOOL) cont{
    self = [super initWithWindowNibName:@"BrowserWindowController"];
    if (self){
        isControllable = [NSNumber numberWithBool:cont];
        isOverridingLoad = [NSNumber numberWithBool:YES];
        windowID = [NSNumber numberWithInt: -1]; //should actually never be -1 when being used
        [self showWindow:nil];
        [self.window makeKeyAndOrderFront:nil];
    /*
        defaultPreferences = [[WebPreferences alloc] initWithIdentifier:@"defaultPreferences"]; //maybe this bit needs to be cleaned up
        [defaultPreferences setPlugInsEnabled: YES];
        [webView setPreferences: defaultPreferences];
        if ([webView.preferences arePlugInsEnabled]) NSLog(@"Plugins are enabled.");
      */
        //[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onBeginLoad:) name: WebViewProgressStartedNotification object:webView]; //which to use?
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onFinishLoad:) name: WebViewProgressFinishedNotification object:webView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onWindowClose:) name: NSWindowWillCloseNotification object:[self window]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onFinishResize:) name: NSWindowDidResizeNotification object:[self window]];
    }
    return self;
}

-(void) onFinishResize: (NSNotification *) notification{
    NSLog(@"onFinishResize called for window %@.", windowID);
    if (starter.socket && [isControllable boolValue]) [starter sendWindowDimensionsUpdate: self];
}

-(void) onWindowClose: (NSNotification *) notification{
    NSLog(@"onWindowClose called for window %@.", windowID);
}

//************************************************************** Need to fix content loading bugs with link loading and other things! *********************************
-(void) onFinishLoad: (NSNotification *) notification{
    url = webView.mainFrameURL;
    NSLog(@"onFinishLoad called, URL is %@", url);
    if (urlField && url) [urlField setStringValue: url];
    else NSLog(@"ERROR updating url in text field box!");
    if (starter.socket && [isControllable boolValue]) [starter sendWindowUpdate: self]; //only if logged in and controllable window
}

-(void) onBeginLoad: (NSNotification *) notification{ //make this work! AND MAKE THIS ONSTARTLOAD!
    if (isOverridingLoad.boolValue){
    url = webView.mainFrameURL;
    NSLog(@"onBeginLoad called, URL is %@", url);
    if (urlField && url) [urlField setStringValue: url];
    else NSLog(@"ERROR updating url in text field box!");
    isOverridingLoad = [NSNumber numberWithBool:NO];
    [self loadCurrentContent];
    if (starter.socket && [isControllable boolValue]) [starter sendWindowUpdate: self]; //only if logged in and controllable window
    }
    else isOverridingLoad = [NSNumber numberWithBool:YES];
}

- (void) loadCurrentContent{
    NSURL *urlToLoad = [NSURL URLWithString:url];
    NSError* error;
    currentHTML = [NSString stringWithContentsOfURL:urlToLoad encoding: NSUTF8StringEncoding error:&error];
    [webView.mainFrame loadHTMLString: currentHTML baseURL:[NSURL URLWithString:url]];
}

- (void) updateFromEssence: (BrowserWindowEssence*) essence{
    if (essence.owner)      user       = [BrowserWindowEssence stringFromData: essence.owner];
    if (essence.url){       url        = [BrowserWindowEssence stringFromData: essence.url];   [webView setMainFrameURL:  url]; }
    if (essence.primeTag)   primeTag   = essence.primeTag;
    
    if (essence.html){
        NSLog(@"Inserting HTML code into browser window: %@", [[NSString alloc] initWithData:essence.html encoding: NSUTF8StringEncoding]);
        currentHTML = [[NSString alloc] initWithData: essence.html encoding: NSUTF8StringEncoding];
        isOverridingLoad = [NSNumber numberWithBool:NO];
        [self loadCurrentContent];
       // [webView.mainFrame loadData:essence.html MIMEType: @"text/html" textEncodingName: @"utf-8" baseURL:nil];
     /*   [webView.mainFrame loadHTMLString:
         [[NSString alloc] initWithData:essence.html encoding:NSUTF8StringEncoding]
                        baseURL:nil]; */
    }
    NSLog(@"Done updating window from essence.");
    
    if (essence.scrollPosition){
        //TODO
    }
}

- (IBAction)loadPage:(NSTextField *)sender { //should use base URL TODO
    url = sender.stringValue;
    NSLog(@"Page on window %@ (mem %p) being loaded, URL: %@", windowID, self, url);
    isOverridingLoad = [NSNumber numberWithBool:NO];
    [self loadCurrentContent];
   // [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:url]]];
    //[webView reload: self];
    //if (starter.socket && [isControllable boolValue]) [starter sendWindowUpdate: self]; //only if logged in and controllable window
}
// **********************************************************************************************************************************************************************
- (NSArray*)getCookiesForCurrentURL
{
    if (!url) return [[NSArray alloc] init];
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:url]];
}

@end

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

@class WebViewEventKillingWindow;
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
    if ([isControllable boolValue]) [controllableIndicator setTitle: @"Local"];
    else{
        [controllableIndicator setTitle: @"Remote"];
        //[urlField setEnabled: NO];
        //[webView setEditable: NO];
    }
}

- (void) onScroll{
    [starter sendWindowScrollUpdate:self];
}

@synthesize starter, user, webView, url, primeTag, urlField, windowID, isControllable, currentHTML, isOverridingLoad, scrollPositionJS, controllableIndicator, userIndicator;
@synthesize killerWindow;
WebPreferences* defaultPreferences;

- (id) initWithDefaultWindowAndControllable: (BOOL) cont{
    self = [super initWithWindowNibName:@"BrowserWindowController"];
    if (self){
        isControllable = [NSNumber numberWithBool:cont];
        isOverridingLoad = [NSNumber numberWithBool:YES];
        windowID = [NSNumber numberWithInt: -1]; //should actually never be -1 when being used
        [self showWindow:nil];
        [self.window makeKeyAndOrderFront:nil];
        killerWindow.controller = self;
    /*
        defaultPreferences = [[WebPreferences alloc] initWithIdentifier:@"defaultPreferences"]; //maybe this bit needs to be cleaned up
        [defaultPreferences setPlugInsEnabled: YES];
        [webView setPreferences: defaultPreferences];
        if ([webView.preferences arePlugInsEnabled]) NSLog(@"Plugins are enabled.");
      */
        //[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onBeginLoad:) name: WebViewProgressStartedNotification object:webView]; //which to use?
        
        [webView setPolicyDelegate: self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onFinishLoad:) name: WebViewProgressFinishedNotification object:webView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onWindowClose:) name: NSWindowWillCloseNotification object:[self window]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onFinishResize:) name: NSWindowDidResizeNotification object:[self window]];
    }
    return self;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame  decisionListener:(id < WebPolicyDecisionListener >)listener

{
    
    NSUInteger actionType = [[actionInformation objectForKey:WebActionNavigationTypeKey] unsignedIntValue];
    if (actionType == WebNavigationTypeLinkClicked) {
        if (![isControllable boolValue]) return;
        else [listener use];
    } else {
        [listener use];
    }
    
}

- (void) onConnect{
    if (starter && starter.name) [userIndicator setTitle: starter.name];
}

-(void) onFinishResize: (NSNotification *) notification{
    NSLog(@"onFinishResize called for window %@.", windowID);
    if (starter.socket && [isControllable boolValue]) [starter sendWindowDimensionsUpdate: self];
}

-(void) onWindowClose: (NSNotification *) notification{
    NSLog(@"onWindowClose called for window %@.", windowID);
    NSData* header = [[NSString stringWithFormat:@"%d", [windowID intValue]] dataUsingEncoding:NSUTF8StringEncoding];
    if (starter.socket && [isControllable boolValue]) [TCPSender sendData: header onSocket: starter.socket withTimeout: standardTimeout tag: windowCloseTag];
}

//************************************************************** Need to fix content loading bugs with link loading and other things! *********************************
-(void) onFinishLoad: (NSNotification *) notification{
    url = webView.mainFrameURL;
    NSLog(@"onFinishLoad called, URL is %@", url);
    if (urlField && url) [urlField setStringValue: url];
    else NSLog(@"ERROR updating url in text field box!"); //seems to happen when there really is no error?
    if (starter.socket && [isControllable boolValue]) [starter sendWindowUpdate: self]; //only if logged in and controllable window
    if (scrollPositionJS){
        NSLog(@"Setting new scroll position with Javascript %@ for window with URL %@", scrollPositionJS, url); //THIS IS STILL PROBLEMATIC
        [webView stringByEvaluatingJavaScriptFromString:scrollPositionJS];
    }
}

-(void) onBeginLoad: (NSNotification *) notification{ //make this work! AND MAKE THIS ONSTARTLOAD!
    if (isOverridingLoad.boolValue){
    url = webView.mainFrameURL;
    NSLog(@"onBeginLoad called, URL is %@", url);
    if (urlField && url) [urlField setStringValue: url];
    else NSLog(@"ERROR updating url in text field box!"); //this seems to show up when there isn't really anything wrong...
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
    scrollPositionJS = nil; //hackjob?
    if (essence.owner){
        user = [BrowserWindowEssence stringFromData: essence.owner];
        NSLog(@"Setting browser window owner name to %@", user);
        [userIndicator setTitle: user]; //isn't working for some reason TODO
    }
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
    
    if (essence.scrollPosition){ //NOT WORKING PROPERLY YET
        NSString* dataString = [[NSString alloc] initWithData:essence.scrollPosition encoding: NSUTF8StringEncoding];
        NSPoint dimensions = NSPointFromString(dataString);
        NSLog(@"Changing scroll position of existing window to %@.", dataString);
        scrollPositionJS = [NSString stringWithFormat:@"scrollTo(%d,%d)", (int)dimensions.x, (int)dimensions.y];
        [webView stringByEvaluatingJavaScriptFromString:scrollPositionJS];
    }
    
    if (essence.dimensions){
        NSString* dataString = [[NSString alloc] initWithData:essence.dimensions encoding: NSUTF8StringEncoding];
        NSRect dimensions = NSRectFromString(dataString);
        dimensions.origin = self.window.frame.origin;
        [[self window] setFrame:dimensions display: YES animate: NO];
    }
    NSLog(@"Done updating window from essence.");
}

- (IBAction)forward:(id)sender {
    NSLog(@"Browser window navigating forward.");
    [webView goForward];
}

- (IBAction)back:(id)sender {
    NSLog(@"Browser window navigating back.");
    [webView goBack];
}

- (IBAction)reloadPage:(id)sender {
    NSLog(@"Browser window reloading.");
    [self loadCurrentContent];
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

- (void) setCookiesFromData: (NSData*) data{
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"Window %d unarchiving cookies data, length of array is %d", [windowID intValue], array.count);
    for (NSData* cookieData in array){
        NSDictionary* cookieDict = [NSPropertyListSerialization propertyListWithData:cookieData options:0 format:NSPropertyListBinaryFormat_v1_0 error:NULL];
        NSHTTPCookie* cookie = [NSHTTPCookie cookieWithProperties:cookieDict];
        [webView injectCookie: cookie];
        NSLog(@"Injected cookie: %@", cookie);
    }
}

@end

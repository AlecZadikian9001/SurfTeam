//
//  ServerConnectionViewController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 10/6/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "ServerConnectionViewController.h"

@interface ServerConnectionViewController ()

@end

@implementation ServerConnectionViewController
BrowserWindowEssence* receivingWindow; BrowserWindowController* windowToBeUpdated;
ServerConnectionViewController* defaultStarter;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        NSLog(@"init called in StarterWindowController, separator tag is %d", separatorTag);
        browserWindows = [[NSMutableArray alloc] init];
        defaultStarter = self;
    }
    return self;
}

+(ServerConnectionViewController*) defaultStarter{ return defaultStarter; }

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@synthesize serverIPField, serverPasswordField, serverPortField, nameField, socket, browserWindows, name;

-(void)sendData: (NSData*) data withTimeout: (NSTimeInterval) timeout tag: (long) tag{ //unified sending method
    [TCPSender sendData: data onSocket: socket withTimeout: timeout tag: tag];
}

-(void)askForWindows{
    [self sendData: [@"a" dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag: windowQueryTag];
}

-(void)sendWindows{
    NSLog(@"Sending %d windows...", browserWindows.count);
    for (BrowserWindowController* window in browserWindows){
        if ([window getIsControllable]) [self sendWindow: window]; //only want to send windows that you are in control of
    }
}

-(void) sendWindow: (BrowserWindowController*) window{
    NSLog(@"Began sending window with URL \"%@\"", window.url);
    [self sendHeader:       window  isUpdate: NO isStart: YES]; //tell the other clients that a window is beginning being sent and what local ID it has
    [self sendCookies:      window];
    [self sendDimensions:   window];
    [self sendURL:          window];
    [self sendHTML:         window];
    [self sendHeader:       window  isUpdate: NO isStart: NO]; //tell the other clients that a window is done being sent
    NSLog(@"Finished sending window with URL \"%@\"", window.url);
}

-(void) sendWindowUpdate:(BrowserWindowController*) window{
    NSLog(@"Began sending window update with URL \"%@\"", window.url);
    [self sendHeader:       window  isUpdate: YES isStart: YES]; //tell the other clients that a window is beginning being sent and what local ID it has
    [self sendCookies:      window];
    [self sendDimensions:   window];
    [self sendURL:          window];
    [self sendHTML:         window];
    [self sendHeader:       window  isUpdate: YES isStart: NO]; //tell the other clients that a window is done being sent
    NSLog(@"Finished sending window update with URL \"%@\"", window.url);
}

- (void)sendHeader: (BrowserWindowController*) window isUpdate: (BOOL) update isStart: (BOOL) isStart{
    NSData* headerData = [[NSString stringWithFormat: @"%d", window.getID] dataUsingEncoding: NSUTF8StringEncoding];
    if (!update){
    if (isStart)    [self sendData: headerData withTimeout: standardTimeout tag: windowBeginTag];
    else            [self sendData: headerData withTimeout: standardTimeout tag: windowEndTag];
    }
    else{
        if (isStart)    [self sendData: headerData withTimeout: standardTimeout tag: windowBeginUpdateTag];
        else            [self sendData: headerData withTimeout: standardTimeout tag: windowEndTag];
    }
}

- (void)sendCookies: (BrowserWindowController*) window{ //sends the cookies if logged in
    return; //FOR NOW, DO NOTHING, TODO TODO
    if (socket==nil) return;
    NSArray* cookies = [window getCookiesForCurrentURL];
    //[starter.socket writeData: [[NSData alloc] init] withTimeout: standardTimeout tag:cookieBeginTag];
    for (NSHTTPCookie* cookie in cookies) {
        DLog(@"Cookie being sent: %@", [cookie description]);
        [self sendData: [[cookie description] dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:cookieTag];
    }
    //[socket writeData: [[NSData alloc] init] withTimeout: standardTimeout tag:cookieEndTag];
}

- (void)sendDimensions: (BrowserWindowController*) window{
    /*   NSRect rect = window.window.frame; NSPoint origin = rect.origin; NSSize size = rect.size;
     WebView* webView = window.webView; CGPoint offset = webView.contentOffset;
     NSString* dimensionString = [NSString stringWithFormat:@"%f;%f;%f;%f;%f;%f", origin.x, origin.y, size.width, size.height,offset.x, offset.y];
     //so the dimensions that must be parsed are like this: x, y, width, heigh, scroll position x, scroll position y
     //not going to send it yet... TODO */
}

- (void)sendHTML: (BrowserWindowController*) window{
    if (socket==nil) return;
    NSString *html = [window.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    [self sendData: [html dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:pageSourceTag];
}

- (void)sendURL: (BrowserWindowController*) window{
    if (socket==nil) return;
    [self sendData: [window.url dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:pageSourceTag];
}

-(void)insertBrowserWindow: (BrowserWindowController*) window{
    int i = browserWindows.count;
    [window setID: i+1];
    NSLog(@"Browser window being added with index %d and id %d.", i, i+1);
    [browserWindows addObject:window];
    DLog(@"Number of browserWindows now: %d", browserWindows.count);
}

- (IBAction)connectButton:(id)sender {
    NSLog(@"About to connect to address %@ on port %@ with %d local windows open.", serverIPField.stringValue, serverPortField.stringValue, browserWindows.count);
    socket = [[GCDAsyncSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
    name = nameField.stringValue;
    NSLog(@"Name set to %@", name);
    NSError* error = [[NSError alloc] init];
    if (![socket connectToHost: serverIPField.stringValue onPort: [serverPortField.stringValue integerValue] withTimeout:standardTimeout error:&error])
        NSLog(@"Unable to connect to host; error: %@", error);
    else{
        [self sendData: [serverPasswordField.stringValue dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:negotiationTag]; //send password
        //[socket readDataWithTimeout: standardTimeout tag: nicknameTag];
        [self sendData: [name dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:nicknameTag];
        
        [self sendWindows];
        [self askForWindows];
        [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:firstTag];
    }

}

//AsyncSocketDelegate methods:

- (void)socket:(GCDAsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"Socket %@ disconnecting with error %@", sock, err);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock{
    NSLog(@"Socket %@ disconnected.", sock);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"Socket %@ connected to host %@:%d", sock, host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //NSLog(@"Socket %@ read data on thread %@ with local tag %ld.", sock, [NSThread currentThread], tag);
    tag = [TCPSender getTagFromData: data];
   // DLog(@"Data network tagged as %ld received: %@", tag, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
    if (tag==windowQueryTag){ NSLog(@"Window query command received."); [self sendWindows]; }
    
    if (tag == windowBeginTag){
        NSLog(@"A window is about to be received.");
        if (receivingWindow) NSLog(@"Client read a window receive tag when it was already receiving one! Error!");
        windowToBeUpdated = nil;
        receivingWindow = [[BrowserWindowEssence alloc] init];
        receivingWindow.owner = [name dataUsingEncoding: NSUTF8StringEncoding];
        receivingWindow.primeTag = data; //ugh, bad again
        NSLog(@"Received prime tag %@", [BrowserWindowEssence stringFromData: receivingWindow.primeTag]);
    }
    else if (tag == windowEndTag){
        if (!receivingWindow) NSLog(@"Client read a window end tag when it was not already receiving one! Error!");
        if (!windowToBeUpdated){

            BrowserWindowController* newWindow =[[BrowserWindowController alloc] initWithWindowNibName:@"BrowserWindowController"];
            [newWindow updateFromEssence: receivingWindow];
            [newWindow addStarter: self overNetwork: YES];
            [newWindow showWindow:nil];
            [newWindow.window makeKeyAndOrderFront:nil];
        }
        else [windowToBeUpdated updateFromEssence: receivingWindow];
        receivingWindow = nil; windowToBeUpdated = nil;
    }
    else if (tag == windowBeginUpdateTag){
        if (receivingWindow) NSLog(@"Client read a window update receive tag when it was already receiving one! Error!");
        NSData* primeTagData = data;
        for (BrowserWindowController* window in browserWindows){
            if ([window.primeTag isEqualToData: primeTagData]){
                windowToBeUpdated = window;
                return;
            }
        }
        NSLog(@"Received a window update tag... but no window to update!");
    }
    else if (receivingWindow){
        if      (tag==urlTag)           { receivingWindow.url = data; NSLog(@"Received URL data."); }
        else if (tag==pageSourceTag)    { receivingWindow.html = data; NSLog(@"Received HTML data."); }
        else if (tag==scrollPositionTag){ receivingWindow.scrollPosition = data; NSLog(@"Received scroll position data."); }
    } //everything after this is called only when a window is not already being received!
    
    else if (tag == cookieTag){
     //   NSLog(@"Data received that must be distributed.");
        //DLog(@"Data tagged with %ld, contains %@", tag, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding], tag);
       // [server distributeData: data fromClient: self withTimeout: standardTimeout tag:tag];
        //   [cookies addObject:[[NSHTTPCookie alloc] init];
    }
    
    [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:connectedTag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
 //   NSLog(@"Socket %@ wrote data.", sock);
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"Error, read timeout!");
    [socket disconnect];
    [socket setDelegate: nil];
    return 0;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"Error, write timeout!");
    [socket disconnect];
    [socket setDelegate: nil];
    return 0;
}

@end

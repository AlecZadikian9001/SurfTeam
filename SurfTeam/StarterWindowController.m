//
//  StarterViewController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "StarterWindowController.h"

@implementation StarterWindowController
@synthesize serverIPField, serverPasswordField, serverPortField, nameField, socket, browserWindows, name;

-(id)initWithWindowNibName: (NSString*) nibName;
{
    self = [super initWithWindowNibName: nibName];
    if (self){
        NSLog(@"init called in StarterWindowController");
        browserWindows = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (IBAction)connectButton:(id)sender {
    NSLog(@"About to connect to address %@ on port %@", serverIPField.stringValue, serverPortField.stringValue);
    socket = [[GCDAsyncSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
    name = nameField.stringValue;
    NSLog(@"Name set to %@", name);
    NSError* error = [[NSError alloc] init];
    if (![socket connectToHost: serverIPField.stringValue onPort: [serverPortField.stringValue integerValue] withTimeout:standardTimeout error:&error])
        NSLog(@"Unable to connect to host; error: %@", error);
    else{
        [socket writeData: [serverPasswordField.stringValue dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:negotiationTag]; //send password
        [socket readDataWithTimeout: standardTimeout tag: nicknameTag];
      //  [socket writeData: [nameField.stringValue dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:nicknameTag];
        [self sendWindows];
    }
}

-(void)sendWindows{
    for (BrowserWindowController* window in browserWindows){
        [self sendWindow: window];
    }
}

-(void) sendWindow: (BrowserWindowController*) window{
    [socket writeData: [[NSData alloc] init] withTimeout: standardTimeout tag:windowBeginTag]; //tell the other clients that a window is beginning being sent
    [self sendCookies: window];
    [self sendHTML : window];
    [socket writeData: [[NSData alloc] init] withTimeout: standardTimeout tag:windowEndTag]; //tell the other clients that a window is done being sent
}

- (void)sendCookies: (BrowserWindowController*) window{ //sends the cookies if logged in
    if (socket==nil) return;
    NSArray* cookies = [window getCookiesForCurrentURL];
    //[starter.socket writeData: [[NSData alloc] init] withTimeout: standardTimeout tag:cookieBeginTag];
    for (NSHTTPCookie* cookie in cookies) {
        DLog(@"Cookie being sent: %@", [cookie description]);
        [socket writeData: [[cookie description] dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:cookieBeginTag];
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
    NSLog(@"Sending HTML source... Brace yourself.");
    NSString *html = [window.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    [socket writeData: [html dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:pageSourceTag];
}

-(void)insertBrowserWindow: (BrowserWindowController*) window{
    NSLog(@"Browser window added.");
    NSString* key = [NSString stringWithFormat: @"%d", [window getID]];
    [browserWindows insertValue: window inPropertyWithKey: key];
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
    NSLog(@"Socket %@ read data.", sock);
    if (tag==nicknameTag){ //send the nickname
        [socket writeData: [name dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:nicknameTag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Socket %@ wrote data.", sock);
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

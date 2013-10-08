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

NSData *inData, *outData;
NSMutableData* cookieBuffer;
BOOL isControllable; //that is, if I own it
int windowID;

- (void) addStarter: (ServerConnectionViewController*) st overNetwork: (BOOL) net{
    NSLog(@"Starter being added to browser window.");
        starter = st;
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
    [starter sendWindow: self];
}

- (NSArray*)getCookiesForCurrentURL
{
    if (!url) return [[NSArray alloc] init];
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:url]];
}

- (void)loadCookies
{
    [starter.socket
     readDataWithTimeout:standardTimeout
     buffer:cookieBuffer
     bufferOffset:0
     tag:cookieTag
     ];
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
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Socket %@ wrote data.", sock);
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"Error, read timeout!");
    return 0;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"Error, write timeout!");
    return 0;
}


@end

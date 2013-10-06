//
//  BrowserWindowController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "BrowserWindowController.h"

@implementation BrowserWindowController
@synthesize starter, owner, webView, url, window;

NSData *inData, *outData;
NSMutableData* cookieBuffer;
BOOL isControllable; //that is, if I own it
int windowID;

- (id) initWithStarter: (StarterWindowController*) st windowID: (int) i{
    self = [super initWithWindowNibName:@"Browser Window"];
    if (self){
        windowID = i;
        starter = st;
        [self showWindow:nil];
        [self.window makeKeyAndOrderFront:nil]; //?????????? WHY WON'T THE WINDOW WORK?!
        [starter insertBrowserWindow: self];
    }
    return self;
}

- (int) getID{ return windowID; }
- (BOOL) getIsControllable{ return isControllable; }

- (IBAction)loadPage:(NSTextFieldCell *)sender {
    url = sender.stringValue;
    NSLog(@"Page being loaded, URL: %@", url);
    [webView setMainFrameURL: url];
    [webView reload: self];
    [starter sendWindow: self];
}

- (NSArray*)getCookiesForCurrentURL
{
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

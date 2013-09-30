//
//  BrowserWindowController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "BrowserWindowController.h"
#import "AsyncSocket.h"

@implementation BrowserWindowController //also implements AsyncSocketDelegate. fix?
@synthesize socket;

NSData *inData, *outData;
NSMutableData* cookieBuffer;

int MAX_COOKIE_LENGTH_BYTES = 1000;
int COOKIE_TIMEOUT = 10000;
int COOKIE_TAG = 1;


- (BrowserWindowController*) init{
   socket = [[AsyncSocket alloc] initWithDelegate: self];
    return self;
}

- (void)saveCookies
{
    NSData         *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    //must send this to other user
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"cookies"];
    [defaults synchronize];
}

- (void)loadCookies
{
[socket 
    readDataToLength:MAX_COOKIE_LENGTH_BYTES
             withTimeout:COOKIE_TIMEOUT
                  buffer:cookieBuffer
            bufferOffset:1 //?
                     tag:COOKIE_TAG
];
}

- (BOOL)connectToServer: (NSString*) address onPort: (int) port{
    NSError* error;
    if (![socket connectToHost: address onPort: port error: &error]) NSLog(@"Failed to connect to host %@: %@", address, error);
    return YES;
}

- (void)disconnectGracefully{
	[socket setDelegate: nil];
	[socket disconnectAfterReadingAndWriting];
}

- (void)disconnectForcibly{
	[socket setDelegate: nil];
	[socket disconnect];
}

//AsyncSocketDelegate methods:

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
NSLog(@"Socket %@ disconnecting with error %@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
NSLog(@"Socket %@ disconnected.", sock);
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
NSLog(@"Socket %@ connected to host %@:%d", sock, host, port);
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
NSLog(@"Socket %@ read data.", sock);
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
NSLog(@"Socket %@ wrote data.", sock);
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length{
    return 1;
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length{
    return 1;
    
}




@end

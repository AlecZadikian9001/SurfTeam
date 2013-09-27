//
//  BrowserWindowController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "BrowserWindowController.h"

@implementation BrowserWindowController //also implements AsyncSocketDelegate. fix?

AsyncSocket *socket;
NSError *error;
NSData *inData, *outData;

- (void) init{
   socket = [[AsyncSocket alloc] initWithDelegate: self];
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
            bufferOffset:(NSUInteger)offset
                     tag:(long)tag
];

//TODOOOOOOOOOO

    NSArray             *cookies       = [NSKeyedUnarchiver unarchiveObjectWithData: [[inData] objectForKey: @"cookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        [cookieStorage setCookie: cookie];
    }
}

- (BOOL)connectToServer: (NSString) *address onPort: (int) port{
    if (![socket connectToHost: address onPort: port error: &error]) NSLog(@"Failed to connect to host %@: %@", address, error);
}

- (void)disconnectGracefully{
	[socket setDelegate: nil]
	[socket disconnectAfterReadingAndWriting];
}

- (void)disconnectForcibly{
	[socket setDelegate: nil]
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
NSLog("Socket %@ read data.", sock);
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
NSLog("Socket %@ wrote data.", sock);
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length;

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length;



@end

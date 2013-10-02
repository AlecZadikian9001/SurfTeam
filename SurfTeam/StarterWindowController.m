//
//  StarterViewController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "StarterWindowController.h"

@implementation StarterWindowController

-(id)initWithWindowNibName: (NSString*) nibName;
{
    self = [super initWithWindowNibName: nibName];
    if (self){
        NSLog(@"init called in StarterWindowController");
        //TESTING, REMOVE THIS
        AsyncSocket* socket = [[AsyncSocket alloc] initWithDelegate: self];
        NSLog(@"About to attempt to connect to %@ on port %d", @"localhost", defaultPort);
        [socket connectToHost: @"localhost" onPort: defaultPort error:nil];
    }
    return self;
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
/*
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
*/

@end

//
//  ClientHandler.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "ClientHandler.h"

NSData *inData, *outData;
NSMutableData* buffer; NSString* bufferString;
Server* server;

@implementation ClientHandler

- (id) initWithServer:(Server*) s{
    self = [super init];
    if (self){
        server = s;
        inData = [[NSData alloc] init];
        outData = [[NSData alloc] init];
        buffer = [[NSMutableData alloc] init];
        bufferString = [NSString alloc];
    }
    return self;
}

- (void)disconnectGracefully: (AsyncSocket*) socket{
	[socket setDelegate: nil];
	[socket disconnectAfterReadingAndWriting];
}

- (void)disconnectForcibly: (AsyncSocket*) socket{
	[socket setDelegate: nil];
	[socket disconnect];
}

//AsyncSocketDelegate methods:

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
	NSLog(@"New socket %@ created by %@", newSocket, sock);
}

//- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{ return nil; }

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{ return YES; }

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"Socket %@ disconnecting with error %@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"Socket %@ disconnected.", sock);
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{ //will fire every time a client is connected
    NSLog(@"Socket %@ connected to host %@:%d", sock, host, port);
    [sock readDataWithTimeout: -1 buffer: buffer bufferOffset: 0 tag: 0]; //tag 0 is for server negotation messages, no timeout
    if (![[bufferString initWithData:buffer encoding:NSUTF8StringEncoding] isEqualToString: server.password]){ //if password is wrong
        [self disconnectForcibly: sock]; //fatality
    }
    //if password is right:
    //TODO
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
    NSLog(@"Error: %d", __LINE__);
    
    return 1;
}

- (NSTimeInterval)onSocket:(AsyncSocket*)sock
 shouldTimeoutWriteWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length{
    NSLog(@"Error: %d", __LINE__);
    
    return 1;
}


@end

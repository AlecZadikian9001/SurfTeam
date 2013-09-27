//
//  Server.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "Server.h"

@implementation Server
@synthesize sockets

NSError *error;
NSData *inData, *outData;

- (void) init{
   socket = [[AsyncSocket alloc] initWithDelegate: self];
}

- (void)distributeData: (NSData*) data fromUser: (int) id{

} 

- (void)disconnectGracefully{
	[socket setDelegate: nil]
	[socket disconnectAfterReadingAndWriting];
}

- (void)disconnectForcibly{
	[socket setDelegate: nil]
	[socket disconnect];
}

//AsyncSocketDelegate methods: TO BE MOVED TO CLIENT THREADS

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
	NSLog(@"New socket %@ created by %@", newSocket, sock); 
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{ }

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{ }

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
                 bytesDone:(NSUInteger)length{
NSLog(@"Error: %@", __LINE__);
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length{
NSLog(@"Error: %@", __LINE__);
}



@end

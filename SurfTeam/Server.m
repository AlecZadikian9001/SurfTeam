//
//  Server.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "Server.h"
#import "AsyncSocket.h"
#import "ClientHandler.h"

@implementation Server
@synthesize clientHandlers, password;

NSError *error;
NSData *inData, *outData;
AsyncSocket* serverSocket;

int DEFAULT_PORT = 9000;

- (id) initWithPassword: (NSString*) pw{
    self = [super init];
    if(self){
        password = pw;
    clientHandlers = [[NSMutableArray alloc] init];
    serverSocket = [[AsyncSocket alloc] initWithDelegate: self];
    NSError *error;
    [serverSocket acceptOnPort: DEFAULT_PORT error: &error];
    }
    return self;
}

- (void)distributeData: (NSData*) data 
	withTimeout: (NSTimeInterval)timeout
	tag: (long) tag
	{
for (ClientHandler* client in clientHandlers{
	[client.socket writeData: data withTimeout: timeout tag: tag];
	}
}


//AsyncSocketDelegate methods:

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
	NSLog(@"New socket %@ created by %@", newSocket, sock);
    newSocket.delegate = [[ClientHandler alloc] initWithServer: self socket: newSocket];
    [clientHandlers addObject: newSocket];
}

//- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{ return nil; }

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{ return YES; }

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

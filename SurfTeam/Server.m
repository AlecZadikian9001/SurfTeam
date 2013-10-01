//
//  Server.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "Server.h"
#import "AppDelegate.h"

@implementation Server
@synthesize clientHandlers, password;

NSError *error;
NSData *inData, *outData;
AsyncSocket* serverSocket;
int port;
NSTextField* label;

- (id) initWithPort: (int) po password: (NSString*) pw{
    self = [super init];
    if(self){
        NSLog(@"Server being initialized with port %d and password \"%@\"", po, pw);
        password = pw;
        port = po;
    clientHandlers = [[NSMutableArray alloc] init];
    serverSocket = [[AsyncSocket alloc] initWithDelegate: self];
    NSError *error;
        [serverSocket acceptOnPort: port error: &error];
    }
    return self;
}

-(void)addLabel: (NSTextField*) l{
    label = l;
    label.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)clientHandlers.count];
}

- (void)distributeData: (NSData*) data fromClient: (ClientHandler*) client
	withTimeout: (NSTimeInterval)timeout
	tag: (long) tag
	{
for (ClientHandler* client2 in clientHandlers){
	if (client!=client2) [client2.socket writeData: data withTimeout: timeout tag: tag]; //don't send to the sender
	}
}


//AsyncSocketDelegate methods:

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
	NSLog(@"New socket %@ accepted by %@", newSocket, sock);
    newSocket.delegate = [[ClientHandler alloc] initWithServer: self socket: newSocket];
    [clientHandlers addObject: newSocket];
    label.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)clientHandlers.count];
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
/*
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
*/

@end

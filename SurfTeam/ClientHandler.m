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
@synthesize socket;

- (id) initWithServer:(Server*) s socket:(AsyncSocket*) sock{
    self = [super init];
    if (self){
        server = s;
	socket = sock;
        inData = [[NSData alloc] init];
        outData = [[NSData alloc] init];
        buffer = [[NSMutableData alloc] init];
        bufferString = [NSString alloc];

	//time to get login stuff
	NSLog(@"Socket %@ connected to host %@:%d", sock, host, port);
    [sock readDataWithTimeout: -1 buffer: buffer bufferOffset: 0 tag: 0]; //tag 0 is for server negotation messages, no timeout
    if (![[bufferString initWithData:buffer encoding:NSUTF8StringEncoding] isEqualToString: server.password]){ //if password is wrong
        [self disconnectSocketForcibly: sock]; //fatality
    }
    //if password is right:
    //TODO

    }
    return self;
}

- (void)disconnectSocketGracefully: (AsyncSocket*) socket{
	[socket setDelegate: nil];
	[socket disconnectAfterReadingAndWriting];
}

- (void)disconnectSocketForcibly: (AsyncSocket*) socket{
	[socket setDelegate: nil];
	[socket disconnect];
}

//AsyncSocketDelegate methods:

//- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{ return nil; }

//- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{ return YES; }

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"Socket %@ disconnecting with error %@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"Socket %@ disconnected.", sock);
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

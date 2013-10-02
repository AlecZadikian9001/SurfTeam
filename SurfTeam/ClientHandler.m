//
//  ClientHandler.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "ClientHandler.h"

NSData *inData, *outData;
NSMutableData* buffer;
Server* server;
BOOL isLoggedIn;

@implementation ClientHandler
@synthesize socket;

- (id) initWithServer:(Server*) s socket:(GCDAsyncSocket*) sock{
    self = [super init];
    if (self){
        isLoggedIn = NO;
        server = s;
        socket = sock;
        inData = [[NSData alloc] init];
        outData = [[NSData alloc] init];
        buffer = [[NSMutableData alloc] init];

        //creator of this is going to run the thread to make sure client is valid
    }
    return self;
}

- (void) main{
    //time to get login stuff
	NSLog(@"Socket %@ connected to host.", socket);
    [socket readDataWithTimeout: negotiationTimeout buffer: buffer bufferOffset: 0 tag: negotiationTag];
    while (buffer.length==0){[NSThread sleepForTimeInterval:.5]; DLog(@"Waiting...");} //wait for password
    NSString* password = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
    password = [password substringToIndex: (password.length - 2)]; //TO BE REMOVED LATER
    if (![password isEqualToString: server.password]){ //if password is wrong
        NSLog(@"Wrong password! Password entered: \"%@\" instead of the server's password \"%@\".", password, server.password);
        [self disconnectSocketForcibly: socket]; //fatality
    }
    else{ isLoggedIn = YES; NSLog(@"User successfully logged in."); }
}

- (void)disconnectSocketGracefully: (GCDAsyncSocket*) socket2{
	[socket2 disconnectAfterReadingAndWriting];
    [socket2 setDelegate: nil];
}

- (void)disconnectSocketForcibly: (GCDAsyncSocket*) socket2{
	[socket2 disconnect];
    [socket2 setDelegate: nil];
}

//AsyncSocketDelegate methods:

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"Socket %@ disconnecting from ClientHandler with error %@", sock, err);
    [server.delegate onClientDisconnect];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"Socket %@ connected to host %@:%d", sock, host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"Socket %@ read data.", sock);
    
    //TO BE DELETED LATER:
    NSLog(@"Incoming message: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    
    if (!isLoggedIn && tag!=negotiationTag){ NSLog(@"Socket %@ tried to read non-negotation data, but user was not logged in!", sock); return; }
    if (tag==negotiationTag) NSLog(@"User is trying to negotiate login: \"%@\"", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    else if (tag==cookieTag || tag==pageSourceTag){
        [server distributeData: data fromClient: self withTimeout: standardTimeout tag:tag];
    }
    else (NSLog(@"Socket %@ read data with an invalid tag! Tag is %ld", sock, tag));
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Socket %@ wrote data.", sock);
}

@end

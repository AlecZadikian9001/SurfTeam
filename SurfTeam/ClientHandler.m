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
int userID;

@implementation ClientHandler
@synthesize socket, name;

- (id) initWithServer:(Server*) s socket:(GCDAsyncSocket*) sock{
    self = [super init];
    if (self){
        isLoggedIn = NO;
        server = s;
        socket = sock;
        inData = [[NSData alloc] init];
        outData = [[NSData alloc] init];
        buffer = [[NSMutableData alloc] init];
        userID = server.clientHandlers.count;
        name = @"default";

        //creator of this is going to run the thread to make sure client is valid
        NSLog(@"Socket %@ given delegate.", socket);
        [socket readDataWithTimeout:standardTimeout buffer: buffer bufferOffset: 0 tag: negotiationTag];
        [socket readDataWithTimeout:standardTimeout buffer: buffer bufferOffset: 0 tag: nicknameTag];
    }
    return self;
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
    NSLog(@"Socket %@ read data on thread %@.", sock, [NSThread currentThread]);
    
    //TO BE DELETED LATER:
    NSLog(@"Incoming message: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if (!isLoggedIn && tag!=negotiationTag){ NSLog(@"Socket %@ tried to read non-negotation data, but user was not logged in!", sock); return; }
    else if (!isLoggedIn && tag==negotiationTag){
        NSLog(@"User is trying to negotiate login: \"%@\"", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSString* password = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
        if (![password isEqualToString: server.password]){ //if password is wrong
            NSLog(@"Wrong password! Password entered: \"%@\" instead of the server's password \"%@\".", password, server.password);
            [self disconnectSocketForcibly: socket]; //fatality
        }
        else{
            isLoggedIn = YES;
            name = [NSString stringWithFormat:@"User%d", userID];
            NSLog(@"User %@ successfully logged in.", name);
            [socket writeData: data withTimeout: standardTimeout tag: nicknameTag]; //echo back to ask for nickname
        }
    }
    else if (tag==cookieTag || tag==pageSourceTag){
        [server distributeData: data fromClient: self withTimeout: standardTimeout tag:tag];
    }
    else if (tag==nicknameTag){ name = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]; NSLog(@"User changed nickname to %@", name); }
    else (NSLog(@"Socket %@ read data with an invalid tag! Tag is %ld", sock, tag));
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Socket %@ wrote data.", sock);
}

@end

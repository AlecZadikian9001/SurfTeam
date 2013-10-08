//
//  ClientHandler.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "ClientHandler.h"

Server* server;
BOOL isLoggedIn;
BrowserWindowEssence* receivingWindow;
int userID;

@implementation ClientHandler
@synthesize socket, name, windows, cookies;

- (id) initWithServer:(Server*) s socket:(GCDAsyncSocket*) sock{
    self = [super init];
    if (self){
        isLoggedIn = NO;
        server = s;
        socket = sock;
        windows = [[NSMutableArray alloc] init];
        userID = server.clientHandlers.count;
        name = @"default";

        //creator of this is going to run the thread to make sure client is valid
        NSLog(@"Socket %@ given delegate.", socket);
        [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag: firstTag];
        //[socket readDataWithTimeout:standardTimeout buffer: buffer bufferOffset: 0 tag: nicknameTag];
    }
    return self;
}
/*
- (void)askForWindows{
    NSLog(@"Client %d is expecting windows.", userID);
    [TCPSender sendData: [@"a" dataUsingEncoding: NSUTF8StringEncoding] onSocket: socket withTimeout: standardTimeout tag: windowQueryTag];
    isExpectingWindows = true;
}
*/
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
 //   NSLog(@"Socket %@ read data on thread %@ with local tag %ld.", sock, [NSThread currentThread], tag);
    tag = [TCPSender getTagFromData: data];
  //  DLog(@"Data network tagged as %ld received: %@", tag, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
    if (tag==negotiationTag){
        if (isLoggedIn){ NSLog(@"User %@ trying to send negotiation tag but is already logged in. Major error!", name); return; }
        NSLog(@"User is trying to negotiate login: \"%@\"", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSString* password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (![password isEqualToString: server.password]){ //if password is wrong
                        NSLog(@"Wrong password! Password entered: \"%@\" instead of the server's password \"%@\".", password, server.password);
                        [self disconnectSocketForcibly: socket]; //fatality
                    }
                else{
                        isLoggedIn = YES;
                        name = [NSString stringWithFormat:@"User%d", userID];
                        NSLog(@"User %@ successfully logged in.", name);
                    }
    }
    else if (tag == windowBeginTag){
        NSLog(@"A window is about to be received.");
        if (receivingWindow) NSLog(@"Client handler read a window receive tag when it was already receiving one! Error!");
        receivingWindow = [[BrowserWindowEssence alloc] init];
        receivingWindow.owner = [name dataUsingEncoding: NSUTF8StringEncoding];
    }
    else if (tag == windowEndTag){
        if (!receivingWindow) NSLog(@"Client handler read a window end tag when it was not already receiving one! Error!");
        [windows addObject: receivingWindow];
        
        NSLog(@"Window %@ has finished being received, now sending it to others.", receivingWindow.url);
        NSMutableData* tempBegin =  [NSMutableData dataWithData:[@"a" dataUsingEncoding: NSUTF8StringEncoding]];
        NSMutableData* tempOwner =  [NSMutableData dataWithData: receivingWindow.owner];
        NSMutableData* tempURL =    [NSMutableData dataWithData: receivingWindow.url];
        NSMutableData* tempHTML =   [NSMutableData dataWithData: receivingWindow.html];
        NSMutableData* tempFinish = [NSMutableData dataWithData:[@"a" dataUsingEncoding: NSUTF8StringEncoding]];
        [TCPSender wrapData: tempBegin  withTag: windowBeginTag];
        [TCPSender wrapData: tempOwner  withTag: ownerTag];
        [TCPSender wrapData: tempURL    withTag: urlTag];
        [TCPSender wrapData: tempHTML   withTag: pageSourceTag];
        [TCPSender wrapData: tempFinish withTag: windowEndTag];
        [server distributeData: tempBegin   fromClient: self withTimeout: standardTimeout tag:windowBeginTag];
        [server distributeData: tempOwner   fromClient: self withTimeout: standardTimeout tag:ownerTag];
        [server distributeData: tempURL     fromClient: self withTimeout: standardTimeout tag:urlTag];
        [server distributeData: tempHTML    fromClient: self withTimeout: standardTimeout tag:pageSourceTag];
        [server distributeData: tempFinish  fromClient: self withTimeout: standardTimeout tag:windowEndTag];
        NSLog(@"Finished sending data for page at URL %@", receivingWindow.url);
        
        receivingWindow = nil;
    }
    else if (receivingWindow){
        if (tag==urlTag){ receivingWindow.url = data; NSLog(@"Received URL data."); }
        else if (tag==pageSourceTag){ receivingWindow.html = data; NSLog(@"Received HTML data."); }
    } //everything after this is called only when a window is not already being received!
    else if (tag == cookieTag){
        NSLog(@"Data received that must be distributed.");
        //DLog(@"Data tagged with %ld, contains %@", tag, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding], tag);
        [server distributeData: data fromClient: self withTimeout: standardTimeout tag:tag];
     //   [cookies addObject:[[NSHTTPCookie alloc] init];
    }
    else if (tag == scrollPositionTag || tag == urlTag || tag==pageSourceTag){
        NSLog(@"Data received that must be distributed.");
        //DLog(@"Data tagged with %ld, contains %@", tag, [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding], tag);
        [server distributeData: data fromClient: self withTimeout: standardTimeout tag:tag];
    }
    else if (tag == windowQueryTag) [server askForWindows: self];
    else if (tag==nicknameTag){ name = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; NSLog(@"User changed nickname to %@", name); }
    else (NSLog(@"Socket %@ read data with an invalid tag! Tag is %ld", sock, tag));
    [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag: connectedTag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
  //  NSLog(@"Socket %@ wrote data.", sock);
}

@end

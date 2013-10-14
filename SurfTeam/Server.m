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
@synthesize clientHandlers, delegate, password;

NSError *error;
NSData *inData, *outData;
GCDAsyncSocket* serverSocket;
int port;

- (id) initWithDelegate: (ServerAppDelegate*) del port: (int) po password: (NSString*) pw{
    self = [super init];
    if(self){
        [delegate onServerBeginOpen];
        NSLog(@"Separator tag is %d", separatorTag);
        NSLog(@"Server being initialized with port %d and password \"%@\"", po, pw);
        delegate = del;
        password = pw;
        port = po;
        clientHandlers = [[NSMutableArray alloc] init];
        serverSocket = [[GCDAsyncSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
        NSError *error;
        [serverSocket acceptOnPort: port error: &error];
        [delegate onServerFinishOpen];
    }
    return self;
}

- (void)distributeData: (NSData*) data fromClient: (ClientHandler*) client
           withTimeout: (NSTimeInterval)timeout
                   tag: (long) tag
{
    @synchronized(self){ //that's right, only one client at a time!
        for (ClientHandler* client2 in clientHandlers){
            if (client!=client2) [client2.socket writeData: data withTimeout: timeout tag: tag]; //don't send to the sender
        }
    }
}

- (void) sendWindowsToClient: (ClientHandler*) sourceClient{
    @synchronized(self){
        for (ClientHandler* client in clientHandlers){
            if (client!=sourceClient){
                for (BrowserWindowEssence* window in client.windows){
                    [TCPSender sendData: window.primeTag    onSocket: sourceClient.socket withTimeout: standardTimeout tag: windowBeginTag];
                    [TCPSender sendData: window.owner       onSocket: sourceClient.socket withTimeout: standardTimeout tag: ownerTag];
                    [TCPSender sendData: window.url         onSocket: sourceClient.socket withTimeout: standardTimeout tag: urlTag];
                    [TCPSender sendData: window.html        onSocket: sourceClient.socket withTimeout: standardTimeout tag: pageSourceTag];
                    [TCPSender sendData: window.primeTag    onSocket: sourceClient.socket withTimeout: standardTimeout tag: windowEndTag];
                }
            }
        }
    }
}

-(void) close{
    [delegate onServerBeginClose];
	[serverSocket disconnect];
    [serverSocket setDelegate: nil];
    [delegate onServerFinishClose];
}


//AsyncSocketDelegate methods:

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
	NSLog(@"New socket %@ accepted by %@", newSocket, sock);
    ClientHandler* temp = [ClientHandler alloc];
    [newSocket setDelegate: temp];
    [temp initWithServer: self socket: newSocket];
    [newSocket synchronouslySetDelegateQueue: dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT)];
    [clientHandlers addObject: temp];
    [delegate onClientConnect];
}

//- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{ return nil; }

//- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{ return YES; }

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"Socket %@ disconnecting with error %@", sock, err);
    [delegate onClientDisconnect];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"Socket %@ connected to host %@:%d", sock, host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"Socket %@ in main server thread read data.", sock);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
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

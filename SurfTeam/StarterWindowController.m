//
//  StarterViewController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "StarterWindowController.h"

@implementation StarterWindowController
@synthesize serverIPField, serverPasswordField, serverPortField, nameField, socket;

-(id)initWithWindowNibName: (NSString*) nibName;
{
    self = [super initWithWindowNibName: nibName];
    if (self){
        NSLog(@"init called in StarterWindowController");
    }
    return self;
}

- (IBAction)connectButton:(id)sender {
    NSLog(@"About to connect to address %@ on port %@", serverIPField.stringValue, serverPortField.stringValue);
    socket = [[GCDAsyncSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
    NSError* error = [[NSError alloc] init];
    if (![socket connectToHost: serverIPField.stringValue onPort: [serverPortField.stringValue integerValue] withTimeout:standardTimeout error:&error])
        NSLog(@"Unable to connect to host; error: %@", error);
    else{
        [socket writeData: [serverPasswordField.stringValue dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:negotiationTag];
        [socket readDataWithTimeout: standardTimeout tag: nicknameTag];
    }
}

//AsyncSocketDelegate methods:

- (void)socket:(GCDAsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"Socket %@ disconnecting with error %@", sock, err);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock{
    NSLog(@"Socket %@ disconnected.", sock);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"Socket %@ connected to host %@:%d", sock, host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"Socket %@ read data.", sock);
    if (tag==nicknameTag){
        [socket writeData: [nameField.stringValue dataUsingEncoding: NSUTF8StringEncoding] withTimeout: standardTimeout tag:nicknameTag]; }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"Socket %@ wrote data.", sock);
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"Error, read timeout!");
    [socket disconnect];
    [socket setDelegate: nil];
    return 0;
}

@end

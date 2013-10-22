//
//  ClientHandler.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "ClientHandler.h"

@implementation ClientHandler
@synthesize socket, name, windows, cookies, userID, server, isLoggedIn, windowToBeUpdated, receivingWindow, receivingCookiesData;

- (id) initWithServer:(Server*) s socket:(GCDAsyncSocket*) sock{
    self = [super init];
    if (self){
        isLoggedIn = [NSNumber numberWithBool: NO];
        server = s;
        socket = sock;
        windows = [[NSMutableArray alloc] init];
        name = @"default";

        //creator of this is going to run the thread to make sure client is valid
        NSLog(@"Socket %@ given delegate.", socket);
        [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag: firstTag];
        //[socket readDataWithTimeout:standardTimeout buffer: buffer bufferOffset: 0 tag: nicknameTag];
    }
    return self;
}

- (void)disconnectSocketGracefully{
	[socket disconnectAfterReadingAndWriting];
    [socket setDelegate: nil];
}

- (void)disconnectSocketForcibly{
	[socket disconnect];
    [socket setDelegate: nil];
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
    
    if (![isLoggedIn boolValue] && tag!=negotiationTag){ NSLog(@"Client tried to send data without being logged in."); [self disconnectSocketForcibly]; }
    if (tag==negotiationTag){
        if ([isLoggedIn boolValue]){ NSLog(@"User %@ trying to send negotiation tag but is already logged in. Major error!", name); return; }
        NSLog(@"User is trying to negotiate login: \"%@\"", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                NSString* password = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (![password isEqualToString: server.password]){ //if password is wrong
                        NSLog(@"Wrong password! Password entered: \"%@\" instead of the server's password \"%@\".", password, server.password);
                        [self disconnectSocketForcibly]; //fatality
                    }
                else{
                    isLoggedIn = [NSNumber numberWithBool: YES];
                        name = [NSString stringWithFormat:@"User%d", userID.integerValue];
                        NSLog(@"User %@ successfully logged in.", name);
                    }
    }
    else if (tag == windowBeginTag){
        NSLog(@"A window is about to be received.");
        if (receivingWindow || windowToBeUpdated) NSLog(@"Client handler read a window receive tag when it was already receiving one! Error!");
        receivingWindow = [[BrowserWindowEssence alloc] init];
        receivingWindow.owner = [name dataUsingEncoding: NSUTF8StringEncoding];
        int localID = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] integerValue]; //bad efficiency alert! :(
        int primeTag = pow(2, localID)*pow(3, userID.integerValue);
        receivingWindow.primeTag = [[NSString stringWithFormat:@"%d", primeTag] dataUsingEncoding: NSUTF8StringEncoding]; //ugh, bad again
        NSLog(@"Received local ID from %@ and used it to make prime tag %d", name, primeTag);
    }
    else if (tag == windowBeginUpdateTag){
        NSLog(@"A window update is about to be received.");
        if (receivingWindow || windowToBeUpdated) NSLog(@"Client handler read a window update receive tag when it was already receiving one! Error!");
        int localID = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] integerValue]; //bad efficiency alert! :(
        int primeTag = pow(2, localID)*pow(3, userID.integerValue);
        NSData* primeTagData = [[NSString stringWithFormat:@"%d", primeTag] dataUsingEncoding: NSUTF8StringEncoding];
        BOOL found = NO;
        for (BrowserWindowEssence* window in windows){
            if ([window.primeTag isEqualToData: primeTagData]){
                windowToBeUpdated = window;
                NSLog(@"Must update window with primetag %@ and URL %@", [[NSString alloc] initWithData: window.primeTag encoding: NSUTF8StringEncoding], window.url);
                [windowToBeUpdated clear];
                found = YES;
                break;
            }
            else{ DLog(@"A window with primeTag %@ has been skipped over in windowBeginUpdateTag.", [BrowserWindowEssence stringFromData: window.primeTag]); }
        }
        if (!found){
            NSLog(@"Received a window update tag %d... but no window to update!", primeTag);
            [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag: connectedTag];
            return;
        }
    }
    else if (tag == windowEndTag){
        if (receivingWindow){
            NSLog(@"Window %@ has finished being received, now sending it to others.", receivingWindow.url);
            [windows addObject: receivingWindow];
            [server distributeDataWithWrappedTag:receivingWindow.primeTag    fromClient:self withTimeout:standardTimeout tag:windowBeginTag];
            [server distributeDataWithWrappedTag:receivingWindow.owner       fromClient:self withTimeout:standardTimeout tag:ownerTag];
            [server distributeDataWithWrappedTag:receivingWindow.dimensions  fromClient:self withTimeout:standardTimeout tag:dimensionsTag];
            [server distributeDataWithWrappedTag:receivingWindow.scrollPosition  fromClient:self withTimeout:standardTimeout tag:scrollPositionTag];
            [server distributeDataWithWrappedTag:receivingWindow.url         fromClient:self withTimeout:standardTimeout tag:urlTag];
            [server distributeDataWithWrappedTag:receivingWindow.html        fromClient:self withTimeout:standardTimeout tag:pageSourceTag];
            [server distributeDataWithWrappedTag:receivingWindow.primeTag    fromClient:self withTimeout:standardTimeout tag:windowEndTag];
            receivingWindow = nil;
        }
        else if (windowToBeUpdated){
            NSLog(@"Window update %@ has finished being received, now sending it to others.", windowToBeUpdated.url);
            [server distributeDataWithWrappedTag:windowToBeUpdated.primeTag    fromClient:self withTimeout:standardTimeout tag:windowBeginUpdateTag];
            if (windowToBeUpdated.owner) [server distributeDataWithWrappedTag:windowToBeUpdated.owner       fromClient:self withTimeout:standardTimeout tag:ownerTag];
            if (windowToBeUpdated.dimensions) [server distributeDataWithWrappedTag:windowToBeUpdated.dimensions  fromClient:self withTimeout:standardTimeout tag:dimensionsTag];
            if (windowToBeUpdated.scrollPosition) [server distributeDataWithWrappedTag:windowToBeUpdated.scrollPosition  fromClient:self withTimeout:standardTimeout tag:scrollPositionTag];
            if (windowToBeUpdated.url) [server distributeDataWithWrappedTag:windowToBeUpdated.url         fromClient:self withTimeout:standardTimeout tag:urlTag];
            if (windowToBeUpdated.html) [server distributeDataWithWrappedTag:windowToBeUpdated.html        fromClient:self withTimeout:standardTimeout tag:pageSourceTag];
            [server distributeDataWithWrappedTag:windowToBeUpdated.primeTag    fromClient:self withTimeout:standardTimeout tag:windowEndTag];
            windowToBeUpdated = nil;
        }
        else{
            NSLog(@"Client handler read a window end tag when it was not already receiving one! Error!");
        }
        NSLog(@"Finished sending data for page at URL %@", receivingWindow.url);
    }
    else if (receivingWindow){
        if      (tag==urlTag)           { receivingWindow.url = data; NSLog(@"Received URL data."); }
        else if (tag==pageSourceTag)    { receivingWindow.html = data; NSLog(@"Received HTML data."); }
        else if (tag==scrollPositionTag){ receivingWindow.scrollPosition = data; NSLog(@"Received scroll position data."); }
        else if (tag==dimensionsTag)    { receivingWindow.dimensions = data; NSLog(@"Received dimensions data."); }
    }
    else if (windowToBeUpdated){
        if      (tag==urlTag)           { windowToBeUpdated.url = data; NSLog(@"Received URL data."); }
        else if (tag==pageSourceTag)    { windowToBeUpdated.html = data; NSLog(@"Received HTML data."); }
        else if (tag==scrollPositionTag){ windowToBeUpdated.scrollPosition = data; NSLog(@"Received scroll position data."); }
        else if (tag==dimensionsTag)    { windowToBeUpdated.dimensions = data; NSLog(@"Received dimensions data."); }
    }
    
    else if (tag == cookieBeginTag){
        receivingCookiesData = [NSData alloc];
    }
    
    else if (tag == cookieTag){
        if (!receivingCookiesData) NSLog(@"Received unexpected cookie data!!!");
        NSData* header = [[NSString stringWithFormat: @"%d", [userID intValue]] dataUsingEncoding:NSUTF8StringEncoding];
        [server distributeDataWithWrappedTag:header fromClient:self withTimeout:standardTimeout tag:cookieBeginTag];
        [server distributeDataWithWrappedTag:data fromClient:self withTimeout:standardTimeout tag:cookieTag];
        receivingCookiesData = nil;
    }
    
    else if (tag == windowQueryTag){ NSLog(@"Client %@ asked for windows.", name); [server sendWindowsToClient: self]; }
    else if (tag==nicknameTag){ name = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; NSLog(@"User changed nickname to %@", name); }
    else (NSLog(@"Socket %@ read data with an invalid tag! Tag is %ld", sock, tag));
    [socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag: connectedTag];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
  //  NSLog(@"Socket %@ wrote data.", sock);
}

@end

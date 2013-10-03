//
//  ClientSocket.m
//  SurfTeam
//
//  Created by Alec Zadikian on 10/2/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "ClientSocket.h"

@implementation ClientSocket
@synthesize inputStream, outputStream;
BOOL canRead = false;
NSMutableData* readBuffer;

-(id) init{
    self = [super init];
    if (self){
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.1.90", 23, &readStream, &writeStream); //change host connection here
        
        inputStream = (NSInputStream *)CFBridgingRelease(readStream);
        outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
        [inputStream setDelegate:self];
        [outputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
        
    }
    return self;
}

- (void)sendData: (NSData*) data withTag: (int) tag{
    NSMutableData* data2 = [[NSMutableData alloc] initWithData: data];
    [data2 appendBytes: &tag length:1]; //adding tag to END
	[outputStream write:[data2 bytes] maxLength:[data2 length]];
    DLog(@"Sent message to server: %@", [[NSString alloc] initWithData:data2 encoding:NSASCIIStringEncoding]);
}

- (NSData*)receiveDataWithTag: (int) tag{
    unsigned char *bytes = [readBuffer bytes];
    int receivedTag = &bytes[sizeof(bytes)-1];
    if (tag!=receivedTag){ NSLog(@"Received data, but it was of the wrong tag: %d", receivedTag); return nil; }
    //need to take tag off first... and if it does not match, it must not do anything!
    [readBuffer setLength: readBuffer.length-1];
    DLog(@"Received message from server %@ with tag %d", [[NSString alloc] initWithData:readBuffer encoding:NSASCIIStringEncoding], tag);
    canRead = NO;
    return readBuffer;
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            
            if (theStream == inputStream) {
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        readBuffer = [NSData dataWithBytes: buffer length: 1024];
                            DLog(@"Received data: %@", [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding] );
                        canRead = YES;
                    }
                }
            }
            break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
			break;
            
		default:
			NSLog(@"Unknown event");
	}
    
}


@end

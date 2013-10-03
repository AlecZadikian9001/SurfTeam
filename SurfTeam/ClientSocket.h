//
//  ClientSocket.h
//  SurfTeam
//
//  Created by Alec Zadikian on 10/2/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientSocket : NSThread <NSStreamDelegate>

@property (strong, nonatomic) NSInputStream* inputStream;
@property (strong, nonatomic) NSOutputStream* outputStream;

-(id) init;
-(void) sendMessage: (NSString*) message;

@end

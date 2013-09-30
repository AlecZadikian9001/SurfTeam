//
//  Server.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Server : NSObject

@property(strong, nonatomic) NSMutableArray* clientSockets;
@property(strong, nonatomic) NSString* password;

- (id) initWithPassword: (NSString*) pw;
- (void)distributeData: (NSData*) data fromUser: (int) userID;

@end

//
//  Server.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Server : NSWindowController

@property(strong, nonatomic) NSMutableArray* sockets; 

- (void)saveCookies;
- (void)loadCookies;
- (void)handleQuit;

@end

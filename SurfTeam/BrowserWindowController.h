//
//  BrowserWindowController.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"

@interface BrowserWindowController : NSWindowController

@property (strong, nonatomic) AsyncSocket* socket;

- (void)saveCookies;
- (void)loadCookies;

@end

//
//  BrowserWindowController.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BrowserWindowController : NSWindowController

- (void)saveCookies;
- (void)loadCookies;
- (void)handleQuit;

@end

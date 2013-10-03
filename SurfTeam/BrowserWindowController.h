//
//  BrowserWindowController.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
#import "Constants.h"
#import "StarterWindowController.h"

@interface BrowserWindowController : NSWindowController
//just the web browser window, can be online or offline!

@property (strong, nonatomic) StarterWindowController* starter;
@property (strong, nonatomic) NSString* owner;

- (void)saveCookies;
- (void)loadCookies;

@end

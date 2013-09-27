//
//  AppDelegate.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/25/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    WebHistory *myHistory = [[WebHistory alloc] init]; //TODO
    [WebHistory setOptionalSharedHistory:myHistory];
}

@end

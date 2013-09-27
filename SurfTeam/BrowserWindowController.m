//
//  BrowserWindowController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "BrowserWindowController.h"

@implementation BrowserWindowController

AsyncSocket *socket;
NSError *error;

- (void) init{
   socket = [[AsyncSocket alloc] init]; //fix this to use delegate
}

- (void)saveCookies
{
    NSData         *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    //must send this to other user
    NSUserDefaults *defaults    = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"cookies"];
    [defaults synchronize];
}

- (void)loadCookies
{
    NSArray             *cookies       = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"cookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        [cookieStorage setCookie: cookie];
    }
}

- (BOOL)connectToServer: (NSString) *address onPort: (int) port{
    if (![socket connectToHost: address onPort: port error: &error]) NSLog(@"Failed to connect to host %@: %@", address, error);
}

@end

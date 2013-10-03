//
//  BrowserWindowController.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/26/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "BrowserWindowController.h"

@implementation BrowserWindowController //also implements AsyncSocketDelegate. fix?
@synthesize starter, owner;

NSData *inData, *outData;
NSMutableData* cookieBuffer;
BOOL isControllable; //that is, if I own it

- (BrowserWindowController*) initWithStarter: (StarterWindowController*) st{
    self = [super init];
    if (self){
        starter = st;
    }
    return self;
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
[starter.socket
    readDataWithTimeout:standardTimeout
                  buffer:cookieBuffer
            bufferOffset:0
                     tag:cookieTag
];
}

@end

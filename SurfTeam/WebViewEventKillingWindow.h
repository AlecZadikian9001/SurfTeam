//
//  WebViewEventKillingWindow.h
//  SurfTeam
//
//  Created by Alec Zadikian on 10/18/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IGIsolatedCookieWebView.h"

@interface WebViewEventKillingWindow : NSWindow
@property (weak) IBOutlet IGIsolatedCookieWebView *webView;
@property (strong, nonatomic) NSNumber* shouldKill; //a boolean
@end

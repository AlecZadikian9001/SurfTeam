//
//  WebViewEventKillingWindow.h
//  SurfTeam
//
//  Created by Alec Zadikian on 10/18/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IGIsolatedCookieWebView.h"
#import "BrowserWindowController.h"

@class BrowserWindowController;
@interface WebViewEventKillingWindow : NSWindow
@property (weak) IBOutlet IGIsolatedCookieWebView *webView;
@property (weak, nonatomic) BrowserWindowController* controller;
@end

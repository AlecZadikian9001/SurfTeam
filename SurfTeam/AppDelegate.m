//
//  AppDelegate.m
//  SurfTeam
//
//  Created by Alec Zadikian on 9/25/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserWindowController.h"
#import "ServerConnectionViewController.h"

@implementation AppDelegate

WebHistory* history;
NSURL *applicationSupportURL, *historyFileURL;
ServerConnectionViewController* starter;
BrowserWindowController* browser;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportURL = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat: @"%@/SurfTeam/", [paths objectAtIndex:0]] isDirectory: YES];
    historyFileURL = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat: @"%@/SurfTeamHistory.txt", [applicationSupportURL path]] isDirectory: NO];
    NSLog(@"App support directory: '%@'", applicationSupportURL);
    NSLog(@"History file: '%@'", historyFileURL);
    [self initializeHistory];
    
    starter = [[ServerConnectionViewController alloc] initWithWindowNibName:@"ServerConnection"];
    [starter showWindow:nil];
    [starter.window makeKeyAndOrderFront:nil];

    browser = [[BrowserWindowController alloc] initWithWindowNibName:@"BrowserWindow"];
    [browser addStarter: starter overNetwork: NO];
    [browser showWindow:nil]; 
    [browser.window makeKeyAndOrderFront:nil];
    
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{
    NSLog(@"Saving history file to URL %@", historyFileURL);
    [history saveToURL:[[NSURL alloc] initFileURLWithPath: [historyFileURL path]] error:nil];
    return NSTerminateNow;
}

- (void)initializeHistory{
    history = [[WebHistory alloc] init];
    if (![history loadFromURL: historyFileURL error:nil]){
        NSError *error;
        NSLog(@"No existing history found... Making new one.");
        if (![[NSFileManager defaultManager] createDirectoryAtURL:applicationSupportURL
                                                     withIntermediateDirectories:NO
                                                    attributes:nil
                                                    error:&error])
            NSLog(@"Error while making application support directory!!! %@", error);
        if (![[NSFileManager defaultManager] createFileAtPath:[historyFileURL path]
                                                contents:nil
                                              attributes:nil])
            NSLog(@"Error while making history file!!!");
    }
    [WebHistory setOptionalSharedHistory:history];
    NSLog(@"All pages visited today: %@", [history orderedItemsLastVisitedOnDay:[NSDate date]]);
}

@end

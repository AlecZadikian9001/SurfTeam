//
//  StarterViewController.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/28/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "Constants.h"

@interface StarterWindowController : NSWindowController

//non-web UI for login and collab

-(id) initWithWindowNibName:(NSString *)windowNibName;

@end

//
//  Constants.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/30/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    invalidTag, //should never be used, just here to make 0 not valid
    negotiationTag, //for sending password
    clientMessageTag, //not used yet, maybe useful for collaborative features
    pageSourceTag, //for sending page source
   // cookieBeginTag, //not used anymore?
    cookieTag, //for sending cookies
   // cookieEndTag, //not used anymore?
    windowBeginTag, //sent before window info is sent, which should be every time a page is loaded
    windowEndTag, //sent after window info is sent
    urlTag, //for sending URL of page
    ownerTag, //for sending the owner of a window
    scrollPositionTag, //sending scroll position, should it change
    pulseTag, //not used yet, sent occasionally to keep TCP stream alive
    nicknameTag, //when client is sending nickname to server or server is asking for nickname
    windowQueryTag, //when client is asking server to ask other clients for windows or server is asking clients for windows
    separatorTag, //to make sure server and client are in sync (not very useful)
    
    firstTag, //not used like other tags, only used to identify within the server what kind of data is being listened for
    connectedTag //same here
} MessageTags;

typedef enum {
    defaultPort = 9000, //typical...
    standardTimeout = 10, //seconds before most communications are dropped
    negotiationTimeout = -1 //no timeout... should this be an exception to the standard timeout rule?
} Timeouts;
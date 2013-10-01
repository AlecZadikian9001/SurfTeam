//
//  Constants.h
//  SurfTeam
//
//  Created by Alec Zadikian on 9/30/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    negotiationTag,
    clientMessageTag,
    pageSourceTag,
    cookieTag,
    pulseTag
} MessageTags;

typedef enum {
    standardTimeout = 30,
    negotiationTimeout = -1
} Timeouts;
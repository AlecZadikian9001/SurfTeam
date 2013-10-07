//
//  browserWindowEssence.h
//  SurfTeam
//
//  Created by Alec Zadikian on 10/6/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrowserWindowEssence : NSObject

@property (strong, nonatomic) NSData* owner;
@property (strong, nonatomic) NSData* url;
@property (strong, nonatomic) NSData* html;
//need to add scroll position to this

@end

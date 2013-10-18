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
@property (strong, nonatomic) NSData* primeTag; //primetag = 2^(local ID)*3^(server ID)
@property (strong, nonatomic) NSData* url;
@property (strong, nonatomic) NSData* html;
@property (strong, nonatomic) NSData* scrollPosition;
@property (strong, nonatomic) NSData* dimensions;
//need to add scroll position to this

-(void) clear; //resets every variable except primeTag and owner
+(NSString*) stringFromData: (NSData*) data; //gets string from data

@end

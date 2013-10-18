//
//  browserWindowEssence.m
//  SurfTeam
//
//  Created by Alec Zadikian on 10/6/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "BrowserWindowEssence.h"

@implementation BrowserWindowEssence
@synthesize owner, url, scrollPosition, html, primeTag, dimensions;

-(void) clear{
    url = nil;
    html = nil;
    scrollPosition = nil;
    dimensions = nil;
}

+(NSString*) stringFromData: (NSData*) data{
    if (!data) return nil;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

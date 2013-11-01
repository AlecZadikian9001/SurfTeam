//
//  WebViewEventKillingWindow.m
//  SurfTeam
//
//  Created by Alec Zadikian on 10/18/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "WebViewEventKillingWindow.h"

@implementation WebViewEventKillingWindow
@synthesize webView, controller;
- (void)sendEvent:(NSEvent*)event
{
  //  NSLog(@"WebViewEventKillingWindow received an event. Shall it die?");
    NSView* hitView;
    if ([controller.isControllable boolValue]){
        [super sendEvent:event];
        switch ([event type]){
            case NSScrollWheel:
            case NSLeftMouseDown:
            case NSLeftMouseDragged:
                hitView = [webView hitTest:[event locationInWindow]];
                //if ([hitView isKindOfClass: [NSScroller class]]){
                [controller onScroll];
             //   }
                break;
                
            default: break;
        }
        return;
    }
    switch([event type])
    {
        //case NSScrollWheel:
        case NSKeyDown: break;
        case NSKeyUp: break;
        case NSLeftMouseDown: break;
        case NSLeftMouseUp: break;
        case NSRightMouseDragged: break;
        case NSMouseMoved: break;
        case NSRightMouseDown: break;
        case NSRightMouseUp: break;
        case NSLeftMouseDragged:
            hitView = [webView hitTest:[event locationInWindow]];
            if([hitView isDescendantOf:webView] &&
               !([hitView isKindOfClass:[NSScroller class]] ||
                 [hitView isKindOfClass:[NSScrollView class]]))
            {
                return;
            }
            break;
        default:
            break;
    }
    [super sendEvent:event];
}
@end

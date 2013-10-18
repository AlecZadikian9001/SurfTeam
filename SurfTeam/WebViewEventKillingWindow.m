//
//  WebViewEventKillingWindow.m
//  SurfTeam
//
//  Created by Alec Zadikian on 10/18/13.
//  Copyright (c) 2013 AlecZ. All rights reserved.
//

#import "WebViewEventKillingWindow.h"

@implementation WebViewEventKillingWindow
@synthesize webView, shouldKill;
- (void)sendEvent:(NSEvent*)event
{
    //NSLog(@"WebViewEventKillingWindow received an event. Shall it die?");
    if (!shouldKill || ![shouldKill boolValue]){ [super sendEvent:event]; return; }
    NSView* hitView;
    switch([event type])
    {
        //case NSScrollWheel:
        case NSKeyDown:
        case NSKeyUp:
        case NSLeftMouseDown:
        case NSLeftMouseUp:
        case NSLeftMouseDragged:
        case NSMouseMoved:
        case NSRightMouseDown:
        case NSRightMouseUp:
        case NSRightMouseDragged:
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

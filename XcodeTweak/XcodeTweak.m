//
//  XcodeTweak.m
//  XcodeTweak
//
//  Created by wuhaotian on 7/4/13.
//  Copyright (c) 2013 wuhaotian. All rights reserved.
//

#import "XcodeTweak.h"
#import "JRSwizzle.h"
#import <objc/objc-class.h>

@implementation XcodeTweak

+ (void)load
{
    
    NSError *error;
    
    if (![NSClassFromString(@"NSApplication") jr_swizzleMethod:@selector(sendEvent:) withMethod:@selector(XTSendEvent:) error:&error]) {
        
        NSLog(@"XcodeTweak: error %@", [error localizedDescription]);
        
    }
    NSLog(@"XcodeTweak loaded");

}

@end






@implementation NSApplication (XcodeTweak)

- (void)XTSendEvent:(NSEvent *)event
{
    static NSArray *keyCode2TabIndex = nil;
    
    if (event.type == NSKeyDown
        && (event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask) // only command modifier pressed
    {
        
        
        if (!keyCode2TabIndex)
        {
            keyCode2TabIndex = [[NSArray alloc] initWithObjects:@"18", @"19", @"20", @"21", @"23", @"22", @"26", @"28", @"25", nil];
        }
        
        NSUInteger tabIndex = [keyCode2TabIndex indexOfObject:[[NSNumber numberWithInt:event.keyCode] stringValue]];
        
        if (tabIndex != NSNotFound)
        {

            NSArray *array = [[NSApplication sharedApplication].keyWindow.contentView subviews];


            
            
            if (array.count && [array[0] respondsToSelector:@selector(numberOfTabViewItems)] // check safari API compat
                && [array[0] respondsToSelector:@selector(selectTabViewItemAtIndex:)])
            {
                NSView *tabSwitcher = array[0];

                NSInteger newTabIndex = -1;
                
                long long tabcount = (long long)[tabSwitcher performSelector:@selector(numberOfTabViewItems) withObject:nil];
                
                if (tabIndex == 8)
                {
                    newTabIndex = tabcount - 1;
                }
                else if (tabcount >= (tabIndex + 1))
                {
                    newTabIndex = tabIndex;
                }
                
                if (newTabIndex >= 0)
                {

                    [tabSwitcher performSelector:@selector(selectTabViewItemAtIndex:) withObject:(id)newTabIndex];
                }
                
                return; // prevent event dispatching
            }

        }
        
    }
//    else if (event.type == NSKeyDown
//             && (event.modifierFlags & NSDeviceIndependentModifierFlagsMask) == (NSCommandKeyMask|NSShiftKeyMask) && event.keyCode == 0x11) { // keycode of 'T'
//        
//        CGEventRef e = CGEventCreateKeyboardEvent(NULL, 0x6, YES); // keycode of 'Z'd
//        
//        CGEventSetFlags(e, kCGEventFlagMaskCommand);
//        
//        NSEvent *new_event = [NSEvent eventWithCGEvent:e];
//        
//        CFRelease(e);
//        
//        [self SafariTabeSwitching_sendEvent:new_event];
//        
//        return;
//    }
    

    [self XTSendEvent:event];
}

@end
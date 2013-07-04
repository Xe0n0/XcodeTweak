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
//#import "IDEWorkspaceWindowController.h"

void XTSelectTab(id self, SEL _cmd, id arg)
{
    NSLog(@"%@", arg);

    NSLog(@"%@", [arg superview]) ;
}

@implementation XcodeTweak

+ (void)load
{
    
    NSError *error;
    
    if (![NSClassFromString(@"NSApplication") jr_swizzleMethod:@selector(sendEvent:) withMethod:@selector(XTSendEvent:) error:&error]) {
        
        NSLog(@"XcodeTweak: error %@", [error localizedDescription]);
        
    }
    class_addMethod(NSClassFromString(@"IDEWorkspaceWindowController"), @selector(XTSelectTab:), (IMP)XTSelectTab, "v@:");
    [NSClassFromString(@"IDEWorkspaceWindowController") jr_swizzleMethod:@selector(selectTab:) withMethod:@selector(XTSelectTab:) error:&error];
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
            NSViewController *vc = [NSApplication sharedApplication].keyWindow.windowController;

            
            if ([vc respondsToSelector:@selector(orderedTabViewItems)] // check safari API compat
                && [vc respondsToSelector:@selector(selectTab:)])
            {
                NSArray *tabs = [vc performSelector:@selector(orderedTabViewItems)];
                NSInteger newTabIndex = -1;
                NSLog(@"%@", tabs);
                if (tabIndex == 8)
                {
                    newTabIndex = tabs.count - 1;
                }
                else if (tabs.count >= (tabIndex + 1))
                {
                    newTabIndex = tabIndex;
                }
                
                if (newTabIndex >= 0)
                {
                    NSObject *tab = tabs[newTabIndex];
                    NSLog(@"%@", tab);
                    [vc performSelector:@selector(selectTab:) withObject:tab];
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
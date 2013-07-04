//
//  XcodeTweak.m
//  XcodeTweak
//
//  Created by wuhaotian on 7/4/13.
//  Copyright (c) 2013 wuhaotian. All rights reserved.
//

#import "XcodeTweak.h"
#import "JRSwizzle.h"

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

        
    [self XTSendEvent:event];
}

@end
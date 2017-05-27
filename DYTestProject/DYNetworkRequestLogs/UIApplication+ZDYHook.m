//
//  UIApplication+ZDYHook.m
//  SimpResearch
//
//  Created by ZeroDY on 2017/5/15.
//  Copyright © 2017年 上海美市科技有限公司. All rights reserved.
//

#import "UIApplication+ZDYHook.h"
#import <objc/runtime.h>

@implementation UIApplication (ZDYHook)

+ (void)hookUIApplication
{
    Method controlMethod = class_getInstanceMethod([UIApplication class], @selector(sendAction:to:from:forEvent:));
    Method hookMethod = class_getInstanceMethod([self class], @selector(hook_sendAction:to:from:forEvent:));
    method_exchangeImplementations(controlMethod, hookMethod);
}


- (BOOL)hook_sendAction:(SEL)action to:(nullable id)target from:(nullable id)sender forEvent:(nullable UIEvent *)event;
{
    NSString *actionDetailInfo = [NSString stringWithFormat:@" %@ - %@ - %@", NSStringFromClass([target class]), NSStringFromClass([sender class]), NSStringFromSelector(action)];
    NSLog(@"%@", actionDetailInfo);
    return [self hook_sendAction:action to:target from:sender forEvent:event];
}

@end

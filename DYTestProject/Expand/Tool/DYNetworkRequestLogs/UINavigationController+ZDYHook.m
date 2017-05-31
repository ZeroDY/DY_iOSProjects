//
//  UINavigationController+ZDYHook.m
//  SimpResearch
//
//  Created by ZeroDY on 2017/5/15.
//  Copyright © 2017年 上海美市科技有限公司. All rights reserved.
//

#import "UINavigationController+ZDYHook.h"
#import <objc/runtime.h>

@implementation UINavigationController (ZDYHook)

+ (void)hookUINavigationController_push
{
    Method pushMethod = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    Method hookMethod = class_getInstanceMethod([self class], @selector(hook_pushViewController:animated:));
    method_exchangeImplementations(pushMethod, hookMethod);
}


- (void)hook_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSString *popDetailInfo = [NSString stringWithFormat: @"%@ - %@ - %@", NSStringFromClass([self class]), @"push", NSStringFromClass([viewController class])];
    NSLog(@"%@", popDetailInfo);
    [self hook_pushViewController:viewController animated:animated];
}


+ (void)hookUINavigationController_pop
{
    Method popMethod = class_getInstanceMethod([self class], @selector(popViewControllerAnimated:));
    Method hookMethod = class_getInstanceMethod([self class], @selector(hook_popViewControllerAnimated:));
    method_exchangeImplementations(popMethod, hookMethod);
}


- (void)hook_popViewControllerAnimated:(BOOL)animated
{
    NSString *popDetailInfo = [NSString stringWithFormat:@"%@ - %@", NSStringFromClass([self class]), @"pop"];
    NSLog(@"%@", popDetailInfo);
    [self hook_popViewControllerAnimated:animated];
}

@end

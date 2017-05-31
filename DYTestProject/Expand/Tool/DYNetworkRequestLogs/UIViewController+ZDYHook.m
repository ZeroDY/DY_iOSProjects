//
//  UIViewController+ZDYHook.m
//  SimpResearch
//
//  Created by ZeroDY on 2017/5/15.
//  Copyright © 2017年 上海美市科技有限公司. All rights reserved.
//

#import "UIViewController+ZDYHook.h"
#import <objc/runtime.h>
#import "SRRequestLogFM.h"

@implementation UIViewController (ZDYHook)

+ (void)hookUIViewController
{
    Method loadMethod = class_getInstanceMethod([self class], @selector(loadView));
    Method hookLoadMethod = class_getInstanceMethod([self class], @selector(hook_loadView));
    method_exchangeImplementations(loadMethod, hookLoadMethod);
    
    
    Method didLoadMethod = class_getInstanceMethod([self class], @selector(viewDidLoad));
    Method hookDidLoadMethod = class_getInstanceMethod([self class], @selector(hook_viewDidLoad));
    method_exchangeImplementations(didLoadMethod, hookDidLoadMethod);
    
    
    Method willAppearMethod = class_getInstanceMethod([self class], @selector(viewWillAppear:));
    Method hookWillAppearMethod = class_getInstanceMethod([self class], @selector(hook_viewWillAppear:));
    method_exchangeImplementations(willAppearMethod, hookWillAppearMethod);
    
    
    Method appearMethod = class_getInstanceMethod([self class], @selector(viewDidAppear:));
    Method hookMethod = class_getInstanceMethod([self class], @selector(hook_ViewDidAppear:));
    method_exchangeImplementations(appearMethod, hookMethod);
    
    Method willDisappearMethod = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
    Method hookwillDisappearMethod = class_getInstanceMethod([self class], @selector(hook_viewWillDisappear:));
    method_exchangeImplementations(willDisappearMethod, hookwillDisappearMethod);

    Method layoutSubviewsMethod = class_getInstanceMethod([self class], @selector(viewWillLayoutSubviews));
    Method hookLayoutSubviewsMethod = class_getInstanceMethod([self class], @selector(hook_viewWillLayoutSubviews));
    method_exchangeImplementations(layoutSubviewsMethod, hookLayoutSubviewsMethod);
    
}

- (void)hook_loadView{
    NSString *appearDetailInfo = [NSString stringWithFormat:@" %@**********************%@", NSStringFromClass([self class]), @"hook_loadView"];
    NSLog(@"%@", appearDetailInfo);
    [SRRequestLogFM shareInstance].controllerName = NSStringFromClass([self class]);
    [SRRequestLogFM shareInstance].loadTime = [UIViewController getRequestLogTime];
//    [SRRequestLogFM insertControllerLog];
    
    [self hook_loadView];
}

- (void)hook_viewDidLoad{
//    if([SRRequestLogFM shareInstance].controllerName &&
//       [[SRRequestLogFM shareInstance].controllerName isEqualToString:NSStringFromClass([self class])]){
//        NSString *appearDetailInfo = [NSString stringWithFormat:@" %@**********************%@", NSStringFromClass([self class]), @"hook_viewDidLoad"];
//        NSLog(@"%@", appearDetailInfo);
//        [SRRequestLogFM shareInstance].didloadTime = [UIViewController getRequestLogTime] - [SRRequestLogFM shareInstance].loadTime;
//    }
    
    
    [self hook_viewDidLoad];
}

- (void)hook_viewWillAppear:(BOOL)animated{
    if([SRRequestLogFM shareInstance].controllerName &&
       [[SRRequestLogFM shareInstance].controllerName isEqualToString:NSStringFromClass([self class])]){
        NSString *appearDetailInfo = [NSString stringWithFormat:@" %@**********************%@", NSStringFromClass([self class]), @"hook_viewWillAppear"];
        NSLog(@"%@", appearDetailInfo);
        [SRRequestLogFM shareInstance].didloadTime = [UIViewController getRequestLogTime] - [SRRequestLogFM shareInstance].loadTime;
    }
    
    
    [self hook_viewWillAppear:animated];
}

- (void)hook_ViewDidAppear:(BOOL)animated
{
//    if([SRRequestLogFM shareInstance].controllerName &&
//       [[SRRequestLogFM shareInstance].controllerName isEqualToString:NSStringFromClass([self class])]){
//        NSString *appearDetailInfo = [NSString stringWithFormat:@" %@**********************%@", NSStringFromClass([self class]), @"hook_ViewDidAppear"];
//        NSLog(@"%@", appearDetailInfo);
//        [SRRequestLogFM shareInstance].didappearTime = [UIViewController getRequestLogTime];
//    }
//    
//    
    [self hook_ViewDidAppear:animated];
}

- (void)hook_viewWillLayoutSubviews{
    if( [SRRequestLogFM shareInstance].controllerName &&
       [[SRRequestLogFM shareInstance].controllerName isEqualToString:NSStringFromClass([self class])]){
        NSString *appearDetailInfo = [NSString stringWithFormat:@" %@**********************%@", NSStringFromClass([self class]), @"hook_viewWillLayoutSubviews"];
        NSLog(@"%@", appearDetailInfo);
        [SRRequestLogFM shareInstance].didappearTime = [UIViewController getRequestLogTime] - [SRRequestLogFM shareInstance].didloadTime    ;
    }
    
    [self hook_viewWillLayoutSubviews];
}

- (void)hook_viewWillDisappear:(BOOL)animated{
    
    NSLog(@"**********************************");
    
    
    if([SRRequestLogFM shareInstance].controllerName &&
       [[SRRequestLogFM shareInstance].controllerName isEqualToString:NSStringFromClass([self class])]){
        NSLog(@"√√√√√√√√√√√√√√√√√√√√√√√√√√√√√√√√√√√√√ --- %@ -- %f",[SRRequestLogFM shareInstance].controllerName,[SRRequestLogFM shareInstance].loadTime);
//        [SRRequestLogFM updateControllerLog];
        [SRRequestLogFM shareInstance].controllerName = nil;
        [SRRequestLogFM shareInstance].refreshNum = 0;
        [SRRequestLogFM shareInstance].loadTime = 0;
        [SRRequestLogFM shareInstance].didloadTime = 0;
        [SRRequestLogFM shareInstance].didappearTime = 0;
    }else{
        NSLog(@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    }
    
    
    [self hook_viewWillDisappear:animated];
    
}

+ (CGFloat)getRequestLogTime{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    return [date timeIntervalSince1970] * 1000;
}



@end

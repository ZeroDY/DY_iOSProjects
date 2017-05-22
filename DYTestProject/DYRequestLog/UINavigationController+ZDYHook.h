//
//  UINavigationController+ZDYHook.h
//  SimpResearch
//
//  Created by ZeroDY on 2017/5/15.
//  Copyright © 2017年 上海美市科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (ZDYHook)

+ (void)hookUINavigationController_push;

+ (void)hookUINavigationController_pop;

@end

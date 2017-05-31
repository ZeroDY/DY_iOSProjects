//
//  AppDelegate.h
//  DYTestProject
//
//  Created by ZeroDY on 2017/5/19.
//  Copyright © 2017年 ZeroDY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end


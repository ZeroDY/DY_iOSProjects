//
//  SRRequestLogFM.m
//  SimpResearch
//
//  Created by ZeroDY on 2017/5/17.
//  Copyright © 2017年 上海美市科技有限公司. All rights reserved.
//

#import "SRRequestLogFM.h"
#import <FMDatabase.h>
#import "UIViewController+ZDYHook.h"

@interface SRRequestLogFM ()


@end

static SRRequestLogFM *_instance = nil;

@implementation SRRequestLogFM


+ (instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}


#pragma mark 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    // 定义一个变量存放当前屏幕显示的viewcontroller
    UIViewController *result = nil;
    
    // 得到当前应用程序的关键窗口（正在活跃的窗口）
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    
    // windowLevel是在 Z轴 方向上的窗口位置，默认值为UIWindowLevelNormal
    if (window.windowLevel != UIWindowLevelNormal)
    {
        // 获取应用程序所有的窗口
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            // 找到程序的默认窗口（正在显示的窗口）
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                // 将关键窗口赋值为默认窗口
                window = tmpWin;
                break;
            }
        }
    }
    // 获取窗口的当前显示视图
    UIView *frontView = [[window subviews] objectAtIndex:0];
    
    // 获取视图的下一个响应者，UIView视图调用这个方法的返回值为UIViewController或它的父视图
    id nextResponder = [frontView nextResponder];
    
    // 判断显示视图的下一个响应者是否为一个UIViewController的类对象
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    return result;
}

+ (void)insertRequestControllerLogWithURL:(NSString *)url
                                beginTime:(CGFloat)beginTime
                              networkTime:(CGFloat)networkTime
                             decodingTime:(CGFloat)decodingTime
                                  allTime:(CGFloat)allTime
                                 dataSize:(NSString *)dataSize
                               dataLength:(NSUInteger)dataLength
                              networkType:(NSString *)networkType
                               controller:(NSString *)controllerName
{
//    if ([SRRequestLogFM shareInstance].controllerName && [controllerName isEqualToString:[SRRequestLogFM shareInstance].controllerName]) {
        // 获取Documents路径
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *sqlPath = [docPath stringByAppendingPathComponent:@"RequestLogDB.sqlite"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:sqlPath]) {
            NSString *sourcesPath = [[NSBundle mainBundle] pathForResource:@"RequestLogDB" ofType:@"sqlite"];
            NSError *error ;
            if ([fileManager copyItemAtPath:sourcesPath toPath:sqlPath error:&error]) {
                NSLog(@"数据库移动成功");
            } else {
                NSLog(@"%@", error);
            }
        }
        
        FMDatabase *db = [FMDatabase databaseWithPath:sqlPath];
        if ([db open])
        {
            [SRRequestLogFM shareInstance].refreshNum++;
            [db executeUpdate:@"INSERT INTO C_R_Logs_T (r_url, r_beginTime, r_networkTime, r_decodingTime, r_allTime, r_dataSize, r_dataLength, networkType, c_name, c_refreshNum, c_loadTime, c_didloadTime, c_didappearTime) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?);",
             url,
             @(beginTime),
             @(networkTime),
             @(decodingTime),
             @(allTime),
             dataSize,
             @(dataLength),
             networkType,
             [SRRequestLogFM shareInstance].controllerName,
             @([SRRequestLogFM shareInstance].refreshNum),
             @([SRRequestLogFM shareInstance].loadTime),
             @([SRRequestLogFM shareInstance].didloadTime),
             @([SRRequestLogFM shareInstance].didappearTime)]
             ;
            
            
            [db close];
        }
//    }
}

//+ (void)insertRequestLogWithURL:(NSString *)url
//                      beginTime:(CGFloat)beginTime
//                     finishTime:(CGFloat)finishTime
//                       dataSize:(NSString *)dataSize
//                     dataLength:(NSUInteger)dataLength
//                    networkType:(NSString *)networkType
//                     controller:(NSString *)controllerName{
//    
//    if ([SRRequestLogFM shareInstance].controllerID && [controllerName isEqualToString:[SRRequestLogFM shareInstance].controller]) {
//        // 获取Documents路径
//        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        NSString *sqlPath = [docPath stringByAppendingPathComponent:@"RequestLogDB.sqlite"];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        if (![fileManager fileExistsAtPath:sqlPath]) {
//            NSString *sourcesPath = [[NSBundle mainBundle] pathForResource:@"RequestLogDB" ofType:@"sqlite"];
//            NSError *error ;
//            if ([fileManager copyItemAtPath:sourcesPath toPath:sqlPath error:&error]) {
//                NSLog(@"数据库移动成功");
//            } else {
//                NSLog(@"%@", error);
//            }
//        }
//        
//        FMDatabase *db = [FMDatabase databaseWithPath:sqlPath];
//        if ([db open])
//        {
//            CGFloat intervalTime = finishTime - beginTime;
//            NSString *dataLengthStr = [NSString stringWithFormat:@"%ld",dataLength];
//            
//            [db executeUpdate:@"INSERT INTO R_Logs (controllerID, controller, url, beginTime, finishTime, intervalTime, dataSize, dataLength, networkType) VALUES (?,?,?,?,?,?,?,?,?);",
//             @([SRRequestLogFM shareInstance].controllerID),
//             [SRRequestLogFM shareInstance].controller,
//             url,
//             @(beginTime),
//             @(finishTime),
//             @(intervalTime),
//             dataSize,
//             dataLengthStr,
//             networkType ];
//            
//            [db close];
//        }
//    }
//
//}
//
//+ (void)insertControllerLog{
//
//    if ([SRRequestLogFM shareInstance].controller) {
//        // 获取Documents路径
//        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        NSString *sqlPath = [docPath stringByAppendingPathComponent:@"RequestLogDB.sqlite"];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        if (![fileManager fileExistsAtPath:sqlPath]) {
//            NSString *sourcesPath = [[NSBundle mainBundle] pathForResource:@"RequestLogDB" ofType:@"sqlite"];
//            NSError *error ;
//            if ([fileManager copyItemAtPath:sourcesPath toPath:sqlPath error:&error]) {
//                NSLog(@"数据库移动成功");
//            } else {
//                NSLog(@"%@", error);
//            }
//        }
//        
//        FMDatabase *db = [FMDatabase databaseWithPath:sqlPath];
//        if ([db open])
//        {
//            if([db executeUpdate: @"INSERT INTO C_Logs (controller, loadTime) VALUES (?,?);",
//                [SRRequestLogFM shareInstance].controller,  @([SRRequestLogFM shareInstance].loadTime)]){
//                FMResultSet *resultSet = [db executeQuery:@"SELECT controllerID FROM C_Logs WHERE loadTime=?;",@([SRRequestLogFM shareInstance].loadTime)];
//                while ([resultSet  next])
//                {
//                    [SRRequestLogFM shareInstance].controllerID = [resultSet intForColumn:@"controllerID"];
//                    NSLog(@"-------------  ^^^^^^^^^^ -----------  %ld",[SRRequestLogFM shareInstance].controllerID);
//                }
//            };
//            [db close];
//        }
//    }
//}
//+ (void)updateControllerLog{
//    [SRRequestLogFM updateControllerLog:[SRRequestLogFM shareInstance].controllerID
//                            didloadTime:[SRRequestLogFM shareInstance].didloadTime
//                         willappearTime:[SRRequestLogFM shareInstance].willappearTime
//                          didappearTime:[SRRequestLogFM shareInstance].didappearTime
//                             finishTime:[SRRequestLogFM shareInstance].finishTime];
//}
//
//
//+ (void)updateControllerLog:(NSUInteger)controllerID
//                didloadTime:(CGFloat)didloadTime
//             willappearTime:(CGFloat)willappearTime
//              didappearTime:(CGFloat)didappearTime
//                 finishTime:(CGFloat)finishTime
//{
//    
//    if ([SRRequestLogFM shareInstance].controllerID) {
//        // 获取Documents路径
//        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        NSString *sqlPath = [docPath stringByAppendingPathComponent:@"RequestLogDB.sqlite"];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        if (![fileManager fileExistsAtPath:sqlPath]) {
//            NSString *sourcesPath = [[NSBundle mainBundle] pathForResource:@"RequestLogDB" ofType:@"sqlite"];
//            NSError *error ;
//            if ([fileManager copyItemAtPath:sourcesPath toPath:sqlPath error:&error]) {
//                NSLog(@"数据库移动成功");
//            } else {
//                NSLog(@"%@", error);
//            }
//        }
//        
//        FMDatabase *db = [FMDatabase databaseWithPath:sqlPath];
//        if ([db open])
//        {
//            if([db executeUpdate: @"UPDATE C_Logs SET didloadTime=?,  willappearTime=?, didappearTime=?, finishTime=? WHERE controllerID=?;",
//                 @(didloadTime),  @(willappearTime), @(didappearTime), @(finishTime)], @(controllerID)){
//                
//                NSLog(@"------------- %@  ^^^^^^^^^^ -----------  UPDATE C_Logs SET didloadTime=%f,  willappearTime=%f, didappearTime=%f, finishTime=%f WHERE controllerID=%ld;" ,[SRRequestLogFM shareInstance].controller, didloadTime,  willappearTime, didappearTime, finishTime, controllerID);
//            };
//            [db close];
//        }
//    }
//}

@end

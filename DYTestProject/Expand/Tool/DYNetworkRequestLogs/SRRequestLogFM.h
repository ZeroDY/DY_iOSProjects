//
//  SRRequestLogFM.h
//  SimpResearch
//
//  Created by ZeroDY on 2017/5/17.
//  Copyright © 2017年 上海美市科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRRequestLogFM : NSObject


@property (nonatomic, copy) NSString *controllerName;

@property (nonatomic, assign) NSInteger refreshNum;

@property (nonatomic, assign) CGFloat loadTime;

@property (nonatomic, assign) CGFloat didloadTime;

@property (nonatomic, assign) CGFloat didappearTime;

+ (void)insertRequestControllerLogWithURL:(NSString *)url
                                beginTime:(CGFloat)beginTime
                              networkTime:(CGFloat)networkTime
                             decodingTime:(CGFloat)decodingTime
                                  allTime:(CGFloat)allTime
                                 dataSize:(NSString *)dataSize
                               dataLength:(NSUInteger)dataLength
                              networkType:(NSString *)networkType
                               controller:(NSString *)controllerName;



//@property (nonatomic, assign) NSUInteger controllerID;
//
//@property (nonatomic, copy) NSString *controller;
//
//@property (nonatomic, assign) CGFloat loadTime;
//
//@property (nonatomic, assign) CGFloat didloadTime;
//
//@property (nonatomic, assign) CGFloat willappearTime;
//
//@property (nonatomic, assign) CGFloat didappearTime;
//
//@property (nonatomic, assign) CGFloat finishTime;

//+ (void)insertRequestLogWithURL:(NSString *)url
//                      beginTime:(CGFloat)beginTime
//                     finishTime:(CGFloat)finishTime
//                       dataSize:(NSString *)dataSize
//                     dataLength:(NSUInteger)dataLength
//                    networkType:(NSString *)networkType
//                     controller:(NSString *)controllerName;
//
//+ (void)insertControllerLog;
//
//+ (void)updateControllerLog;

+ (instancetype) shareInstance;



@end

//
//  SRRequestLog.h
//  SimpResearch
//
//  Created by ZeroDY on 2017/5/16.
//  Copyright © 2017年 上海美市科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRRequestLog : NSObject

+ (void)insertStudentWithURL:(NSString *)url
                   beginTime:(CGFloat)beginTime
                  finishTime:(CGFloat)finishTime
                    dataSize:(NSString *)dataSize
                  dataLength:(NSUInteger)dataLength
                 networkType:(NSString *)networkType;

@end

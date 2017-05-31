//
//  SRRequestLog.m
//  SimpResearch
//
//  Created by ZeroDY on 2017/5/16.
//  Copyright © 2017年 上海美市科技有限公司. All rights reserved.
//

#import "SRRequestLog.h"
#import <sqlite3.h>
#import <FMDatabase.h>

@implementation SRRequestLog

// 创建数据库指针
static sqlite3 *db = nil;



// 打开数据库
+ (sqlite3 *)open {
    
    // 此方法的主要作用是打开数据库
    // 返回值是一个数据库指针
    // 因为这个数据库在很多的SQLite API（函数）中都会用到，我们声明一个类方法来获取，更加方便
    
    // 懒加载
    if (db != nil) {
        return db;
    }
    
    // 获取Documents路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject];
    
    // 生成数据库文件在沙盒中的路径
    NSString *sqlPath = [docPath stringByAppendingPathComponent:@"RequestLogDB.sqlite"];
    
    // 创建文件管理对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 判断沙盒路径中是否存在数据库文件，如果不存在才执行拷贝操作，如果存在不在执行拷贝操作
    if ([fileManager fileExistsAtPath:sqlPath] == NO) {
        // 获取数据库文件在包中的路径
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"RequestLogDB" ofType:@"sqlite"];
        
        // 使用文件管理对象进行拷贝操作
        // 第一个参数是拷贝文件的路径
        // 第二个参数是将拷贝文件进行拷贝的目标路径
        [fileManager copyItemAtPath:filePath toPath:sqlPath error:nil];
        
    }
    
    // 打开数据库需要使用一下函数
    // 第一个参数是数据库的路径（因为需要的是C语言的字符串，而不是NSString所以必须进行转换）
    // 第二个参数是指向指针的指针
    sqlite3_open([sqlPath UTF8String], &db);
    
    return db;
}

// 关闭数据库
+ (void)close {
    
    // 关闭数据库
    sqlite3_close(db);
    
    // 将数据库的指针置空
    db = nil;
    
}


// 插入一条记录
+ (void)insertStudentWithURL:(NSString *)url
                   beginTime:(CGFloat)beginTime
                  finishTime:(CGFloat)finishTime
                    dataSize:(NSString *)dataSize
                  dataLength:(NSUInteger)dataLength
                 networkType:(NSString *)networkType{
    
    // 打开数据库
    sqlite3 *db = [self open];
    
    sqlite3_stmt *stmt = nil;
    
    int result = sqlite3_prepare_v2(db, "insert into Logs values(?,?,?,?,?,?,?)", -1, &stmt, nil);
    
    if (result == SQLITE_OK) {
        CGFloat intervalTime = finishTime - beginTime;
        NSString *dataLengthStr = [NSString stringWithFormat:@"%ld",dataLength];
        // 绑定
//        sqlite3_bind_double(stmt, 1, [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]);
        sqlite3_bind_text(stmt, 2, [url UTF8String], -1, nil);
        sqlite3_bind_double(stmt, 3, beginTime);
        sqlite3_bind_double(stmt, 4, finishTime);
        sqlite3_bind_double(stmt, 5, intervalTime);
        sqlite3_bind_text(stmt, 6, [dataSize UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 7, [dataLengthStr UTF8String], -1, nil);
        sqlite3_bind_text(stmt, 8, [networkType UTF8String], -1, nil);
        
        // 插入与查询不一样，执行结果没有返回值
        sqlite3_step(stmt);
        
    }
    
    // 释放语句对象
    sqlite3_finalize(stmt);
    
    [self close];
}


// 获取表中保存的所有
+ (NSArray *)allStudents {
    
    // 打开数据库
    sqlite3 *db = [self open];
    
    // 创建一个语句对象
    sqlite3_stmt *stmt = nil;
    
    // 声明数组对象
    NSMutableArray *mArr = nil;
    
    // 此函数的作用是生成一个语句对象，此时sql语句并没有执行，创建的语句对象，保存了关联的数据库，执行的sql语句，sql语句的长度等信息
    int result = sqlite3_prepare_v2(db, "select * from Logs", -1, &stmt, nil);
    if (result == SQLITE_OK) {
        
        // 为数组开辟空间
        mArr = [NSMutableArray arrayWithCapacity:0];
        
        // SQLite_ROW仅用于查询语句，sqlite3_step()函数执行后的结果如果是SQLite_ROW，说明结果集里面还有数据，会自动跳到下一条结果，如果已经是最后一条数据，再次执行sqlite3_step()，会返回SQLite_DONE，结束整个查询
        while (sqlite3_step(stmt) == SQLITE_ROW) {

            // 获取记录中的字段值
            // 第一个参数是语句对象，第二个参数是字段的下标，从0开始
            int ID = sqlite3_column_int(stmt, 0);
            const unsigned char *curl = sqlite3_column_text(stmt, 1);
            double beginTime = sqlite3_column_double(stmt, 2);
            double finishTime = sqlite3_column_double(stmt, 3);
            double intervalTime = sqlite3_column_double(stmt, 4);
            const unsigned char *cdataSize = sqlite3_column_text(stmt, 5);
            const unsigned char *cdataLength = sqlite3_column_text(stmt, 6);
            const unsigned char *cnetType = sqlite3_column_text(stmt, 7);
            
            // 将获取到的C语言字符串转换成OC字符串
            NSString *url = [NSString stringWithUTF8String:(const char *)curl];
            NSString *dataSize = [NSString stringWithUTF8String:(const char *)cdataSize];
            NSString *dataLength = [NSString stringWithUTF8String:(const char *)cdataLength];
            NSString *networkType = [NSString stringWithUTF8String:(const char *)cnetType];

    
            NSLog(@"%d - %@ - %f - %f - %f - %@ - %@ - %@ ",
                  ID, url, beginTime, finishTime, intervalTime, dataSize, dataLength, networkType);
        }
    }
    
    // 关闭数据库
    sqlite3_finalize(stmt);
    
    return mArr;
    
}

@end

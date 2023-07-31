//
//  YMNetConnect.h
//  YMTool
//
//  Created by 海南有趣 on 2020/5/11.
//  Copyright © 2020 huangyuzhou. All rights reserved.
//

#import <Foundation/Foundation.h>


/// 监测connect命令的的输出到日志变量
@protocol YMNetConnectDelegate <NSObject>

- (void)ymConnectAverage:(long)avarage;

- (void)ymConnectLog:(NSString *)socketLog;

- (void)ymConnectDidEnd:(BOOL)success;

@end

@interface YMNetConnect : NSObject

@property (nonatomic, weak) id<YMNetConnectDelegate> delegate;


/// 通过hostaddress和port 进行connect诊断
/// @param host IP地址
/// @param port 端口
- (void)runWithHostAddress:(NSString *)host
                      port:(int)port;

/// 停止connect
- (void)stopConnect;

@end


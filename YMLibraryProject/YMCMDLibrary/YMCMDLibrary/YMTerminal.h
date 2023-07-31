//
//  YMTerminal.h
//  ToDeskTest
//
//  Created by 黄玉洲 on 2022/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YMTerminal : NSObject

/// 开始终端操作
- (bool)startTerminal;

/// 停止终端操作
- (void)stopTerminal;

/// 执行命令
/// @param command 执行命令
- (void)runCommand:(NSString *)command;

@property (nonatomic, copy) void (^terminationHandler)(YMTerminal *terminal); // 终止回调
@property (nonatomic, copy) void (^commandOutputHandler)(NSString *output); // 输出回调

@end

NS_ASSUME_NONNULL_END

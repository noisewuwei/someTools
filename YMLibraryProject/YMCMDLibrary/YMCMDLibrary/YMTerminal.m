//
//  YMTerminal.m
//  ToDeskTest
//
//  Created by 黄玉洲 on 2022/8/23.
//

#import "YMTerminal.h"
#include <util.h>
@interface YMTerminal ()
{
    
    NSTask *task;
    NSFileHandle * _masterHandle, * _slaveHandle;
    NSPipe * _errorOutputPipe;
    
    
    NSString *nid;
    
    int _isLaunch;
    NSUInteger _existenceLength;
    NSUInteger _totalLength;
    
    void (^readHandler)(NSFileHandle *);
    BOOL readsEnabled;
}

/// 停止终端操作
- (void)stopTerminal;

/// 执行命令
- (void)runCommand:(NSString *)str;

@end

@implementation YMTerminal

- (void)dealloc {
    [self stopTerminal];
}

/// 开始终端操作
- (bool)startTerminal {
    _isLaunch = 0;
    _existenceLength = 0;
    _totalLength = 0;
    
    task = [NSTask new];
    NSDictionary *environment = [NSProcessInfo processInfo].environment;
    NSString *homePath = environment[@"HOME"];
    if (homePath) {
        task.currentDirectoryPath = homePath;
    }
    
    _isLaunch = 1;
    int amaster = 0, aslave = 0;
    if (openpty(&amaster, &aslave, NULL, NULL, NULL) == -1) {
        return false;
    }
    
    _masterHandle = [[NSFileHandle alloc] initWithFileDescriptor:amaster closeOnDealloc:YES];
    _slaveHandle = [[NSFileHandle alloc] initWithFileDescriptor:aslave closeOnDealloc:YES];
    
    NSMutableDictionary * mutableEnvironment = [NSProcessInfo processInfo].environment.mutableCopy;
    mutableEnvironment[@"TERM"] = @"dumb";
    
    task.launchPath = @"/bin/zsh";
    task.arguments = @[@"-i", @"-l"];
    task.environment = mutableEnvironment;
    
    task.standardInput = _slaveHandle;
    task.standardOutput = _slaveHandle;
    task.standardError = _errorOutputPipe = [NSPipe pipe];
    
    
    // 执行结果回调
    __weak __typeof(self) weakSelf = self;
    readHandler = ^(NSFileHandle *handle) {
        NSData *data = handle.availableData;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self receivedData:data];
        });
    };

    // 进程销毁回调
    task.terminationHandler = ^(NSTask *task){
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self stopTerminal];
            if (self.terminationHandler != nil) {
                self.terminationHandler(self);
            }
        });
    };
    
    [self enableReads:YES];
    [task launch];
    return true;
}

/// 停止终端操作
- (void)stopTerminal {
    if (_isLaunch == 1) {
        [_masterHandle closeFile];
        [_slaveHandle closeFile];
        [_errorOutputPipe.fileHandleForReading closeFile];
        [_errorOutputPipe.fileHandleForWriting closeFile];
        [task terminate];
        _isLaunch = 0;
    }
}

/// 执行命令
- (void)runCommand:(NSString *)command {
    if (command.length > 0) {
        _existenceLength = command.length;
        _totalLength = 0;
        
        if (![command hasSuffix:@"\n"]) {
            command = [command stringByAppendingString:@"\n"];
        }
        [_masterHandle writeData:[command dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

/// 启用命令结果读取
/// @param enable 是否启用
- (void)enableReads:(BOOL)enable {
    if (enable && !readsEnabled) {
        _masterHandle.readabilityHandler = readHandler;
        _errorOutputPipe.fileHandleForReading.readabilityHandler = readHandler;
        readsEnabled = YES;
    } else if (!enable && readsEnabled) {
        _masterHandle.readabilityHandler = nil;
        _errorOutputPipe.fileHandleForReading.readabilityHandler = nil;
        readsEnabled = NO;
    }
}

#pragma mark - I/O Helpers
/// 接收执行输出
/// @param data 输出
- (void)receivedData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // 处理@"%                                                                              \r \r"字符串
    if ([self matchPredicate:@"^%[\\s]{5,}[\\r]{1}[\\s]{1,}[\\r]{1}$" forContent:string]) {
        return;
    }
    
    string = [string stringByReplacingOccurrencesOfString:@"[?2004h" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[?2004l" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    if ([[string stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"%"]) {
        string = [string stringByReplacingOccurrencesOfString:@"%" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    // 处理@"xxxxxxxxx\n%                                                                               "字符串
    if ([self matchPredicate:@"^([\\s\\S]*)(\n%[ ]{5,})$" forContent:string]) {
        NSMutableString * mStr = [[NSMutableString alloc] initWithString:string];
        NSRange range = [string rangeOfString:@"\n"];
        if (string.length-range.location > 0) {
            NSRange subRange = NSMakeRange(range.location, string.length-range.location);
            [mStr deleteCharactersInRange:subRange];
            string = [mStr mutableCopy];
        }
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    if (_totalLength > _existenceLength && string.length > 0 && self.commandOutputHandler) {
        NSRange range = [string rangeOfString:@"\n" options:NSBackwardsSearch];
        if (range.location == (string.length-1)) {
            string = [string substringWithRange:NSMakeRange(0, range.location)];
        }
        if (![string isEqual:@"\n"] && ![string isEqual:@"\x1b"]) {
            self.commandOutputHandler(string);
        }
    }
    
    _totalLength += string.length;
}

- (BOOL)matchPredicate:(NSString *)regex forContent:(NSString *)content {
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    bool match = [pre evaluateWithObject:content];
    return match;
}

#pragma mark - getter
- (NSString *)currentDirectoryPath {
    return task.currentDirectoryPath;
}

#pragma mark - setter
- (void)setCurrentDirectoryPath:(NSString *)path {
    task.currentDirectoryPath = path;
}

@end

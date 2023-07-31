//
//  YMIOPMLibTool.m
//  YMTool
//
//  Created by 黄玉洲 on 2021/2/4.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

#import "YMIOPMLibTool.h"
#import "YMNotifyTool.h"
#pragma mark - YMIOPMLibModel
@interface YMIOPMLibModel ()

@property (assign, nonatomic) NSString * appPID;
@property (assign, nonatomic) NSString * eventtype;
@property (assign, nonatomic) NSString * scheduledby;
@property (assign, nonatomic) NSDate * time;

@end

@implementation YMIOPMLibModel

- (NSString *)description {
    NSMutableDictionary * mDic = [NSMutableDictionary dictionary];
    [mDic setObject:self.appPID ?: @"" forKey:@"appPID"];
    [mDic setObject:self.eventtype ?: @"" forKey:@"eventtype"];
    [mDic setObject:self.scheduledby ?: @"" forKey:@"scheduledby"];
    [mDic setObject:self.time ?: @"" forKey:@"time"];
    NSString * string = [NSString stringWithFormat:@"%@", mDic];
    return string;
}

@end

#pragma mark - YMIOPMLibTool
@interface YMIOPMLibTool ()

@property (assign, nonatomic) bool isWakeup;

@end

@implementation YMIOPMLibTool

static YMIOPMLibTool * instance = nil;
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YMIOPMLibTool alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
    
    }
    return self;
}

#pragma mark - 通知
- (void)addNotification {
    NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];
    [center addObserver:self selector:@selector(screenDidSleep)
                   name:kWorkspaceScreensDidSleepNotification
                 object:nil];
    [center addObserver:self selector:@selector(screenDidWakeup)
                   name:kWorkspaceScreensDidWakeNotification
                 object:nil];
}

- (void)removeNofitication {
    [self removeObserver:self forKeyPath:kWorkspaceScreensDidSleepNotification];
    [self removeObserver:self forKeyPath:kWorkspaceScreensDidWakeNotification];
}

/// 休眠
- (void)screenDidSleep {
    self.isWakeup = false;
}

/// 唤醒
- (void)screenDidWakeup {
    self.isWakeup = true;
}

#pragma mark 指令执行
/// 立即执行指令(部分指令可能无法立即执行，所以需要延迟几秒再去调用)
/// 注意：需要Root权限才能调用
/// @param powerEvent 指令类型
+ (IOReturn)ymIOPMSchedulePowerEvent:(kPowerEvent)powerEvent {
    return [self ymIOPMSchedulePowerEvent:powerEvent date:[NSDate dateWithTimeIntervalSinceNow:0]];
}

/// 立即执行指令(部分指令可能无法立即执行，所以需要延迟几秒再去调用)
/// 注意：需要Root权限才能调用
/// @param powerEvent 指令类型
/// @param date 指定命令执行时间
+ (IOReturn)ymIOPMSchedulePowerEvent:(kPowerEvent)powerEvent date:(NSDate *)date {
    if ([YMIOPMLibTool share].isWakeup && powerEvent == kPowerEvent_WakeUp) {
        return kIOReturnSuccess;
    }
    
    NSDate * nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    if ([date timeIntervalSince1970] < [nowDate timeIntervalSince1970]) {
        return kIOReturnIsoTooOld;
    }
    
    CFStringRef powerType = nil;
    switch (powerEvent) {
        case kPowerEvent_WakeUp: powerType = CFSTR(kIOPMAutoWake); break;
        case kPowerEvent_PowerOn: powerType = CFSTR(kIOPMAutoPowerOn); break;
        case kPowerEvent_WakeUPOrPowerOn: powerType = CFSTR(kIOPMAutoWakeOrPowerOn); break;
        case kPowerEvent_Sleep: powerType = CFSTR(kIOPMAutoSleep); break;
        case kPowerEvent_Shutdown: powerType = CFSTR(kIOPMAutoShutdown); break;
        case kPowerEvent_Restart: powerType = CFSTR(kIOPMAutoRestart); break;
        default: return kIOReturnUnsupported;
    }
    
    IOPMAssertionID assertionID;
    IOPMAssertionDeclareUserActivity(CFSTR(""), kIOPMUserActiveLocal, &assertionID);
    
    // 系统执行时间
    CFDateRef dateRef = (__bridge CFDateRef)date;
    
    // CFStringRef通过CFBundleIdentifier标识正在调用的应用程序。可能为NULL。
    CFStringRef cgStringRef = NULL;
    
    // 执行指令
    IOReturn result = IOPMSchedulePowerEvent(dateRef, cgStringRef, powerType);
    if (result == kIOReturnSuccess && powerEvent == kPowerEvent_WakeUp) {
        [YMIOPMLibTool share].isWakeup = true;
    }
    return result;
}

#pragma mark 指令获取
/// 获取指令
+ (NSArray <YMIOPMLibModel *> *)ymIOPMCopyScheduledPowerEvents {
    CFArrayRef arrayRef = IOPMCopyScheduledPowerEvents();
    NSArray *array = (__bridge NSArray*)arrayRef;
    NSMutableArray * mArray = [NSMutableArray array];
    for (id obj in array) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            YMIOPMLibModel * model = [[YMIOPMLibModel alloc] init];
            model.appPID = obj[@"appPID"];
            model.eventtype = obj[@"eventtype"];
            model.scheduledby = obj[@"scheduledby"];
            model.time = obj[@"time"];
            [mArray addObject:model];
        }
    }
    return mArray;
}


#pragma mark 指令取消
/// 取消先前安排的电源事件。
/// 注意：需要Root权限才能调用
/// @param model 电源事件信息
+ (IOReturn)ymIOPMCancelScheduledPowerEvent:(YMIOPMLibModel *)model {
    CFDateRef dateRef = (__bridge CFDateRef)model.time;
    CFStringRef my_id = (__bridge CFStringRef)model.appPID;
    CFStringRef eventtype = (__bridge CFStringRef)model.eventtype;
    return IOPMCancelScheduledPowerEvent(dateRef, my_id, eventtype);
}

@end


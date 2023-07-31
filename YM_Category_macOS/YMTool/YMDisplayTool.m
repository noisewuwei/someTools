//
//  YMDisplayTool.m
//  YMTool
//
//  Created by 黄玉洲 on 2021/11/6.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import "YMDisplayTool.h"
#import "DisplayGamma.h"

#import <AppKit/AppKit.h>
#import <CoreGraphics/CGDirectDisplay.h>
#import <CoreGraphics/CGDisplayConfiguration.h>
#import <ApplicationServices/ApplicationServices.h>

typedef struct {
    uint32_t modeNumber;
    int32_t flags;
    uint32_t width;
    uint32_t height;
    uint32_t depth;
    uint8_t unknown[170];
    uint16_t freq;
    uint8_t more_unknown[16];
    float density;
} CGSDisplayMode;

extern CGDisplayErr CGSGetDisplayList(CGDisplayCount maxDisplays, CGDirectDisplayID * onlineDspys, CGDisplayCount * dspyCnt);
extern CGError CGSConfigureDisplayEnabled(CGDisplayConfigRef, CGDirectDisplayID, bool);
extern AXError _AXUIElementGetWindow(AXUIElementRef, CGWindowID* out);

extern void CGSGetNumberOfDisplayModes(CGDirectDisplayID display, int *nModes);
extern void CGSGetDisplayModeDescriptionOfLength(int displayID, int idx, CGSDisplayMode *mode, int length);
extern CGError CGSConfigureDisplayMode(CGDisplayConfigRef config, CGDirectDisplayID display, int modeNum);
extern void CGSGetCurrentDisplayMode(CGDirectDisplayID display, int* modeNum);

@interface YMDisplayTool ()

@property (strong, nonatomic) DisplayGamma * displayGamma;
@property (assign, nonatomic) int gammaDisplayID;

@end


@implementation YMDisplayTool

/// 验证是否为主屏幕
/// @param displayID 屏幕ID
+ (bool)ymDisplayIsMain:(NSString *)displayID {
    return CGDisplayIsMain((uint32_t)[displayID integerValue]);
}

/// 获取主屏ID
+ (uint32_t)ymMainDisplayID {
    return CGMainDisplayID();
}

/// 获取屏幕数量
+ (uint32_t)ymDisplayCount:(NSError **)error {
    const uint32_t kMaxDisplays = 128; // 最大屏幕数量
    uint32_t display_count = 0; // 屏幕数量

    // 如果没有获取到屏幕列表，则输出错误日志
    CGError err = CGGetActiveDisplayList(kMaxDisplays, nil, &display_count);
    if (error && err != kCGErrorSuccess) {
        NSString * errReason = [NSString stringWithFormat:@"CGError:%d", err];
        NSError * methodError = [NSError errorWithDomain:@"Get display count failed!"
                                                    code:err
                                                userInfo:@{NSLocalizedDescriptionKey: errReason}];
        *error = methodError;
    }

    return display_count;
}

/// 获取NSScreen
+ (NSScreen *)ymScreenWithDisplayID:(int32_t)displayID {
    NSScreen * screen = nil;
    for (NSScreen * temp_screen in [NSScreen screens]) {
        if ([[[temp_screen deviceDescription] objectForKey:@"NSScreenNumber"] integerValue] == displayID) {
            screen = temp_screen;
            break;
        }
    }
    return screen;
}

/// 获取显示器ID，返回nil证明获取失败;数组中第一位为主屏幕;
+ (NSArray <NSString *> *)ymDisplayList {
    const uint32_t kMaxDisplays = 128; // 最大屏幕数量
    CGDirectDisplayID active_displays[kMaxDisplays]; // 屏幕ID数组
    uint32_t display_count = 0; // 屏幕数量

    // 如果没有获取到屏幕列表，则输出错误日志
    CGError err = CGGetActiveDisplayList(kMaxDisplays, active_displays, &display_count);
    if (err != kCGErrorSuccess) {
        return nil;
    }
    
    // 遍历屏幕列表
    NSMutableArray * displayIDs = [NSMutableArray array];
    for (uint32_t i = 0; i < display_count; ++i) {
        uint32_t displayID_uint32 = active_displays[i];
        NSString * displayID = [NSString stringWithFormat:@"%d", displayID_uint32];
        
        // 将主屏幕放到第一位
        boolean_t boolValue = CGDisplayIsMain(displayID_uint32);
        if (boolValue) {
            [displayIDs insertObject:displayID atIndex:0];
        } else {
            [displayIDs addObject:displayID];
        }
    }
    
    return displayIDs;
}

+ (NSArray <YMDisplay *> *)ymDisplayModelList {
    NSArray * array = [self ymDisplayList];
    if (array.count == 0) {
        return nil;
    }
    
    NSMutableArray * displayModels = [NSMutableArray array];
    for (NSString * displayIDStr in array) {
        int displayID = [displayIDStr intValue];
        YMDisplay * display = [[YMDisplay alloc] initWithDisplayID:displayID];
        if (display.displayID > 0) {
            [displayModels addObject:display];
        }
    }
    
    if (displayModels.count == 0) {
        return nil;
    }
    return displayModels;
}

/// 获取指定屏幕的大小（像素值）
/// @param displayID 屏幕ID
+ (CGRect)ymDisplayBoundsWithID:(NSString *)displayID {
    return CGDisplayBounds((uint32_t)[displayID integerValue]);
}

/// 获取指定屏幕的大小（毫米值）
/// @param displayID 屏幕ID
+ (CGSize)ymDisplaySizeWithID:(NSString *)displayID {
    return CGDisplayScreenSize((uint32_t)[displayID integerValue]);
}

/// 禁用显示器
/// @param disable 是否禁用
/// @param displayID 屏幕ID
+ (NSString *)ymDisplayDisable:(bool)disable displayID:(NSString *)displayID {
    CGError err;
    CGDisplayConfigRef config;
    @try {
        if (disable) {
            CGDirectDisplayID    displays[0x10];
            CGDisplayCount  nDisplays = 0;
            
            CGDisplayErr err = CGSGetDisplayList(0x10, displays, &nDisplays);
            
            if (err == 0 && nDisplays > 0)
            {
                for (int i = 0; i < nDisplays; i++)
                {
                    if (displays[i] == (uint32_t)[displayID integerValue])
                        continue;
                    if (!CGDisplayIsOnline(displays[i]))
                        continue;
                    if (!CGDisplayIsActive(displays[i]))
                        continue;
                    @try {
                        [self moveAllWindows:(uint32_t)[displayID integerValue] to:&displays[i]];
                    }
                    @catch (NSException *e)
                    {
                        NSLog(@"Problems in moving windows");
                    }
                    break;
                }
            }
        }
        
        usleep(1000*1000); // sleep 1000 ms
        
        err = CGBeginDisplayConfiguration (&config);
        if (err != 0) {
            return [NSString stringWithFormat:@"Error in CGBeginDisplayConfiguration: %d",err];
        }
        
        bool mirror = CGDisplayIsInMirrorSet((uint32_t)[displayID integerValue]);
        if (!disable && mirror) {
            CGConfigureDisplayMirrorOfDisplay(config, (uint32_t)[displayID integerValue], kCGNullDirectDisplay);
        }
        
        err = CGSConfigureDisplayEnabled(config, (uint32_t)[displayID integerValue], !disable);
        if (err != 0) {
            return [NSString stringWithFormat:@"Error in CGSConfigureDisplayEnabled: %d", err];
        }
        
//        if (!mirror)
//        {
//            CGConfigureDisplayFadeEffect (config, 0, 0, 0, 0, 0);
//
//            io_registry_entry_t entry = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler");
//            if (entry)
//            {
//                IORegistryEntrySetCFProperty(entry, CFSTR("IORequestIdle"), kCFBooleanTrue);
//                usleep(100*1000); // sleep 100 ms
//                IORegistryEntrySetCFProperty(entry, CFSTR("IORequestIdle"), kCFBooleanFalse);
//                IOObjectRelease(entry);
//            }
//        }
        
        err = CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
        if (err != 0) {
            return [NSString stringWithFormat:@"Error in CGCompleteDisplayConfiguration: %d", err];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception:" );
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason );
    }
}

/// 切换屏幕分辨率
/// @param displayID 屏幕ID
/// @param modeNumber 编号(YMDisplayResolution)
+ (bool)ymDisplayID:(NSString *)displayID checkModeNumber:(int)modeNumber error:(NSString **)error {
    int display = (int)[displayID integerValue];
    // 验证屏幕活跃
    if (!CGDisplayIsActive(display)) {
        if (error) {
            *error = @"alert monitor not active";
        }
        return NO;
    } else {
        CGError err;
        CGDisplayConfigRef config;
        err = CGBeginDisplayConfiguration(&config);
        if (err != 0 && error) {
            *error = [NSString stringWithFormat:@"Error in CGBeginDisplayConfiguration: %@(%d)\n", [self ymStringWithCGError:err], err];
            return NO;
        }
        
        err = CGSConfigureDisplayMode(config, display, modeNumber);
        if (err != 0 && error) {
            *error = [NSString stringWithFormat:@"Error in CGConfigureDisplayWithDisplayMode: %@(%d)\n", [self ymStringWithCGError:err], err];
            return NO;
        }
        
        err = CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
        if (err != 0) {
            *error = [NSString stringWithFormat:@"Error in CGCompleteDisplayConfiguration: %@(%d)\n", [self ymStringWithCGError:err], err];
            return NO;
        }
    }
    return YES;
}

+ (NSString *)ymStringWithCGError:(CGError)err {
    switch (err) {
        case kCGErrorSuccess: return @"kCGErrorSuccess";
        case kCGErrorFailure: return @"kCGErrorFailure";
        case kCGErrorIllegalArgument: return @"kCGErrorIllegalArgument";
        case kCGErrorInvalidConnection: return @"kCGErrorInvalidConnection";
        case kCGErrorInvalidContext: return @"kCGErrorInvalidContext";
        case kCGErrorCannotComplete: return @"kCGErrorCannotComplete";
        case kCGErrorNotImplemented: return @"kCGErrorNotImplemented";
        case kCGErrorRangeCheck: return @"kCGErrorRangeCheck";
        case kCGErrorTypeCheck: return @"kCGErrorTypeCheck";
        case kCGErrorInvalidOperation: return @"kCGErrorInvalidOperation";
        case kCGErrorNoneAvailable: return @"kCGErrorNoneAvailable";
        default: return @"unknow";
    }
}

/// 获取屏幕是否休眠
+ (bool)ymDisplayIsSleep {
    // 另一种方式是终端执行system_profiler SPDisplaysDataType
    // 如果有Display Asleep: Yes字段，说明已经处于休眠状态
    return CGDisplayIsAsleep(0);
}

/// 获取指定屏幕是否休眠
+ (bool)ymDisplayIsSleepWithID:(int)displayID {
    return CGDisplayIsAsleep(displayID);
}

/// 获取指定屏幕是否活跃
+ (bool)ymDisplayIsActiveWithID:(int)displayID {
    return CGDisplayIsActive(displayID);
}

/// 获取指定屏幕是否为内置屏幕
+ (bool)ymDisplayIsBuiltinWithID:(int)displayID {
    return CGDisplayIsBuiltin(displayID);
}

/// 获取指定屏幕是否在镜像中
+ (bool)ymDisplayIsInMirrorSet:(int)displayID {
    return CGDisplayIsInMirrorSet(displayID);
}

/// 获取屏幕顺序
+ (int)ymDisplayUnitNumber:(int)displayID {
    return CGDisplayUnitNumber(displayID);
}

/// 获取屏幕供应商ID
+ (int)ymDisplayVendorNumber:(int)displayID {
    return CGDisplayVendorNumber(displayID);
}

/// 获取屏幕商品号
+ (int)ymDisplayModelNumber:(int)displayID {
    return CGDisplayModelNumber(displayID);
}

/// 获取屏幕序列号
+ (int)ymDisplaySerialNumber:(int)displayID {
    return CGDisplaySerialNumber(displayID);
}

/// 调整屏幕亮度
/// @param brightness 0~1.0
- (bool)ymDisplayBrightness:(float)brightness displayID:(int)displayID {
    if (brightness < 0 || brightness > 1.0) {
        return false;
    }
    
    if (self.gammaDisplayID != displayID) {
        [self.displayGamma applyToDisplayID:self.gammaDisplayID];
        self.gammaDisplayID = displayID;
        self.displayGamma = nil;
    }
    
    if (self.displayGamma == nil) {
        self.displayGamma = [DisplayGamma initWithDisplayID:displayID];
    }
    
    DisplayGamma * newGamma = [self.displayGamma copyWithBrightness:brightness];
    CGError error = [newGamma applyToDisplayID:displayID];
    return error == 0;
}

#pragma mark private
/// 将所有窗口移到另一个显示器上
/// @param display 源显示
/// @param todisplay 目的地显示
+ (void)moveAllWindows:(CGDirectDisplayID)display to:(CGDirectDisplayID*)todisplay {
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    CGRect bounds = CGDisplayBounds(display);
    CGRect dstbounds = CGDisplayBounds(*todisplay);
    for (NSDictionary *windowItem in ((__bridge NSArray *)windowList))
    {
        NSNumber *windowLayer = (NSNumber*)[windowItem objectForKey:(id)kCGWindowLayer];
        if ([windowLayer intValue] == 0)
        {
            CGRect windowBounds;
            CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[windowItem objectForKey:(id)kCGWindowBounds], &windowBounds);
            if (CGRectContainsPoint(bounds, windowBounds.origin))
            {
                NSNumber *windowNumber = (NSNumber*)[windowItem objectForKey:(id)kCGWindowNumber];
                NSNumber *windowOwnerPid = (NSNumber*)[windowItem objectForKey:(id)kCGWindowOwnerPID];
                AXUIElementRef appRef = AXUIElementCreateApplication((pid_t)[windowOwnerPid longValue]);
                if (appRef != nil) {
                    
                    CFArrayRef _windows;
                    if (AXUIElementCopyAttributeValues(appRef, kAXWindowsAttribute, 0, 100, &_windows) == kAXErrorSuccess)
                    {
                        for (int i = 0, len = (int)CFArrayGetCount(_windows); i < len; i++)
                        {
                            AXUIElementRef _windowItem = (AXUIElementRef)CFArrayGetValueAtIndex(_windows,i);
                            CGWindowID windowID;
                            if (_AXUIElementGetWindow(_windowItem, &windowID) == kAXErrorSuccess)
                            {
                                if (windowID == windowNumber.longValue)
                                {
                                    NSPoint tmpPos;
                                    tmpPos.x = dstbounds.origin.x;
                                    tmpPos.y = dstbounds.origin.y;
                                    CFTypeRef _position = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&tmpPos));
                                    if(AXUIElementSetAttributeValue(_windowItem,kAXPositionAttribute,(CFTypeRef*)_position) != kAXErrorSuccess){
                                        NSString* windowName = (NSString*)[windowItem objectForKey:(id)kCGWindowName];
                                        NSLog(@"Could not move window %ld (%@) of %ld", windowNumber.longValue, windowName, windowOwnerPid.longValue);
                                    }
                                }
                            }
                        }
                    }
                    CFRelease(appRef);
                }
            }
        }
    }
    CFRelease(windowList);
}

@end

#pragma mark - YMDisplayResolution
@interface YMDisplayResolution ()

@property (assign, nonatomic) int displayID;          // 屏幕ID
@property (assign, nonatomic) uint32_t modeNumber;    // 排列顺序
@property (assign, nonatomic) int32_t flags;
@property (assign, nonatomic) uint32_t width;         // 宽度
@property (assign, nonatomic) uint32_t height;        // 高度
@property (assign, nonatomic) uint32_t depth;         // 位深度
@property (assign, nonatomic) uint8_t * unknown;
@property (assign, nonatomic) uint16_t freq;          // 刷新率
@property (assign, nonatomic) uint8_t * more_unknown;
@property (assign, nonatomic) bool isHiDPI;
@property (assign, nonatomic) int widthMultiple;      // 最小公倍数
@property (assign, nonatomic) int heightMultiple;     // 最小公倍数
@property (assign, nonatomic) bool isActive;          // 活跃分辨率
@end

@implementation YMDisplayResolution

- (instancetype)initWithDisplayID:(int)displayID mode:(CGSDisplayMode)mode {
    if (self = [super init]) {
        self.displayID = displayID;
        self.modeNumber = mode.modeNumber;
        self.flags = mode.flags;
        self.width = mode.width;
        self.height = mode.height;
        self.depth = mode.depth;
        self.unknown = mode.unknown;
        self.freq = mode.freq;
        self.more_unknown = mode.more_unknown;
        self.isHiDPI = mode.density > 1;
    }
    return self;
}

- (NSString *)description {
    NSString * descriptionStr = [NSString stringWithFormat:@"displayID:%d modeNumber:%d flags:%d width:%d height:%d depth:%d unknown:%s freq:%d more_unknown:%s isHiDPI:%d isActive:%d", self.displayID, self.modeNumber, self.flags, self.width, self.height, self.depth, self.unknown, self.freq, self.more_unknown, self.isHiDPI, self.isActive];
    return descriptionStr;
}

@end


#pragma mark - YMDisplayItem
@interface YMDisplayItem ()

@property (assign, nonatomic) int displayID;
@property (assign, nonatomic) CGSize maxSize;

@end

@implementation YMDisplayItem

- (instancetype)initWithDisplayID:(int)displayID {
    if (self = [self initWithDisplayID:displayID duplicateRemove:NO withHiDPI:YES]) {
        self.displayID = displayID;
        [self loadDisplayModes:NO withHiDPI:YES];
    }
    return self;
}

- (instancetype)initWithDisplayID:(int)displayID duplicateRemove:(bool)duplicateRemove  withHiDPI:(bool)withHiDPI {
    if (self = [super init]) {
        self.displayID = displayID;
        [self loadDisplayModes:duplicateRemove withHiDPI:withHiDPI];
    }
    return self;
}

/// 加载屏幕的所有模式
- (void)loadDisplayModes:(bool)duplicateRemove withHiDPI:(bool)withHiDPI {
    // 获取支持的分辨率数量
    int numberOfDisplayModes = 0;
    CGSGetNumberOfDisplayModes(self.displayID, &numberOfDisplayModes);
    if (numberOfDisplayModes <= 0) {
        return;
    }
    
    // 获取当前屏幕活跃的分辨率
    int32_t currentDisplayMode = 0;
    CGSGetCurrentDisplayMode(self.displayID, &currentDisplayMode);
    
    // 最大分辨率
    self.maxSize = CGSizeMake(0, 0);
    
    // 获取分辨率数据
    NSMutableSet * mSet = [NSMutableSet set];
    NSMutableArray * resolutions = [NSMutableArray array];
    for (int i = 0; i < numberOfDisplayModes; i++) {
        CGSDisplayMode mode;
        CGSGetDisplayModeDescriptionOfLength(self.displayID, i, &mode, sizeof(mode));
        YMDisplayResolution * resolution = [[YMDisplayResolution alloc] initWithDisplayID:self.displayID mode:mode];
        resolution.isActive = currentDisplayMode == i ? true : false;
         
        if (mode.flags < 0) {
            continue;
        }
        
        if (!withHiDPI) {
            if (!resolution.isHiDPI) {
                continue;
            }
        }
        
        if (duplicateRemove) {
            NSString * value = [NSString stringWithFormat:@"%dx%d", resolution.width, resolution.height];
            if ([mSet containsObject:value]) {
                continue;
            }
            [mSet addObject:value];
        }
        
        // 获取最大分辨率
//        int tempScale = resolution.isHiDPI ? 2 : 1;
//        if ((self.maxSize.width + self.maxSize.height) < (resolution.width + resolution.height) * tempScale) {
//            self.maxSize = CGSizeMake(resolution.width, resolution.height);
//        }
        
        int commonDivisor = [self maxCommonDivisor:resolution.width height:resolution.height];
        resolution.widthMultiple = resolution.width/commonDivisor;
        resolution.heightMultiple = resolution.height/commonDivisor;
        [resolutions addObject:resolution];
    }
    
    // 删除大于最大分辨率的分辨率选项
//    NSMutableArray * deleteArray = [NSMutableArray array];
//    for (YMDisplayResolution * resolution in resolutions) {
//        int tempScale = resolution.isHiDPI ? 2 : 1;
//        if ((resolution.width* tempScale > self.maxSize.width) && (resolution.height * tempScale > self.maxSize.height)) {
//            [deleteArray addObject:resolution];
//        }
//    }
//    [resolutions removeObjectsInArray:deleteArray];
    
    NSArray * array = [resolutions sortedArrayUsingComparator:^NSComparisonResult(YMDisplayResolution * a, YMDisplayResolution * b) {
        if (a.width > b.width)
            return NSOrderedAscending;
        else if (a.width < b.width)
            return NSOrderedDescending;
        else {
            if (a.freq > b.freq)
                return NSOrderedAscending;
            else if (a.freq < b.freq)
                return NSOrderedDescending;
            return NSOrderedSame;
        }
    }];
    self.resolutions = array;
}

/// 获取最大公约数
- (int)maxCommonDivisor:(int)width height:(int)height {
    return (height == 0) ? width : [self maxCommonDivisor:height height:width%height];
}

@end


#pragma mark - 屏幕
@interface YMDisplay ()

@property (assign, nonatomic) int displayID;              // 屏幕ID
@property (assign, nonatomic) int displayUnitNumber;      // 屏幕顺序
@property (assign, nonatomic) int displayVendorNumber;    // 供应商编号
@property (assign, nonatomic) int displayProduceNumber;   // 产品编号
@property (assign, nonatomic) int displaySerialNumber;    // 序列号

@end
    
@implementation YMDisplay

- (instancetype)initWithDisplayID:(int)displayID {
    if (self = [super init]) {
        self.displayID = displayID;
        self.displayUnitNumber = [YMDisplayTool ymDisplayUnitNumber:displayID];
        self.displayVendorNumber = [YMDisplayTool ymDisplayVendorNumber:displayID];
        self.displayProduceNumber = [YMDisplayTool ymDisplayModelNumber:displayID];
        self.displaySerialNumber = [YMDisplayTool ymDisplaySerialNumber:displayID];
    }
    return self;
}

@end

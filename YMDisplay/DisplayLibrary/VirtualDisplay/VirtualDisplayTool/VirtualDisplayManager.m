//
//  VirtualDisplayManager.m
//  YMDisplay
//
//  Created by 黄玉洲 on 2022/7/10.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "VirtualDisplayManager.h"
#import "DisplayDefinition.h"

#import "VirtualDisplay.h"
#import "VirtualDisplayDescriptor.h"
#import "VirtualDisplayMode.h"
#import "VirtualDisplaySettings.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreGraphics/CGDirectDisplay.h>
#import <CoreGraphics/CGDisplayConfiguration.h>
#import <ApplicationServices/ApplicationServices.h>

#import <objc/runtime.h>

#pragma mark - DisplayMode
@interface DisplayMode ()

@property(assign, nonatomic) unsigned int height;
@property(assign, nonatomic) unsigned int width;

@end

@implementation DisplayMode

- (instancetype)initWithWidth:(unsigned int)width ratio:(float)ratio {
    if (self = [super init]) {
        self.width = width;
        self.height = width * ratio;
    }
    return self;
}

@end

#pragma mark - VirtualDisplayManager
extern void CGSGetNumberOfDisplayModes(CGDirectDisplayID display, int *nModes);
extern void CGSGetDisplayModeDescriptionOfLength(int displayID, int idx, CGSDisplayMode *mode, int length);
extern CGError CGSConfigureDisplayMode(CGDisplayConfigRef config, CGDirectDisplayID display, int modeNum);
extern void CGSGetCurrentDisplayMode(CGDirectDisplayID display, int* modeNum);

@interface VirtualDisplayManager ()

@property (strong, nonatomic) NSMutableArray * virtualDisplayList;

@end



@implementation VirtualDisplayManager


/*
 注册一个显示重配置回调过程。“用户信息”参数每次返回回调过程调用。
 */
void reconfigurationCallBack(CGDirectDisplayID display, CGDisplayChangeSummaryFlags flags, void * __nullable userInfo) {
    
}

typedef void(*CGDisplayReconfigurationCallBack)(CGDirectDisplayID display,
  CGDisplayChangeSummaryFlags flags, void * __nullable userInfo);

+ (instancetype)share {
    static VirtualDisplayManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VirtualDisplayManager alloc] init];
    });
    return instance;
}

+ (bool)isSupport {
    if (@available(macOS 10.15, *)) {
        return true;
    }
    return false;
}

- (instancetype)init {
    if (self = [super init]) {
        self.virtualDisplayList = [NSMutableArray array];
    }
    return self;
}

/// 创建虚拟屏
/// @param definition 按指定分辨率比例创建
/// @param displayName 屏幕名称
- (VirtualDisplay *)createVirtualDisplay:(DisplayDefinition *)definition displayName:(NSString *)displayName {
    if (@available(macOS 10.15, *)) {
        NSArray * modes = @[
                            [[DisplayMode alloc] initWithWidth:3840 ratio:(definition.aspectHeight * 1.0 / definition.aspectWidth)],
                            [[DisplayMode alloc] initWithWidth:2880 ratio:(definition.aspectHeight * 1.0 / definition.aspectWidth)],
                            [[DisplayMode alloc] initWithWidth:2560 ratio:(definition.aspectHeight * 1.0 / definition.aspectWidth)],
                            [[DisplayMode alloc] initWithWidth:2048 ratio:(definition.aspectHeight * 1.0 / definition.aspectWidth)],
                            [[DisplayMode alloc] initWithWidth:1920 ratio:(definition.aspectHeight * 1.0 / definition.aspectWidth)],
                            [[DisplayMode alloc] initWithWidth:1600 ratio:(definition.aspectHeight * 1.0 / definition.aspectWidth)],
                            [[DisplayMode alloc] initWithWidth:1280 ratio:(definition.aspectHeight * 1.0 / definition.aspectWidth)],
                            ];
        return [self createVirtualDisplay:definition modes:modes displayName:displayName];
    }
    return nil;
}

/// 创建虚拟屏
/// @param definition 按指定分辨率比例创建
/// @param modes 分辨率
/// @param displayName 屏幕名称
- (VirtualDisplay *)createVirtualDisplay:(DisplayDefinition *)definition modes:(NSArray <DisplayMode *> *)modes displayName:(NSString *)displayName {\
    if (@available(macOS 10.15, *)) {
        VirtualDisplayDescriptor *descriptor = [[VirtualDisplayDescriptor alloc] init];
        if (descriptor) {
            int randomNum = 0;
            while (randomNum == 0) {
                int random = 1000 + arc4random() % 1000 + 1;
                if (self.virtualDisplayList.count == 0) {
                    randomNum = random;
                    break;
                }

                for (VirtualDisplay * display in self.virtualDisplayList) {
                    if (display.serialNum != random) {
                        randomNum = random;
                        break;
                    }
                }
            }

            descriptor.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            descriptor.serialNum = randomNum;       // 序列号
            descriptor.name = displayName;
            descriptor.productID = (uint32_t)0x400; // 模型ID
            descriptor.vendorID = (uint32_t)0x800;  // 供应商ID

            descriptor.whitePoint = CGPointMake(0.950, 1.000);   // "Taken from Generic RGB Profile.icc"
            descriptor.redPrimary = CGPointMake(0.454, 0.242);   // "Taken from Generic RGB Profile.icc"
            descriptor.greenPrimary = CGPointMake(0.353, 0.674); // "Taken from Generic RGB Profile.icc"
            descriptor.bluePrimary = CGPointMake(0.157, 0.084);  // "Taken from Generic RGB Profile.icc"

            descriptor.maxPixelsWide = (uint32_t)(definition.aspectWidth * (definition.hiDPI ? 2 : 1) * definition.maxMultiplier);
            descriptor.maxPixelsHigh = (uint32_t)(definition.aspectHeight * (definition.hiDPI ? 2 : 1) * definition.maxMultiplier);

            double diagonalSizeRatio = definition.inches * 25.4 / sqrt(definition.aspectWidth * definition.aspectWidth + definition.aspectHeight * definition.aspectHeight);
            descriptor.sizeInMillimeters = CGSizeMake(definition.aspectWidth * diagonalSizeRatio, definition.aspectHeight * diagonalSizeRatio);

            NSMutableArray * displayModes = [NSMutableArray array];
            VirtualDisplay * display = [[VirtualDisplay alloc] initWithDescriptor:descriptor];
            VirtualDisplaySettings *settings = [[VirtualDisplaySettings alloc] init];
            if (settings && display) {
                for (DisplayMode * mode in modes) {
                    VirtualDisplayMode * displayMode = [[VirtualDisplayMode alloc] initWithWidth:mode.width height:mode.height refreshRate:definition.refreshRate];
                    [displayModes addObject:displayMode];
                }

                settings.hiDPI = definition.hiDPI;
                settings.modes = displayModes;
                if ([display applySettings:settings]) {
                    [self.virtualDisplayList addObject:display];
                    return display;
                }
            }
        }
    }
    return nil;
}



/// 创建虚拟屏(测试阶段)
/// @param definition 按指定分辨率创建
/// @param displayName 屏幕名称
- (VirtualDisplay *)createFixedResolutionVirtualDisplay:(DisplayResolutionDefinition *)definition displayName:(NSString *)displayName {
    if (@available(macOS 10.15, *)) {
        VirtualDisplayDescriptor *descriptor = [[VirtualDisplayDescriptor alloc] init];
        int randomNum = 0;
        while (randomNum == 0) {
            int random = 1000 + arc4random() % 1000 + 1;
            if (self.virtualDisplayList.count == 0) {
                randomNum = random;
                break;
            }

            for (VirtualDisplay * display in self.virtualDisplayList) {
                if (display.serialNum != random) {
                    randomNum = random;
                    break;
                }
            }
        }

        descriptor.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        descriptor.serialNum = randomNum;       // 序列号
        descriptor.name = displayName;
        descriptor.productID = (uint32_t)0x400; // 模型ID
        descriptor.vendorID = (uint32_t)0x800;  // 供应商ID

        descriptor.whitePoint = CGPointMake(0.3125, 0.3291);   // "Taken from Generic RGB Profile.icc"
        descriptor.redPrimary = CGPointMake(0.6797, 0.3203);   // "Taken from Generic RGB Profile.icc"
        descriptor.greenPrimary = CGPointMake(0.2559, 0.6983); // "Taken from Generic RGB Profile.icc"
        descriptor.bluePrimary = CGPointMake(0.1494, 0.0557);  // "Taken from Generic RGB Profile.icc"

    //    descriptor.maxPixelsWide = definition.width * (definition.hiDPI ? 2 : 1);
    //    descriptor.maxPixelsHigh = definition.height * (definition.hiDPI ? 2 : 1);
    //    descriptor.sizeInMillimeters = CGSizeMake(25.4 * descriptor.maxPixelsWide / definition.ppi, 25.4 * descriptor.maxPixelsHigh / definition.ppi);

        descriptor.maxPixelsWide = (uint32_t)(definition.aspectWidth * (definition.hiDPI ? 2 : 1) * definition.maxMultiplier);
        descriptor.maxPixelsHigh = (uint32_t)(definition.aspectHeight * (definition.hiDPI ? 2 : 1) * definition.maxMultiplier);

        // 使用24寸屏幕计算
        double diagonalSizeRatio = 27 * 25.4 / sqrt(definition.aspectWidth * definition.aspectWidth + definition.aspectHeight * definition.aspectHeight);
        descriptor.sizeInMillimeters = CGSizeMake(definition.aspectWidth * diagonalSizeRatio,
                                                  definition.aspectHeight * diagonalSizeRatio);

        VirtualDisplay * display = [[VirtualDisplay alloc] initWithDescriptor:descriptor];
        NSArray * modes = [NSArray array];
        if (display) {
            // 常见分辨率
            modes =  @[
                [[VirtualDisplayMode alloc] initWithWidth:6016 height:3384 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:5120 height:2880 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:4096 height:2304 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:3840 height:2400 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:3840 height:2160 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:3840 height:1600 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:3840 height:1080 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:3072 height:1920 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:2880 height:1800 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:2560 height:1600 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:2560 height:1440 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:2304 height:1440 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:2048 height:1536 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:2048 height:1152 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1920 height:1200 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1920 height:1080 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1680 height:1050 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1600 height:1200 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1600 height:900 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1440 height:900 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1400 height:1050 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1366 height:768 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1280 height:1024 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1280 height:800 refreshRate:60],
                [[VirtualDisplayMode alloc] initWithWidth:1280 height:720 refreshRate:60],
            ];
        }

        VirtualDisplaySettings *settings = [[VirtualDisplaySettings alloc] init];
        if (settings) {
            settings.hiDPI = definition.hiDPI ? 1 : 0;
            settings.modes = modes;
            if ([display applySettings:settings]) {
                [self.virtualDisplayList addObject:display];
                settings = nil;
                return display;
            }
        }
    }
    return nil;
}


/// 已创建的虚拟屏
- (NSArray <VirtualDisplay *> *)virtualDisplays {
    return self.virtualDisplayList;
}

/// 删除虚拟屏
- (bool)removeVirtualDisplay:(VirtualDisplay *)virtualDisplay {
    bool result = false;
    for (int i = 0; i < self.virtualDisplays.count; i++) {
        VirtualDisplay * tempVirtualDisplay = self.virtualDisplays[i];
        if (virtualDisplay.displayID == tempVirtualDisplay.displayID) {
            tempVirtualDisplay = nil;
            [self.virtualDisplayList removeObjectAtIndex:i];
            result = true;
        }
    }
    return result;
}

/// 删除虚拟屏
- (bool)removeVirtualDisplayID:(unsigned int)virtualDisplayID {
    bool result = false;
    for (int i = 0; i < self.virtualDisplays.count; i++) {
        VirtualDisplay * tempVirtualDisplay = self.virtualDisplays[i];
        if (virtualDisplayID == tempVirtualDisplay.displayID) {
            tempVirtualDisplay = nil;
            [self.virtualDisplayList removeObjectAtIndex:i];
            result = true;
        }
    }
    return result;
}

/// 删除指定个数虚拟屏（从最后面的开始删除）
- (bool)removeVirtualDisplayWithCount:(unsigned int)count {
    if (count <= 0 || self.virtualDisplays.count < count) {
        return false;
    }
    
    int deleteCount = 0;
    while (deleteCount < count) {
        [self.virtualDisplayList removeLastObject];
        deleteCount++;
    }
    return true;
}

- (void)removeAllVirtualDisplay {
    [self.virtualDisplayList removeAllObjects];
}

#pragma mark - 显示器
/// 删除屏幕color file文件(需要root权限)
/// @param displayName 虚拟屏名字
- (void)removeColorFileWithDisplayName:(NSString *)displayName {
    NSString * colorFilePath = @"/Library/ColorSync/Profiles/Displays";
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * files = [fileManager contentsOfDirectoryAtPath:colorFilePath error:nil];
    for (NSString * fileName in files) {
        if ([[fileName lowercaseString] containsString:[displayName lowercaseString]]) {
            NSError * error;
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", colorFilePath, fileName] error:&error];
            if (error) {
                NSLog(@"remove fail:%@", [error localizedDescription]);
            }
        }
    }
}



#pragma mark - 分辨率
- (NSArray <DisplayResolution *> *)resolutionsWithDisplayID:(int)displayID {
    int numberOfDisplayModes = 0;
    CGSGetNumberOfDisplayModes(displayID, &numberOfDisplayModes);
    if (numberOfDisplayModes <= 0) {
        return nil;
    }
    
    NSMutableArray * resolutions = [NSMutableArray array];
    int currentDisplayMode;
    CGSGetCurrentDisplayMode(displayID, &currentDisplayMode);
    for (int i = 0; i < numberOfDisplayModes; i++) {
        CGSDisplayMode mode;
        CGSGetDisplayModeDescriptionOfLength(displayID, i, &mode, sizeof(mode));
        DisplayResolution * resolution = [[DisplayResolution alloc] initWithDisplayID:(int)displayID mode:mode];
        resolution.isActive = currentDisplayMode == i ? true : false;
        [resolutions addObject:resolution];
    }
    
    return resolutions;
}

/// 切换屏幕分辨率
/// @param displayID 屏幕ID
/// @param modeNumber 编号(YMDisplayResolution)
- (BOOL)changeResolution:(int)displayID modeNumber:(int)modeNumber error:(NSString **)error {
    // 验证屏幕活跃
    if (!CGDisplayIsActive(displayID)) {
        if (error) {
            *error = @"alert monitor not active";
        }
        return NO;
    } else {
        CGError err;
        CGDisplayConfigRef config;
        err = CGBeginDisplayConfiguration(&config);
        if (err != 0 && error) {
            *error = [NSString stringWithFormat:@"Error in CGBeginDisplayConfiguration: %d\n", err];
            return NO;
        }
        
        err = CGSConfigureDisplayMode(config, displayID, modeNumber);
        if (err != 0 && error) {
            *error = [NSString stringWithFormat:@"Error in CGConfigureDisplayWithDisplayMode: %d\n", err];
            return NO;
        }
        err = CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
        if (err != 0) {
            *error = [NSString stringWithFormat:@"Error in CGCompleteDisplayConfiguration: %d\n", err];
            return NO;
        }
    }
    return YES;
}


@end

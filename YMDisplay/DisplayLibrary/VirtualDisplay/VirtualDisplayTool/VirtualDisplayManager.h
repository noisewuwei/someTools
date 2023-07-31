//
//  VirtualDisplayManager.h
//  YMDisplay
//
//  Created by 黄玉洲 on 2022/7/10.
//

#import <Foundation/Foundation.h>
#import "DisplayResolution.h"
#import "DisplayDefinition.h"
#import "VirtualDisplay.h"
NS_ASSUME_NONNULL_BEGIN
@class DisplayDefinition;
@class DisplayResolutionDefinition;

@interface DisplayMode : NSObject

/// 初始化
/// @param width 宽度
/// @param ratio 比率 = 高度:宽度
- (instancetype)initWithWidth:(unsigned int)width ratio:(float)ratio;

@property(readonly, nonatomic) unsigned int width;
@property(readonly, nonatomic) unsigned int height;

@end

@interface VirtualDisplayManager : NSObject

+ (instancetype)share;

+ (bool)isSupport;

/// 创建虚拟屏
/// @param definition 按指定分辨率比例创建
/// @param displayName 屏幕名称
- (VirtualDisplay *)createVirtualDisplay:(DisplayDefinition *)definition displayName:(NSString *)displayName;

/// 创建虚拟屏
/// @param definition 按指定分辨率比例创建
/// @param modes 分辨率
/// @param displayName 屏幕名称
- (VirtualDisplay *)createVirtualDisplay:(DisplayDefinition *)definition modes:(NSArray <DisplayMode *> *)modes displayName:(NSString *)displayName;

/// 创建虚拟屏
/// @param definition 按指定分辨率创建
/// @param displayName 屏幕名称
- (VirtualDisplay *)createFixedResolutionVirtualDisplay:(DisplayResolutionDefinition *)definition displayName:(NSString *)displayName;

/// 已创建的虚拟屏
- (NSArray <VirtualDisplay *> *)virtualDisplays;

/// 删除虚拟屏
- (bool)removeVirtualDisplay:(VirtualDisplay *)virtualDisplay;

/// 删除虚拟屏
- (bool)removeVirtualDisplayID:(unsigned int)virtualDisplayID;

/// 删除指定个数虚拟屏（从最后面的开始删除）
- (bool)removeVirtualDisplayWithCount:(unsigned int)count;

- (void)removeAllVirtualDisplay;

#pragma mark - 显示器
/// 删除屏幕color file文件(需要root权限)
/// @param displayName 虚拟屏名字
- (void)removeColorFileWithDisplayName:(NSString *)displayName;


#pragma mark - 分辨率
- (NSArray <DisplayResolution *> *)resolutionsWithDisplayID:(int)displayID;

/// 切换屏幕分辨率
/// @param displayID 屏幕ID
/// @param modeNumber 编号(YMDisplayResolution)
- (BOOL)changeResolution:(int)displayID modeNumber:(int)modeNumber error:(NSString **)error;

@end

NS_ASSUME_NONNULL_END

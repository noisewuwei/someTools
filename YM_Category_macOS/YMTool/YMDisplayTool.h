//
//  YMDisplayTool.h
//  YMTool
//
//  Created by 黄玉洲 on 2021/11/6.
//  Copyright © 2021 海南有趣. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NSScreen;
NS_ASSUME_NONNULL_BEGIN
@class YMDisplay;

/// CGDisplay的相关引用
@interface YMDisplayTool : NSObject

/// 验证是否为主屏幕
/// @param displayID 屏幕ID
+ (bool)ymDisplayIsMain:(NSString *)displayID;

/// 获取主屏ID
+ (uint32_t)ymMainDisplayID;

/// 获取屏幕数量
+ (uint32_t)ymDisplayCount:(NSError **)error;

/// 获取NSScreen
+ (NSScreen *)ymScreenWithDisplayID:(int32_t)displayID;

/// 获取显示器ID，返回nil证明获取失败;数组中第一位为主屏幕;
+ (NSArray <NSString *> *)ymDisplayList;
+ (NSArray <YMDisplay *> *)ymDisplayModelList;


/// 获取指定屏幕的大小（像素值）
/// @param displayID 屏幕ID
+ (CGRect)ymDisplayBoundsWithID:(NSString *)displayID;

/// 获取指定屏幕的大小（毫米值）
/// @param displayID 屏幕ID
+ (CGSize)ymDisplaySizeWithID:(NSString *)displayID;

/// 禁用显示器
/// @param disable 是否禁用
/// @param displayID 屏幕ID
+ (NSString *)ymDisplayDisable:(bool)disable displayID:(NSString *)displayID;

/// 切换屏幕分辨率
/// @param displayID 屏幕ID
/// @param modeNumber 编号(YMDisplayResolution)
+ (bool)ymDisplayID:(NSString *)displayID checkModeNumber:(int)modeNumber error:(NSString **)error;

/// 获取屏幕是否休眠
+ (bool)ymDisplayIsSleep;

/// 获取指定屏幕是否休眠
+ (bool)ymDisplayIsSleepWithID:(int)displayID;

/// 获取指定屏幕是否活跃
+ (bool)ymDisplayIsActiveWithID:(int)displayID;

/// 获取指定屏幕是否为内置屏幕
+ (bool)ymDisplayIsBuiltinWithID:(int)displayID;

/// 获取指定屏幕是否在镜像中
+ (bool)ymDisplayIsInMirrorSet:(int)displayID;

/// 获取屏幕顺序
+ (int)ymDisplayUnitNumber:(int)displayID;

/// 获取屏幕供应商ID
+ (int)ymDisplayVendorNumber:(int)displayID;

/// 获取屏幕商品号
+ (int)ymDisplayModelNumber:(int)displayID;

/// 获取屏幕序列号
+ (int)ymDisplaySerialNumber:(int)displayID;

/// 调整屏幕亮度
/// @param brightness 0~1.0
- (bool)ymDisplayBrightness:(float)brightness displayID:(int)displayID;


@end


#pragma mark - 分辨率
@class YMDisplayResolution;
@interface YMDisplayItem : NSObject

- (instancetype)initWithDisplayID:(int)displayID;
- (instancetype)initWithDisplayID:(int)displayID duplicateRemove:(BOOL)duplicateRemove withHiDPI:(BOOL)withHiDPI;

@property (assign, nonatomic, readonly) int displayID;  // 屏幕ID
@property (assign, nonatomic, readonly) CGSize maxSize; // 最大分辨率
@property (strong, nonatomic) NSArray <YMDisplayResolution *> * resolutions;

@end

@interface YMDisplayResolution : NSObject

@property (assign, nonatomic, readonly) int displayID;          // 屏幕ID
@property (assign, nonatomic, readonly) uint32_t modeNumber;    // 排列顺序
@property (assign, nonatomic, readonly) int32_t flags;
@property (assign, nonatomic, readonly) uint32_t width;         // 宽度
@property (assign, nonatomic, readonly) uint32_t height;        // 高度
@property (assign, nonatomic, readonly) uint32_t depth;         // 位深度
@property (assign, nonatomic, readonly) uint8_t * unknown;
@property (assign, nonatomic, readonly) uint16_t freq;          // 刷新率
@property (assign, nonatomic, readonly) uint8_t * more_unknown;
@property (assign, nonatomic, readonly) bool isHiDPI;           
@property (assign, nonatomic, readonly) int widthMultiple;      // 最小公倍数
@property (assign, nonatomic, readonly) int heightMultiple;     // 最小公倍数
@property (assign, nonatomic, readonly) bool isActive;          // 该分辨率是否活跃

@end

#pragma mark - 屏幕
@interface YMDisplay : NSObject

- (instancetype)initWithDisplayID:(int)displayID;

@property (assign, nonatomic, readonly) int displayID;              // 屏幕ID
@property (assign, nonatomic, readonly) int displayUnitNumber;      // 屏幕顺序
@property (assign, nonatomic, readonly) int displayVendorNumber;    // 供应商编号
@property (assign, nonatomic, readonly) int displayProduceNumber;   // 产品编号
@property (assign, nonatomic, readonly) int displaySerialNumber;    // 序列号

@end

NS_ASSUME_NONNULL_END

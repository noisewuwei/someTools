//
//  DisplayResolution.h
//  YMDisplay
//
//  Created by 黄玉洲 on 2022/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    uint32_t modeNumber;
    uint32_t flags;
    uint32_t width;
    uint32_t height;
    uint32_t depth;
    uint8_t unknown[170];
    uint16_t freq;
    uint8_t more_unknown[16];
    float density;
} CGSDisplayMode;

@interface DisplayResolution : NSObject

- (instancetype)initWithDisplayID:(int)displayID mode:(CGSDisplayMode)displayMode;

@property (assign, nonatomic, readonly) int displayID;          // 屏幕ID
@property (assign, nonatomic, readonly) uint32_t modeNumber;    // 排列顺序
@property (assign, nonatomic, readonly) uint32_t width;         // 宽度
@property (assign, nonatomic, readonly) uint32_t height;        // 高度
@property (assign, nonatomic, readonly) uint16_t refreshRate;   // 刷新率
@property (assign, nonatomic, readonly) bool isHIDPI;             // hiDPI
@property (assign, nonatomic) bool isActive;          // 活跃分辨率

@end

NS_ASSUME_NONNULL_END

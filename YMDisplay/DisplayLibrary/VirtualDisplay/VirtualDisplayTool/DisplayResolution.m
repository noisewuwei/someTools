//
//  DisplayResolution.m
//  YMDisplay
//
//  Created by 黄玉洲 on 2022/7/24.
//

#import "DisplayResolution.h"

@interface DisplayResolution ()

@property (assign, nonatomic) int displayID;          // 屏幕ID
@property (assign, nonatomic) uint32_t modeNumber;    // 排列顺序
@property (assign, nonatomic) uint32_t width;         // 宽度
@property (assign, nonatomic) uint32_t height;        // 高度
@property (assign, nonatomic) uint16_t refreshRate;   // 刷新率
@property (assign, nonatomic) bool isHIDPI;             // hiDPI
@property (assign, nonatomic) uint32_t bitDepth;       // 位深度

@end

@implementation DisplayResolution

- (instancetype)initWithDisplayID:(int)displayID mode:(CGSDisplayMode)displayMode {
    if (self = [super init]) {
        self.displayID = displayID;
        self.modeNumber = displayMode.modeNumber;
        self.width = displayMode.width;
        self.height = displayMode.height;
        self.bitDepth = displayMode.depth;
        self.refreshRate = displayMode.freq;
        self.isHIDPI = displayMode.density > 1;
    }
    return self;
}

- (NSString *)description {
    NSString * descriptionStr = [NSString stringWithFormat:@"displayID:%d modeNumber:%d width:%d height:%d isHiDPI:%d isActive:%d", self.displayID, self.modeNumber, self.width, self.height, self.isHIDPI, self.isActive];
    return descriptionStr;
}

@end

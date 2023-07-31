//
//  VirtualDisplaySettings.m
//  VirtualDisplay
//
//  Created by 黄玉洲 on 2022/8/31.
//

#import "VirtualDisplaySettings.h"

@implementation VirtualDisplaySettings

- (void)dealloc {
#if defined(DEBUG)
    NSLog(@"%s", __func__);
#endif
}

+ (instancetype)alloc {
    Class VirtualDisplaySettingsClass = NSClassFromString(@"CGVirtualDisplaySettings");
    return [VirtualDisplaySettingsClass alloc];
}

@end

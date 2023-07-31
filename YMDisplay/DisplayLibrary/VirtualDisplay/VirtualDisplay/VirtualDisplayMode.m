//
//  VirtualDisplayMode.m
//  VirtualDisplay
//
//  Created by 黄玉洲 on 2022/8/31.
//

#import "VirtualDisplayMode.h"

@implementation VirtualDisplayMode

- (void)dealloc {
#if defined(DEBUG)
    NSLog(@"%s", __func__);
#endif
}

+ (instancetype)alloc {
    Class VirtualDisplayModeClass = NSClassFromString(@"CGVirtualDisplayMode");
    return [VirtualDisplayModeClass alloc];
}

@end

//
//  VirtualDisplay.m
//  YMDisplay
//
//  Created by 黄玉洲 on 2022/7/25.
//

#import "VirtualDisplay.h"
#import <objc/runtime.h>
@implementation VirtualDisplay

- (void)dealloc {
#if defined(DEBUG)
    NSLog(@"%s", __func__);
#endif
}

+ (instancetype)alloc {
    Class VirtualDisplayClass = NSClassFromString(@"CGVirtualDisplay");
    return [VirtualDisplayClass alloc];
}

@end

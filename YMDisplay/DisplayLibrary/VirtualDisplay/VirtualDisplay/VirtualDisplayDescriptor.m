//
//  VirtualDisplayDescriptor.m
//  VirtualDisplay
//
//  Created by 黄玉洲 on 2022/8/31.
//

#import "VirtualDisplayDescriptor.h"

@implementation VirtualDisplayDescriptor

- (void)dealloc {
#if defined(DEBUG)
    NSLog(@"%s", __func__);
#endif
}

+ (instancetype)alloc {
    Class VirtualDisplayDescriptorClass = NSClassFromString(@"CGVirtualDisplayDescriptor");
    return [VirtualDisplayDescriptorClass alloc];
}

@end

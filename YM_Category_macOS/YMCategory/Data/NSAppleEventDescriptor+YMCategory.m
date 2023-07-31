//
//  NSAppleEventDescriptor+YMCategory.m
//  YMCategory
//
//  Created by 黄玉洲 on 2022/10/31.
//  Copyright © 2022 海南有趣. All rights reserved.
//

#import "NSAppleEventDescriptor+YMCategory.h"

@implementation NSAppleEventDescriptor (YMCategory)

- (NSAppleEventDescriptor *)ymDescriptorForKeyword:(AEKeyword)keywor {
    return [self attributeDescriptorForKeyword:keywor];
}

- (OSType)ymOSTypeForKeyword:(AEKeyword)keywor {
    return [[self attributeDescriptorForKeyword:keywor] typeCodeValue];
}

- (DescType)ymDescTypeForKeyword:(AEKeyword)keywor {
    return [[self attributeDescriptorForKeyword:keywor] descriptorType];
}

- (DescType)ymBooleanTypeForKeyword:(AEKeyword)keywor {
    return [[self attributeDescriptorForKeyword:keywor] booleanValue];
}


@end

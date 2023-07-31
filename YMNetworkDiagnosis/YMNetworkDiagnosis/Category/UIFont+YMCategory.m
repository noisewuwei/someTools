//
//  UIFont+YMCategory.m
//  wujiVPN
//
//  Created by 黄玉洲 on 2018/12/25.
//  Copyright © 2018年 TouchingApp. All rights reserved.
//

#import "UIFont+YMCategory.h"
#import <objc/runtime.h>

@implementation UIFont (YMCategory)

+ (void)load {
    // 获取替换后的类方法
    Method newMethod = class_getClassMethod([self class], @selector(adjustFont:));
    // 获取替换前的类方法
    Method method = class_getClassMethod([self class], @selector(systemFontOfSize:));
    // 然后交换类方法，交换两个方法的IMP指针，(IMP代表了方法的具体的实现）
    method_exchangeImplementations(newMethod, method);
    
    Method newBoldFontMethod = class_getClassMethod([self class], @selector(adjustBoldFont:));
    Method boldMethod = class_getClassMethod([self class], @selector(boldSystemFontOfSize:));
    method_exchangeImplementations(newBoldFontMethod, boldMethod);
    
    Method newSpecifiedFontMethod = class_getClassMethod([self class], @selector(adjustFontName:fontSize:));
    Method specifiedMethod = class_getClassMethod([self class], @selector(fontWithName:size:));
    method_exchangeImplementations(newSpecifiedFontMethod, specifiedMethod);
}

/** systemFontOfSize: */
+ (UIFont *)adjustFont:(CGFloat)fontSize {
    UIFont *newFont = nil;
    fontSize = [self adjustFontSize:fontSize];
    newFont = [UIFont adjustFont:fontSize];
    return newFont;
}

/** boldSystemFontOfSize: */
+ (UIFont *)adjustBoldFont:(CGFloat)fontSize {
    UIFont * newFont = nil;
    fontSize = [self adjustFontSize:fontSize];
    newFont = [UIFont adjustBoldFont:fontSize];
    return newFont;
}

/** fontWithName:size: */
+ (UIFont *)adjustFontName:(NSString *)fontName fontSize:(CGFloat)fontSize {
    UIFont * newFont = nil;
    fontSize = [self adjustFontSize:fontSize];
    newFont = [UIFont adjustFontName:fontName fontSize:fontSize];
    return newFont;
}

/** 适配字体大小 */
+ (CGFloat)adjustFontSize:(CGFloat)size {
    CGFloat screeHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (screeHeight < 1024) {
        CGFloat ratio = screenWidth / 375;
        CGFloat tempSize = size * ratio;
        return tempSize;
    } else {
        CGFloat ratio = screenWidth / 768;
        CGFloat tempSize = size * 1.3 * ratio;
        return tempSize;
    }
    return size;
}

@end


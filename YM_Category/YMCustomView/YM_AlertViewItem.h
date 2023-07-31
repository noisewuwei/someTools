//
//  YM_AlertViewItem.h
//  YM_AlertView
//
//  Created by 黄玉洲 on 2021/5/22.
//  Copyright © 2021 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 样式
@interface YM_AlertViewItem : NSObject

+ (instancetype)defaltWithTitle:(NSString *)title;

@property (strong, nonatomic) NSString * text;

// 默认：[UIColor colorWithRed:0.04 green:0.52 blue:1 alpha:1];
@property (strong, nonatomic) UIColor  * textColor;

// 默认：Arial 16.0f
@property (strong, nonatomic) UIFont   * textFont;


@end


NS_ASSUME_NONNULL_END

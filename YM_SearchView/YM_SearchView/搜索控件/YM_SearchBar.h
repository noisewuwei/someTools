//
//  YM_SearchBar.h
//  YM_SearchView
//
//  Created by 黄玉洲 on 2018/5/22.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YM_SearchBarDelegate <NSObject>

@optional
/**
 *  搜索关键字
 *
 *  @param keyword 关键字
 */
- (void)didSearchWithKeyword:(NSString *)keyword;

@end

@interface YM_SearchBar : UIView


@property (nonatomic, strong) NSString * placeHolder;   // 占位符
@property (nonatomic, assign) BOOL isChangeLocation;    // 是否允许改变占位符位置
@property (nonatomic, strong) UIColor * backgroundColor;// 背景色
@property (nonatomic, strong) UIImage * searchImage;    // 左侧图片
@property (nonatomic, strong) UIFont * font;            // 输入框的字体样式
@property (nonatomic, strong) UIButton * cancelBtn;     // 取消按钮（字体限制在两位以内）
@property (nonatomic, assign) id <YM_SearchBarDelegate>  delegate; // 代理


@end

//
//  UITableView+YMCategory.h
//  youqu
//
//  Created by 黄玉洲 on 2019/6/5.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, kTableViewType) {
    /** 不展示任何文本 默认 */
    kTableViewType_NoShow,
    /** 暂无数据*/
    kTableViewType_NoData,
    /** 轻触屏幕重试 */
    kTableViewType_TouchReload,
    /** 网络异常 */
    kTableViewType_NetworkError
};

typedef void(^TouchBlock)(void);

@interface UITableView (YMCategory)

/**
 自定义显示内容
 @param text 文本
 @param imageName 图片名
 */
- (void)showText:(NSString *)text imageName:(NSString *)imageName;

/**
 按类型显示内容
 @param type 类型名
 */
- (void)showTextWithType:(kTableViewType)type;

/** 隐藏文本和图片 */
- (void)hideTextAndImage;


/** 点击回调 */
@property (copy, nonatomic) TouchBlock touchBlock;

@end


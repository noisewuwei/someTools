//
//  UICollectionView+YMCategory.h
//  youqu
//
//  Created by 黄玉洲 on 2019/7/2.
//  Copyright © 2019年 TouchingApp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, kCollectionViewType) {
    /** 不展示任何文本 默认 */
    kCollectionViewType_NoShow,
    /** 暂无数据*/
    kCollectionViewType_NoData,
    /** 轻触屏幕重试 */
    kCollectionViewType_TouchReload,
    /** 网络异常 */
    kCollectionViewType_NetworkError
};

typedef void(^TouchBlock)(void);

@interface UICollectionView (YMCategory)

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
- (void)showTextWithType:(kCollectionViewType)type;

/** 隐藏文本和图片 */
- (void)hideTextAndImage;


/** 点击回调 */
@property (copy, nonatomic) TouchBlock touchBlock;

/** 占位标题 */
@property (copy, nonatomic) NSString * viewTitle;

/** 占位图片名 */
@property (copy, nonatomic) NSString * viewImageName;

@end


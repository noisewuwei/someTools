//
//  YM_TableViewCell.h
//
//  Created by 黄玉洲 on 2019/5/8.
//  Copyright © 2019年 Louis. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YMSideslipActionStyle) {
    YMSideslipActionStyle_Default = 0,
    /** 红底 */
    YMSideslipActionStyle_Destructive = YMSideslipActionStyle_Default,
    /** 灰底 */
    YMSideslipActionStyle_Normal
};

@interface YMSideslipCellAction : NSObject

+ (instancetype)rowActionWithStyle:(YMSideslipActionStyle)style
                             title:(nullable NSString *)title
                           handler:(void (^)(YMSideslipCellAction *action, NSIndexPath *indexPath))handler;

@property (nonatomic, readonly) YMSideslipActionStyle style;

/** 文字内容 */
@property (nonatomic, copy, nullable) NSString *title;

/** 按钮图片. 默认无图 */
@property (nonatomic, strong, nullable) UIImage *image;

/** 字体大小. 默认17 */
@property (nonatomic, assign) CGFloat fontSize;

/** 文字颜色. 默认白色 */
@property (nonatomic, strong, nullable) UIColor *titleColor;

/** 背景颜色. 根据状态进行颜色显示 */
@property (nonatomic, copy, nullable) UIColor *backgroundColor;

/** 内容左右间距. 默认15 */
@property (nonatomic, assign) CGFloat margin;

@end


@class YM_TableViewCell;
/** 代理 */
@protocol YMSideslipCellDelegate <NSObject>
@optional;

/**
 *  选中了侧滑按钮
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *  @param index        选中的是第几个action
 */
- (void)sideslipCell:(YM_TableViewCell *)sideslipCell
      rowAtIndexPath:(NSIndexPath *)indexPath
  didSelectedAtIndex:(NSInteger)index;

/**
 *  告知当前位置的cell是否需要侧滑按钮
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *
 *  @return YES 表示当前cell可以侧滑, NO 不可以
 */
- (BOOL)sideslipCell:(YM_TableViewCell *)sideslipCell
canSideslipRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  返回侧滑事件
 *
 *  @param sideslipCell 当前响应的cell
 *  @param indexPath    cell在tableView中的位置
 *
 *  @return 数组为空, 则没有侧滑事件
 */
- (NSArray<YMSideslipCellAction *> *)sideslipCell:(YM_TableViewCell *)sideslipCell
                editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;
@end


/** cell当前状态 */
typedef NS_ENUM(NSInteger, YMSideslipState) {
    /** 侧滑按钮未展示 */
    YMSideslipState_Hide,
    /** 侧滑按钮正在展示 */
    YMSideslipState_Showing,
    /** 侧滑按钮已展示 */
    YMSideslipState_Show
};

/** cell */
@interface YM_TableViewCell : UITableViewCell

/** 侧滑按钮容器视图 */
@property (strong, nonatomic) UIView * btnContainView;

/** 侧滑按钮高度 */
@property (assign, nonatomic) CGFloat sideslipBtnHeight;

/** 侧滑按钮协议 */
@property (nonatomic, weak) id <YMSideslipCellDelegate> delegate;

/** 侧滑时，主视图和侧滑按钮最大间隔，默认为30 */
@property (assign, nonatomic) CGFloat maxSlidesMargin;

/** 隐藏侧滑 */
- (void)hiddenSideslip;

#pragma mark - 用于重写
- (void)stateDidChange:(YMSideslipState)state;

@end


@interface UITableView (YMCategorySideslip)

/** 收起所有侧滑cell */
- (void)hiddenAllSideslip;

@end

NS_ASSUME_NONNULL_END

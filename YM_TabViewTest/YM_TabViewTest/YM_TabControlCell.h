//
//  YM_TabControlCell.h
//  DS_lottery
//
//  Created by 黄玉洲 on 2018/7/11.
//  Copyright © 2018年 海南达生实业有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YM_TabControlCellDelegate;
static NSString * YM_TabControlCellID = @"YM_TabControlCellID";
@interface YM_TabControlCell : UICollectionViewCell

/** 指示标 */
@property (strong, nonatomic, readonly) UIView * indicatorView;

@property (assign, nonatomic) BOOL isShowLine;

@property (assign, nonatomic) NSInteger index;

@property (weak, nonatomic) id <YM_TabControlCellDelegate> cellDelegate;

@end


@protocol YM_TabControlCellDelegate <NSObject>
@optional

/**
 线条颜色
 @return 颜色
 */
- (UIColor *)ym_lineColorWithIndex:(NSInteger)index;

/**
 线条高度
 @return 高度
 */
- (CGFloat)ym_lineHeightWithIndex:(NSInteger)index;

@end

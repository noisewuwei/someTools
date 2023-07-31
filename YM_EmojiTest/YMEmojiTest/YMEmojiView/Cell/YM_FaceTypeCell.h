//
//  YM_FaceTypeCell.h
//  YMEmojiTest
//
//  Created by 黄玉洲 on 2018/6/19.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * YM_FaceTypeCellID = @"YM_FaceTypeCell";

/** 表情类型cell */
@interface YM_FaceTypeCell : UICollectionViewCell

/** 表情类型 */
@property (copy, nonatomic) NSString * emojiType;

/** 是否选中 */
@property (assign, nonatomic) BOOL     isSelected;
@end

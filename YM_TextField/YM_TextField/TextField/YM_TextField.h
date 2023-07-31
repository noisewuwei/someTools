//
//  YM_TextField.h
//  YM_TextField
//
//  Created by 黄玉洲 on 2018/11/4.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YM_TextField : UITextField

/** 限制中文输入 */
@property (assign, nonatomic) BOOL isLimitChinese;

@end

NS_ASSUME_NONNULL_END

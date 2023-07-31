//
//  YM_DownloadProgressView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_DownloadProgressView : UIView

/** 进度 */
@property (nonatomic, assign) CGFloat progress;

/** 重置状态 */
- (void)resetState;

/** 开始动画 */
- (void)startAnima;

@end

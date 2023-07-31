//
//  YM_BaseTool.h
//
//
//  Created by 黄玉洲 on 2019/2/14.
//  Copyright © 2019年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_BaseNavigationController : UINavigationController <UINavigationControllerDelegate>

/* 拖拽开关(默认开启) */
@property (assign, nonatomic) BOOL  isPan;

/* 全局侧拉（默认为NO，即只有左侧100px可以发生侧拉触摸） */
@property (assign, nonatomic) BOOL  globalTouch;

/// 模态风格
@property (assign, nonatomic) UIModalPresentationStyle modalStyle;

@end

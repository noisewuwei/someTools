//
//  YM_SliderView.h
//  YM_SliderView
//
//  Created by 黄玉洲 on 2018/6/20.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YM_SliderView : UIControl

/**
 *  初始化
 *
 *  @param frame 控件大小
 *
 *  @return UISlider对象
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  进度条、滑块样式 滑块状态
 */
@property (nonatomic,assign) BOOL          thumbOn;                     // 跟踪当前滑块的状态
@property (nonatomic,strong) UIImageView * thumbImageView;              // 滑块
@property (nonatomic,strong) UIImage     * imageOfThumbImageView;       // 滑块的图片样式
@property (nonatomic,strong) UIImageView * trackImageViewNormal;        // 滑条未完成进度状态
@property (nonatomic,strong) UIImageView * trackImageViewHighlighted;   // 滑条已完成进度状态


/**
 *  引用系统Slide相同的属性
 */
@property (nonatomic,assign)     float value;                           // 默认为0.0. 这个值被控制在最大值/最小值内
@property (nonatomic,assign)     float minimumValue;                    // 默认为0.0. 表示最小值
@property (nonatomic,assign)     float maximumValue;                    // 默认为1.0. 表示最大值
@property (nonatomic,getter=isContinuous) BOOL continuous;              // 如果设置,拖拽产生值的改变,默认 = YES;


/**
 *  使用这些属性来配置UILabel的字体和颜色
 */
@property (nonatomic,strong) UILabel *labelOnThumb;                     // 显示滑块之中的字体,随着移动可以改变它的字体、颜色和其他属性,默认隐藏
@property (nonatomic,strong) UILabel *labelAboveThumb;                  // 显示滑块之上的字体,随着移动可以改变它的字体、颜色和其他属性,默认隐藏
@property (nonatomic,assign) int decimalPlaces;                         // 用来显示滑块之中、之上的Label所显示的数字的小数点位数

@end

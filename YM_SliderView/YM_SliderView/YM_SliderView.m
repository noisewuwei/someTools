//
//  YM_SliderView.m
//  YM_SliderView
//
//  Created by 黄玉洲 on 2018/6/20.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_SliderView.h"

// 如果您的预编译和这里的预编译相同，只需要把里几个预编译删掉即可
// 但要保证该类可以获取到您的预编译
#define MINX(X) CGRectGetMinX(X)
#define MINY(Y) CGRectGetMinY(Y)

#define MAXX(X) CGRectGetMaxX(X)
#define MAXY(Y) CGRectGetMaxY(Y)

#define MIDX(X) CGRectGetMidX(X)
#define MIDY(Y) CGRectGetMidY(Y)

#define WIDTH(width) CGRectGetWidth(width)
#define HEIGHT(height) CGRectGetHeight(height)
@interface YM_SliderView ()
{
    CGRect  _selfRect;      // 记录最初的frame值
}

@end

@implementation YM_SliderView


- (void)dealloc
{
    [_thumbImageView removeObserver:self forKeyPath:@"center"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 初始化控件
        [self initUI];
        
        // 初始化界面
        self.backgroundColor = [UIColor clearColor];
        self.layer.frame = CGRectMake(frame.origin.x,
                                      frame.origin.y,
                                      frame.size.width,
                                      frame.size.height + _thumbImageView.image.size.height);
        
        // 观察者观察变化
        [_thumbImageView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark - 初始化
/**
 *  初始化
 */
- (void)initUI
{
    // 默认属性
    _value = 0.f;
    _minimumValue = 0.f;
    _maximumValue = 100.f;
    _continuous = YES;
    _thumbOn = NO;
    _decimalPlaces = 0;
    
    // 未完成进度状态
    _trackImageViewNormal = [[UIImageView alloc] init];
    _trackImageViewNormal.backgroundColor = [UIColor grayColor];
    [self addSubview:_trackImageViewNormal];
    
    // 完成进度状态
    _trackImageViewHighlighted = [[UIImageView alloc] init];
    _trackImageViewHighlighted.backgroundColor = [UIColor blueColor];
    [self addSubview:_trackImageViewHighlighted];
    
    // 滑块按钮
    _thumbImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SliderTrack"]];
    [self addSubview:_thumbImageView];
    
    // 滑块之中的Label
    _labelOnThumb = [[UILabel alloc] init];
    _labelOnThumb.backgroundColor = [UIColor clearColor];
    _labelOnThumb.textAlignment = NSTextAlignmentCenter;
    _labelOnThumb.text = [NSString stringWithFormat:[self valueStringFormat],_value];
    _labelOnThumb.textColor = [UIColor orangeColor];
    _labelOnThumb.hidden = YES;
    [self addSubview:_labelOnThumb];
    
    // 滑块之上的Label
    _labelAboveThumb = [[UILabel alloc] init];
    _labelAboveThumb.backgroundColor = [UIColor clearColor];
    _labelAboveThumb.textAlignment = NSTextAlignmentCenter;
    _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat],_value];
    _labelAboveThumb.textColor = [UIColor blueColor];
    _labelAboveThumb.hidden = YES;
    [self addSubview:_labelAboveThumb];
}

- (void)layoutSubviews
{
    // 配置进度条的位置、大小
    _trackImageViewNormal.frame = _selfRect;
    _trackImageViewNormal.center = CGPointMake(self.layer.frame.size.width / 2,
                                               self.layer.frame.size.height / 2);
    _trackImageViewHighlighted.frame = _selfRect;
    _trackImageViewHighlighted.center = CGPointMake(self.layer.frame.size.width / 2,
                                                    self.layer.frame.size.height / 2);
    
    // 获取滑块图片的高度
    CGFloat thumbHeight = _thumbImageView.image.size.height;
    // 获取滑块图片的宽度
    CGFloat thumbWidth = _thumbImageView.image.size.width;
    // 配置滑块的大小
    _thumbImageView.frame = CGRectMake(0, 0, thumbWidth, thumbHeight);
    // 配置滑块的中心位置
    _thumbImageView.center = CGPointMake([self pointXForValue:_value],
                                         MIDY(_trackImageViewNormal.frame));
    
    // 配置滑块之中、之上UILabel的大小和位置
    _labelOnThumb.frame = _thumbImageView.frame;
    _labelAboveThumb.frame = CGRectMake(MINX(_labelOnThumb.frame),
                                        MINY(_labelOnThumb.frame) -
                                        HEIGHT(_labelOnThumb.frame) * 0.6,
                                        WIDTH(_labelOnThumb.frame),
                                        HEIGHT(_labelOnThumb.frame));
}

- (void)drawRect:(CGRect)rect
{
    // 将滑块中的Label中心绑定在滑块的中心上
    _labelOnThumb.center = _thumbImageView.center;
    // 绑定滑块之上的Label中心在滑块之上
    _labelAboveThumb.center = CGPointMake(_thumbImageView.center.x,
                                          _thumbImageView.center.y -
                                          HEIGHT(_labelAboveThumb.frame) * 0.6);
}

#pragma mark - setter
// 设置frame
- (void)setFrame:(CGRect)frame
{
    // 记录frame
    _selfRect = frame;
    
    // 在设置的frame基础上加上按钮的高度 防止按钮过大超过视图范围不能够触摸
    self.layer.frame = CGRectMake(frame.origin.x,
                                  frame.origin.y,
                                  frame.size.width,
                                  frame.size.height + _thumbImageView.image.size.height);
}

// 设置value
- (void)setValue:(float)value
{
    // 当设值大于最大值或小于最小值时
    if (value < _minimumValue || value > _maximumValue) {
        return;
    }
    
    // 获取value并配置滑块的中心点
    _value = value;
    _thumbImageView.center = CGPointMake([self pointXForValue:value],
                                         _thumbImageView.center.y);
    
    // 改变显示的值
    _labelOnThumb.text = [NSString stringWithFormat:[self valueStringFormat],_value];
    _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat],value];
    
    [self setNeedsDisplay];
}

// 设置滑块图片
- (void)setImageOfThumbImageView:(UIImage *)imageOfThumbImageView
{
    if (imageOfThumbImageView) {
        _thumbImageView.image = imageOfThumbImageView;
        self.layer.frame = CGRectMake(self.layer.frame.origin.x,
                                      self.layer.frame.origin.y,
                                      self.layer.frame.size.width,
                                      _selfRect.size.height + imageOfThumbImageView.size.height);
    }
}

#pragma  mark - Touch
// 触摸开始瞬间
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    // 获取当前触摸的点
    CGPoint touchPoint = [touch locationInView:self];
    // 判断当前触摸点是否在滑块上
    if (CGRectContainsPoint(_thumbImageView.frame, touchPoint)) {
        _thumbOn = YES;
    }else{
        _thumbOn = NO;
    }
    return YES;
}

// 触摸结束瞬间
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_thumbOn) {
        // 获取当前滑块的中心点位置
        _value = [self valueForPointX:_thumbImageView.center.x];
        _labelOnThumb.text = [NSString stringWithFormat:[self valueStringFormat],_value];
        _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat],_value];
        // 发送与事件相关联的操作
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    _thumbOn = NO;
}

// 触摸过程
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!_thumbOn) {
        return YES;
    }
    // 获取当前触摸的点
    CGPoint touchPoint = [touch locationInView:self];
    // 配置滑块的位置（如果触摸点在）
    _thumbImageView.center = CGPointMake(MIN(MAX([self pointXForValue:_minimumValue], touchPoint.x),
                                             [self pointXForValue:_maximumValue]),
                                         _thumbImageView.center.y);
    
    
    _value = [self valueForPointX:_thumbImageView.center.x];
    _labelOnThumb.text = [NSString stringWithFormat:[self valueStringFormat],_value];
    _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat],_value];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
    return YES;
}

#pragma mark - 自定义方法
/**
 *  返回当前value的NSString格式
 *
 *  @return 返回Value
 */
- (NSString *)valueStringFormat
{
    return [NSString stringWithFormat:@"%%.%df",_decimalPlaces];
}

/**
 *  根据value获取X坐标
 *  @param value 当前的value值
 *  @return 返回x坐标
 */
- (CGFloat)pointXForValue:(CGFloat)value
{
    // x的坐标等于当前value值在滑条最大值的比率
    return self.frame.size.width * (value - _minimumValue) / (_maximumValue - _minimumValue);
}

/**
 *  根据X坐标获取当前value
 *
 *  @param pointX 当前的点坐标的x
 *
 *  @return 返回value
 */
- (CGFloat)valueForPointX:(CGFloat)pointX
{
    return _minimumValue + pointX / WIDTH(self.frame) * (_maximumValue - _minimumValue);
}

#pragma mark - 观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 进度条
    _trackImageViewHighlighted.frame = CGRectMake(_trackImageViewNormal.frame.origin.x,
                                                  _trackImageViewNormal.frame.origin.y,
                                                  _thumbImageView.center.x,
                                                  HEIGHT(_selfRect));
    
    // 滑块之中的Label
    _labelOnThumb.frame = _thumbImageView.frame;
    
    // 滑块之上的Label
    _labelAboveThumb.frame = CGRectMake(MINX(_labelOnThumb.frame),
                                        MINY(_labelOnThumb.frame) -
                                        HEIGHT(_labelOnThumb.frame) * 0.6,
                                        WIDTH(_labelOnThumb.frame),
                                        HEIGHT(_labelOnThumb.frame));
}




@end

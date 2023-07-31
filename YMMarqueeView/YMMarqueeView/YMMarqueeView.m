//
//  YMMarqueeView.m
//  YMMarqueeView
//
//  Created by 黄玉洲 on 2019/7/31.
//  Copyright © 2019年 黄玉洲. All rights reserved.
//

#import "YMMarqueeView.h"
#import <CoreText/CoreText.h>



#pragma mark - NSString + YMMarqueeView
static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}
@implementation NSString (YMMarqueeView)

#pragma mark - 计算字符
/**
 获取字符串所需要的高度
 @param size           大小控制
 @param font           字体
 @param numberOfLines  限制行数（如果是0则不限制行数）
 @return 所需高度
 */
- (CGSize)ymStringForSize:(CGSize)size
                     font:(UIFont *)font
   limitedToNumberOfLines:(NSInteger)numberOfLines {
    
    if (self.length == 0) {
        return CGSizeMake(0, 0);
    }
    
    if (!font) {
        return CGSizeMake(0, 0);
    }
    
    // 获取NSAttributedString
    NSDictionary * attributedDic = NSAttributedStringAttributesFromLabel(font);
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:self attributes:attributedDic];
    
    // 计算适配高度
    CGSize fitSize = [self sizeThatFitsAttributedString:attributedString
                                     withConstraints:CGSizeMake(size.width, size.height)
                              limitedToNumberOfLines:numberOfLines];
    
    // 向上取整数并返回
    return fitSize;
}

/**
 根据'NSAttributedString'计算字符串所需高度
 @param attributedString 字符串属性
 @param size             控件限定大小
 @param numberOfLines    限定的行数
 @return 适配后的大小
 */
- (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attributedString
                       withConstraints:(CGSize)size
                limitedToNumberOfLines:(NSUInteger)numberOfLines
{
    if (!attributedString ||
        attributedString.length == 0) {
        return CGSizeZero;
    }
    
    /**
     https://blog.csdn.net/mangosnow/article/details/37700553
     CTFramesetter 是使用 Core Text 绘制时最重要的类。
     它管理您的字体引用和文本绘制帧。
     目前您需要了解 CTFramesetterCreateWithAttributedString 通过应用属性化文本创建 CTFramesetter。
     */
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    
    CGSize calculatedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(framesetter, attributedString, size, numberOfLines);
    
    CFRelease(framesetter);
    
    return calculatedSize;
}

#pragma mark - private 函数
/**
 计算字符串所需高度
 @param framesetter      CTFramesetterRef
 @param attributedString NSAttributedString
 @param size             限定的大小
 @param numberOfLines    限定的行数
 @return 适配后的大小
 */
static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    CFRange rangeToSize = CFRangeMake(0, (CFIndex)[attributedString length]);
    CGSize constraints = CGSizeMake(size.width, MAXFLOAT);
    
    // 如果只限制为一行，则适配的尺寸是这一整行的宽度
    if (numberOfLines == 1) {
        constraints = CGSizeMake(MAXFLOAT, MAXFLOAT);
    }
    // 如果标签的行数大于1，则将范围限制为已设置的行数
    else if (numberOfLines > 0) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, MAXFLOAT));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN((CFIndex)numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            rangeToSize = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        
        CFRelease(frame);
        CGPathRelease(path);
    }
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    
    return CGSizeMake(CGFloat_ceil(suggestedSize.width), CGFloat_ceil(suggestedSize.height));
}

/**
 获取默认情况下的'NSAttributedString'属性字典
 @param font 指定的字体样式
 @return 默认的'NSAttributedString'属性字典
 */
static inline NSDictionary * NSAttributedStringAttributesFromLabel(UIFont *font) {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    [mutableAttributes setObject:font forKey:(NSString *)kCTFontAttributeName];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = font.lineHeight;
    paragraphStyle.maximumLineHeight = font.lineHeight;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

@end

#pragma mark - UIView + YMMarqueeView
@implementation UIView (YMMarqueeView)

/** 跑马灯视图复制 */
- (UIView *)copyMarqueeView {
    NSError * error = nil;
    NSData * archivedData = nil;
    UIView * copyView = nil;
    if (@available(iOS 11.0, *)) {
        archivedData = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:NO error:&error];

        if (error) {
            return nil;
        }
        
        error = nil;
        copyView = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:archivedData error:&error];
        if (error) {
            return nil;
        }
    } else {
        archivedData = [NSKeyedArchiver archivedDataWithRootObject:self];
        
        copyView = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    }
    return copyView;
}

@end

#pragma mark - YMMarqueeGradientView(模糊效果)
@interface YMMarqueeGradientView : UIView

@property (strong, nonatomic) CAGradientLayer * gradientMask;

@property (strong, nonatomic) UIColor * gradientColor;

@property (assign, nonatomic) CGPoint   startPoint;
@property (assign, nonatomic) CGPoint   endPoint;
@property (strong, nonatomic) NSArray * colors;

@end

@implementation YMMarqueeGradientView

- (instancetype)init {
    if (self = [super init]) {
     
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.layer addSublayer:self.gradientMask];
}

- (CAGradientLayer *)gradientMask {
    if (!_gradientMask) {
        _gradientMask = [CAGradientLayer layer];
        _gradientMask.frame = self.bounds;
        _gradientMask.startPoint = _startPoint;
        _gradientMask.endPoint = _endPoint;
        _gradientMask.colors = _colors;
    }
    return _gradientMask;
}

@end

#pragma mark - YMMarqueeView
@interface YMMarqueeView ()

/** 存放要展示的视图的容器 */
@property (strong, nonatomic) UIView * containerView;

/** 跑马灯计时器 */
@property (strong, nonatomic) CADisplayLink * marqueeDisplayLink;

/** 是否反复 */
@property (assign, nonatomic) BOOL isReversing;

@property (strong, nonatomic) YMMarqueeGradientView * leftGradientView;
@property (strong, nonatomic) YMMarqueeGradientView * rightGradientView;
@property (strong, nonatomic) YMMarqueeGradientView * topGradientView;
@property (strong, nonatomic) YMMarqueeGradientView * bottomGradientView;

@end

@implementation YMMarqueeView

- (void)dealloc {
    _contentViewFrameConfigWhenCantMarquee = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        // 初始化默认值
        _direction = kMarqueeDirection_Left;
        _contentMargin = 12;
        _frameInterval = 1;
        _pointsPerFrame = 0.5;
        _gradientSize = 5;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self layoutView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_contentView) {
        return;
    }
    
    // 移除旧的视图
    for (UIView * view in _containerView.subviews) {
        [view removeFromSuperview];
    }
    
    // 对视图进行大小适配
    [self contentViewFit];
    [_containerView addSubview:_contentView];
    
    // 设置容器的大小
    // 如果是双向来回的，只需要分配一个视图大小
    // 如果是单向的，要分配两个视图的大小再加上视图的间隔
    CGFloat width = 0;
    CGFloat height = 0;
    if (_direction == kMarqueeDirection_HorizontalReset) {
        width = _contentView.bounds.size.width;
        height = self.bounds.size.height;
    } else if (_direction == kMarqueeDirection_VerticalReset) {
        width = self.bounds.size.width;
        height = _contentView.bounds.size.height;
    } else if (_direction == kMarqueeDirection_Left ||
               _direction == kMarqueeDirection_Right) {
        width = _contentView.bounds.size.width*2 + _contentMargin;
        height = self.bounds.size.height;
    } else {
        width = self.bounds.size.width;
        height = _contentView.bounds.size.height*2 + _contentMargin;
    }
    
    _containerView.frame = CGRectMake(0, 0, width, height);
    
    // 添加渐变效果
    if (_gradientColors && _gradientColors.count >= 2) {
        if (_direction == kMarqueeDirection_Left ||
            _direction == kMarqueeDirection_Right) {
            [self addSubview:self.leftGradientView];
            [self addSubview:self.rightGradientView];
        } else if (_direction == kMarqueeDirection_Top ||
                   _direction == kMarqueeDirection_Bottom) {
            [self addSubview:self.topGradientView];
            [self addSubview:self.bottomGradientView];
        }
    }
    
    // 获取所需的宽度和高度
    CGFloat viewWidth = _contentView.bounds.size.width;
    CGFloat viewHeight = _contentView.bounds.size.height;
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    // 设置所需宽度和高度，并确定是否使用两个视图
    if (_direction < kMarqueeDirection_Top) {
        if (viewWidth > selfWidth) {
            _contentView.frame = CGRectMake(0, 0, viewWidth, selfHeight);
            // 需要两个视图进行跑马灯展示
            if (_direction != kMarqueeDirection_HorizontalReset) {
                // UIView是没有遵从拷贝协议的。
                // 可以通过UIView支持NSCoding协议，间接来复制一个视图
                UIView * otherContentView = [_contentView copyMarqueeView];
                otherContentView.frame = CGRectMake(viewWidth + _contentMargin, 0, viewWidth, selfHeight);
                [_containerView addSubview:otherContentView];
            }
            [self startMarquee];
        } else {
            if (_contentViewFrameConfigWhenCantMarquee != nil) {
                _contentViewFrameConfigWhenCantMarquee(_contentView);
            } else {
                _contentView.frame = CGRectMake(0, 0, viewWidth, selfHeight);
            }
            [self stopMarquee];
        }
    } else {
        if (viewHeight > selfHeight) {
            _contentView.frame = CGRectMake(0, 0, selfWidth, viewHeight);
            // 需要两个视图进行跑马灯展示
            if (_direction != kMarqueeDirection_HorizontalReset) {
                // UIView是没有遵从拷贝协议的。
                // 可以通过UIView支持NSCoding协议，间接来复制一个视图
                UIView * otherContentView = [_contentView copyMarqueeView];
                otherContentView.frame = CGRectMake(0, viewHeight + _contentMargin, selfWidth, viewHeight);
                [_containerView addSubview:otherContentView];
            }
            [self startMarquee];
        } else {
            if (_contentViewFrameConfigWhenCantMarquee != nil) {
                _contentViewFrameConfigWhenCantMarquee(_contentView);
            } else {
                _contentView.frame = CGRectMake(0, 0, selfWidth, viewHeight);
            }
            [self stopMarquee];
        }
    }
}

/** 如果你的contentView的内容在初始化的时候，无法确定。
    需要通过网络等延迟获取，那么在内容赋值之后，在调用该方法即可。 */
- (void)reloadData {
    [self setNeedsLayout];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = true;
    [self addSubview:self.containerView];
}

#pragma mark - override
- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 当视图将被移除父视图的时候，newSuperview就为nil。
    // 在这个时候，停止掉CADisplayLink，断开循环引用，视图就可以被正确释放掉了。
    if (!newSuperview) {
        [self stopMarquee];
    }
}

#pragma mark - 跑马灯操作
/** 开始跑马灯 */
- (void)startMarquee {
    [self stopMarquee];
    
    if (_direction == kMarqueeDirection_Right) {
        CGRect frame = _containerView.frame;
        frame.origin.x = self.bounds.size.width - frame.size.width;
        _containerView.frame = frame;
    }
    
    _marqueeDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(processMarquee)];
    _marqueeDisplayLink.frameInterval = self.frameInterval;
    [_marqueeDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    _leftGradientView.hidden = NO;
    _rightGradientView.hidden = NO;
    _topGradientView.hidden = NO;
    _bottomGradientView.hidden = NO;
}

/** 停止跑马灯 */
- (void)stopMarquee {
    [_marqueeDisplayLink invalidate];
    _marqueeDisplayLink = nil;
    
    _leftGradientView.hidden = YES;
    _rightGradientView.hidden = YES;
    _topGradientView.hidden = YES;
    _bottomGradientView.hidden = YES;
}

- (void)processMarquee {
    CGRect frame = _containerView.frame;
    
    switch (_direction) {
        case kMarqueeDirection_Left: {
            CGFloat targetX = -(_contentView.bounds.size.width + _contentMargin);
            if (frame.origin.x <= targetX) {
                frame.origin.x = 0;
                _containerView.frame = frame;
            } else {
                frame.origin.x -= _pointsPerFrame;
                if (frame.origin.x < targetX) {
                    frame.origin.x = targetX;
                }
                _containerView.frame = frame;
            }
        }
            break;
        case kMarqueeDirection_Right: {
            CGFloat targetX = self.bounds.size.width - _contentView.bounds.size.width;
            if (frame.origin.x >= targetX) {
                frame.origin.x = self.bounds.size.width -_containerView.bounds.size.width;
                _containerView.frame = frame;
            }else {
                frame.origin.x += _pointsPerFrame;
                if (frame.origin.x > targetX) {
                    frame.origin.x = targetX;
                }
                _containerView.frame = frame;
            }
        }
            break;
        case kMarqueeDirection_HorizontalReset: {
            CGFloat horizontalMargin = 10;
            if (_isReversing) {
                CGFloat targetX = horizontalMargin;
                if (frame.origin.x > targetX) {
                    frame.origin.x = horizontalMargin;
                    _containerView.frame = frame;
                    _isReversing = false;
                }else {
                    frame.origin.x += _pointsPerFrame;
                    if (frame.origin.x > horizontalMargin) {
                        frame.origin.x = horizontalMargin;
                        _isReversing = false;
                    }
                    _containerView.frame = frame;
                }
            }else {
                CGFloat targetX = self.bounds.size.width - _containerView.bounds.size.width - horizontalMargin;
                if (frame.origin.x <= targetX) {
                    _isReversing = true;
                }else {
                    frame.origin.x -= _pointsPerFrame;
                    if (frame.origin.x < targetX) {
                        frame.origin.x = targetX;
                        _isReversing = true;
                    }
                    _containerView.frame = frame;
                }
            }
        }
            break;
        case kMarqueeDirection_Top: {
            CGFloat targetY = -(_contentView.bounds.size.height + _contentMargin);
            if (frame.origin.y <= targetY) {
                frame.origin.y = 0;
                _containerView.frame = frame;
            } else {
                frame.origin.y -= _pointsPerFrame;
                if (frame.origin.y < targetY) {
                    frame.origin.y = targetY;
                }
                _containerView.frame = frame;
            }
        }
            break;
        case kMarqueeDirection_Bottom: {
            CGFloat targetY = self.bounds.size.height - _contentView.bounds.size.height;
            if (frame.origin.y >= targetY) {
                frame.origin.y = self.bounds.size.height -_containerView.bounds.size.height;
                _containerView.frame = frame;
            }else {
                frame.origin.y += _pointsPerFrame;
                if (frame.origin.y > targetY) {
                    frame.origin.y = targetY;
                }
                _containerView.frame = frame;
            }
        }
            break;
        case kMarqueeDirection_VerticalReset: {
            CGFloat verticalMargin = 10;
            if (_isReversing) {
                CGFloat targetY = verticalMargin;
                if (frame.origin.y > targetY) {
                    frame.origin.y = 0;
                    _containerView.frame = frame;
                    _isReversing = false;
                }else {
                    frame.origin.y += _pointsPerFrame;
                    if (frame.origin.y > verticalMargin) {
                        frame.origin.y = verticalMargin;
                        _isReversing = false;
                    }
                    _containerView.frame = frame;
                }
            }else {
                CGFloat targetY = self.bounds.size.height - _containerView.bounds.size.height - verticalMargin;
                if (frame.origin.y <= targetY) {
                    _isReversing = true;
                }else {
                    frame.origin.y -= _pointsPerFrame;
                    if (frame.origin.y < targetY) {
                        frame.origin.y = targetY;
                        _isReversing = true;
                    }
                    _containerView.frame = frame;
                }
            }
        }
            break;
    }
}

#pragma mark - 适配大小
- (void)contentViewFit {
    if ([_contentView isKindOfClass:[UILabel class]]) {
        UILabel * label = [UILabel new];
        label = (UILabel *)_contentView;
        NSString * content = label.text;
        UIFont * font = label.font;
        CGSize fitSize = CGSizeZero;
        if (_direction == kMarqueeDirection_Left ||
            _direction == kMarqueeDirection_Right ||
            _direction == kMarqueeDirection_HorizontalReset) {
            fitSize = [content ymStringForSize:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height) font:font limitedToNumberOfLines:label.numberOfLines];
            fitSize = CGSizeMake(fitSize.width, self.bounds.size.height);
        } else {
            fitSize = [content ymStringForSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) font:font limitedToNumberOfLines:0];
            fitSize = CGSizeMake(self.bounds.size.width, fitSize.height);
            label.numberOfLines = 0;
        }
        CGRect frame = _contentView.frame;
        frame.size = fitSize;
        _contentView.frame = frame;
    } else {
        [_contentView sizeToFit];
    }
}

#pragma mark - setter
- (void)setContentView:(UIView *)contentView {
    if (![_contentView isEqual:contentView]) {
        _contentView = contentView;
        [self setNeedsLayout];
    }
}

#pragma mark - 懒加载
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (YMMarqueeGradientView *)leftGradientView {
    if (!_leftGradientView) {
        _leftGradientView = [YMMarqueeGradientView new];
        _leftGradientView.frame = CGRectMake(0, 0, 5, self.bounds.size.height);
        _leftGradientView.startPoint = CGPointMake(0, 0.5);
        _leftGradientView.endPoint = CGPointMake(1, 0.5);
        _leftGradientView.colors = _gradientColors;
        _leftGradientView.hidden = YES;
    }
    return _leftGradientView;
}

- (YMMarqueeGradientView *)rightGradientView {
    if (!_rightGradientView) {
        _rightGradientView = [YMMarqueeGradientView new];
        _rightGradientView.frame = CGRectMake(self.bounds.size.width - _gradientSize, 0, _gradientSize, self.bounds.size.height);
        _rightGradientView.startPoint = CGPointMake(1, 0.5);
        _rightGradientView.endPoint = CGPointMake(0, 0.5);
        _rightGradientView.colors = _gradientColors;
        _rightGradientView.hidden = YES;
    }
    return _rightGradientView;
}

- (YMMarqueeGradientView *)topGradientView {
    if (!_topGradientView) {
        _topGradientView = [YMMarqueeGradientView new];
        _topGradientView.frame = CGRectMake(0, 0, self.bounds.size.width, _gradientSize);
        _topGradientView.startPoint = CGPointMake(0.5, 0);
        _topGradientView.endPoint = CGPointMake(0.5, 1);
        _topGradientView.colors = _gradientColors;
        _topGradientView.hidden = YES;
    }
    return _topGradientView;
}

- (YMMarqueeGradientView *)bottomGradientView {
    if (!_bottomGradientView) {
        _bottomGradientView = [YMMarqueeGradientView new];
        _bottomGradientView.frame = CGRectMake(0, self.bounds.size.height - _gradientSize, self.bounds.size.width, _gradientSize);
        _bottomGradientView.startPoint = CGPointMake(0.5, 1);
        _bottomGradientView.endPoint = CGPointMake(0.5, 0);
        _bottomGradientView.colors = _gradientColors;
        _bottomGradientView.hidden = YES;
    }
    return _bottomGradientView;
}


@end

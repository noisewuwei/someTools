//
//  UIButton+YMCategory.m
//  YM_Category
//
//  Created by huangyuzhou on 2018/9/4.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "UIButton+YMCategory.h"
#import "NSObject+YMCategory.h"
#import "CABasicAnimation+YMCategory.h"
#import "UIImage+YMCategory.h"
#import "UIColor+YMCategory.h"
#import <objc/runtime.h>

#define YMButtonWeakSelf  \
__weak __typeof(self) weakSelf = self;
//@weakify(self);

/** strongSelf */
#define YMButtonStrongSelf \
__strong __typeof(weakSelf) self = weakSelf;

@implementation UIButton (YMCategory)

/// 便利构造
/// 注意：一定要先设置UIControlStateNormal再设置UIControlStateHighlighted
/// @param buttonType 按钮类型
/// @param isSetup 是否设置默认高亮标题颜色
/// @param alpha 透明度
+ (instancetype)buttonWithType:(UIButtonType)buttonType isSetupHighlight:(BOOL)isSetup alpha:(CGFloat)alpha {
    UIButton * button = [UIButton buttonWithType:buttonType];
    if (isSetup) {
        button.allowHighlight = isSetup;
        button.highlightAlpha = alpha;
    }
    return button;
}

/// 便利构造
+ (instancetype)buttonWithTitle:(NSString *)title
                          image:(UIImage *)image
                      backImage:(UIImage *)backImage
                 highlightAlpha:(CGFloat)alpha {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button
    .ymTitle(title, UIControlStateNormal)
    .ymTitleColor([UIColor whiteColor], UIControlStateNormal)
    .ymImage(image, UIControlStateNormal)
    .ymBackImage(backImage, UIControlStateNormal);
    
    if (alpha != 1) {
        button.ymTitleColor([UIColor whiteColor].ymAlpha(alpha), UIControlStateHighlighted);
        if (image) {
            button.ymImage(image.ymAlpha(alpha), UIControlStateHighlighted);
        }
        if (backImage) {
            button.ymBackImage(backImage.ymAlpha(alpha), UIControlStateHighlighted);
        }
    }
                         
    return button;
}

// 利用UIButton的titleEdgeInsets和imageEdgeInsets来实现文字和图片的自由排列
// 注意：这个方法需要在设置图片和文字之后才可以调用，且button的大小要大于 图片大小+文字大小+spacing
#pragma mark - 按钮图文风格
static char kImagePositionKey;
static char kImageSpacingKey;
- (UIButton *(^)(YM_ImagePosition, CGFloat))ymPosition {
    return ^UIButton * (YM_ImagePosition positionValue, CGFloat spaceValue) {
        //        [self setProperty:@(positionValue) key:&kImagePositionKey];
        self.setProperty(&kImagePositionKey, @(positionValue));
        self.setProperty(&kImageSpacingKey, @(spaceValue));
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            [self updateImageTextPosition];
        });
        return self;
    };
}

/** 更新图文位置 */
- (void)updateImageTextPosition {
    CGFloat space = [self.getProperty(&kImageSpacingKey) floatValue];
    CGFloat image_w = self.imageView.image.size.width;
    CGFloat image_h = self.imageView.image.size.height;
    CGFloat label_w =  self.titleLabel.bounds.size.width;
    CGFloat label_h =  self.titleLabel.bounds.size.height;
    CGFloat trueLabW = [self.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    
    // https://www.jianshu.com/p/f521505beed9
    // 原始坐标X（图文左右排列）
    // Original_Image_X = (W - W_Image - W_Label) / 2
    // Original_Label_X = (W - W_Image - W_Label) / 2 + W_Image
    
    // 左文右图：
    // After_Image_X = (W - W_Image - W_Label - Space) / 2 + W_Label + Space
    // After_Label_X = (W - W_Image - W_Label - Space) / 2
    // ==> imageOffset = Original - After => W_Label + Space/2
    // ==> labelOffset = Original - After => W_Image + Space/2
    
    // 左图右文
    // After_Image_X = (W - W_Image - W_Label - Space) / 2
    // After_Label_X = (W - W_Image - W_Label - Space) / 2 + W_Image + Space
    // ==> imageOffset = Original - After => -Space/2
    // ==> labelOffset = Original - After => -Space/2
    
    // 原始坐标X、Y（图文左右上下）
    // Original_Image_X = (W - W_Image - W_Label) / 2
    // Original_Image_Y = (H - H_Image) / 2
    // Original_Label_X = (W - W_Image - W_Label) / 2 + W_Image
    // Original_Label_Y = (H - H_Label) / 2
    
    // 上图下文
    // After_Image_X = (W - W_Image) / 2
    // After_Image_Y = (H - H_Image - H_Label - Space) / 2
    // After_Label_X = (W - W_Label) / 2
    // After_Label_Y = (H - H_Image - H_Label - Space) / 2 + Space + H_Image
    // ==> imageOffsetX = OriginalX - AfterX => -W_Label / 2
    // ==> imageOffsetY = OriginalY - AfterY => (H_Label + Space) / 2
    // ==> labelOffsetX = Original - After => W_Image/2
    // ==> labelOffsetY = Original - After => -(H_Image + Space)/2
    
    //image中心移动的x距离
    CGFloat imageOffsetX = self.bounds.size.width > 0 ? (self.bounds.size.width - image_w) / 2 : label_w/2;
    //image中心移动的y距离
    CGFloat imageOffsetY = label_h/2 + space/2;
    //label左边缘移动的x距离
    CGFloat labelOffsetX1 = image_w/2 - label_w/2 + trueLabW/2;
    //label右边缘移动的x距离
    CGFloat labelOffsetX2 = image_w/2 + label_w/2 - trueLabW/2;
    //label中心移动的y距离
    CGFloat labelOffsetY = image_h/2 + space/2;
    
    // 正值缩小视图框架, 负值扩大视图框架
    YM_ImagePosition position = [self.getProperty(&kImagePositionKey) integerValue];
    switch (position) {
        case YM_ImagePosition_Left:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -space/2, 0, space/2);
//            self.titleEdgeInsets = UIEdgeInsetsMake(0, space/2, 0, -space/2);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            break;
        case YM_ImagePosition_Right:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, trueLabW+space/2, 0, -(trueLabW + space/2));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(image_w + space/2), 0, image_w + space/2);
            break;
        case YM_ImagePosition_Top:
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX1, -labelOffsetY, labelOffsetX2);
            break;
        case YM_ImagePosition_Bottom:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -labelOffsetX1, labelOffsetY, labelOffsetX2);
            break;
        default: break;
    }
}

#pragma mark - 按钮图片
- (UIButton *(^)(UIImage *, UIControlState))ymImage {
    return ^UIButton *(UIImage * image, UIControlState state) {
        YMButtonWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            YMButtonStrongSelf
            [self setImage:image forState:state];
        });
        return self;
    };
}

- (UIButton *(^)(NSString *, UIControlState))ymImageName {
    return ^UIButton *(NSString * imageName, UIControlState state) {
        YMButtonWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            YMButtonStrongSelf
            [self setImage:[UIImage imageNamed:imageName] forState:state];
        });
        return self;
    };
}

#pragma mark - 按钮背景
- (UIButton *(^)(UIImage *, UIControlState))ymBackImage {
    return ^UIButton *(UIImage * image, UIControlState state) {
        YMButtonWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            YMButtonStrongSelf
            [self setBackgroundImage:image forState:state];
            if (self.allowHighlight && state == UIControlStateNormal) {
                [self setBackgroundImage:image.ymAlpha(self.highlightAlpha) forState:UIControlStateHighlighted];
            }
        });
        return self;
    };
}

- (UIButton *(^)(NSString *, UIControlState))ymBackImageName {
    return ^UIButton *(NSString * imageName, UIControlState state) {
        YMButtonWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            YMButtonStrongSelf
            [self setBackgroundImage:[UIImage imageNamed:imageName] forState:state];
            if (self.allowHighlight && state == UIControlStateNormal) {
                [self setBackgroundImage:[UIImage imageNamed:imageName].ymAlpha(self.highlightAlpha) forState:UIControlStateHighlighted];
            }
        });
        return self;
    };
}

#pragma mark - 事件
- (UIButton *(^)(id, SEL, UIControlEvents))ymAction {
    return ^UIButton * (id target, SEL sel, UIControlEvents event) {
        [self addTarget:target action:sel forControlEvents:event];
        return self;
    };
}

#pragma mark - 标题
/** 标题 */
- (UIButton *(^)(NSString *, UIControlState))ymTitle {
    return ^UIButton * (NSString * title, UIControlState state) {
        YMButtonWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            YMButtonStrongSelf
            [self setTitle:title forState:state];
        });
        return self;
    };
}

/** 字体颜色 */
- (UIButton *(^)(UIColor *, UIControlState))ymTitleColor {
    return ^UIButton * (UIColor * color, UIControlState state) {
        YMButtonWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            YMButtonStrongSelf
            [self setTitleColor:color forState:state];
            if (self.allowHighlight && state == UIControlStateNormal) {
                [self setTitleColor:color.ymAlpha(self.highlightAlpha) forState:UIControlStateHighlighted];
            }
        });
        return self;
    };
}

/** 标题字体 */
- (UIButton *(^)(UIFont *))ymTitleFont {
    return ^UIButton * (UIFont * font) {
        YMButtonWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            YMButtonStrongSelf
            self.titleLabel.font = font;
        });
        return self;
    };
}

/** 标题富文本 */
- (UIButton *(^)(NSAttributedString *, UIControlState))ymTitleAttribute {
    return ^UIButton * (NSAttributedString * attribute, UIControlState state) {
        YMButtonWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            YMButtonStrongSelf
            [self setAttributedTitle:attribute forState:state];
            if (self.allowHighlight && state == UIControlStateNormal) {
                NSMutableAttributedString * mAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:attribute];
                
                NSMutableArray <UIColor *> * colors = [NSMutableArray array];
                NSMutableArray <NSString *> * ranges = [NSMutableArray array];
                [mAttribute enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(0, mAttribute.length) options:NSAttributedStringEnumerationReverse usingBlock:^(UIColor * _Nonnull color, NSRange range, BOOL * _Nonnull stop) {
                    NSLog(@"%f", self.highlightAlpha);
                    [colors addObject:color.ymAlpha(self.highlightAlpha)];
                    [ranges addObject:NSStringFromRange(range)];
                }];
                
                for (int i = 0; i < colors.count; i++) {
                    NSRange range = NSRangeFromString(ranges[i]);
                    UIColor * color = colors[i];
                    [mAttribute addAttribute:NSForegroundColorAttributeName value:color range:range];
                }
                [self setAttributedTitle:mAttribute forState:UIControlStateHighlighted];
            }
        });
        return self;
    };
}

/** 对齐方式 */
- (UIButton *(^)(YM_BtnAlignment))ymAlignment {
    return ^UIButton * (YM_BtnAlignment aligment) {
        if (aligment <= YM_BtnAlignment_VFill) {
            self.contentVerticalAlignment = (UIControlContentVerticalAlignment)aligment;
        } else {
            self.contentHorizontalAlignment = (UIControlContentHorizontalAlignment)(aligment - YM_BtnAlignment_HCenter);
        }
        return self;
    };
}

#pragma mark - 图片加载动画
/** 开始加载动画 */
- (void)ymStartLoadAnimationWithImage:(UIImage *)image
                             duration:(CGFloat)duration
                           buttonSize:(CGSize)buttonSize {
    if (!image) {
        return;
    }
    
    // 设置旋转视图
    CGFloat size = buttonSize.width * 0.5;
    CGFloat x = (buttonSize.width - size) / 2.0;
    CGFloat y = (buttonSize.height - size) / 2.0;
    UIImageView * imageView = [UIImageView new];
    imageView.frame = CGRectMake(x, y, size, size);
    imageView.image = image;
    imageView.tag = 9999;
    [self addSubview:imageView];
    
    // 旋转动画
    NSString * fileModel = kCAFillModeForwards;
    NSInteger count = INT_MAX;
    CABasicAnimation * turnViewAnimation = [CABasicAnimation ymRotationWithType:kRotationCoordinate_Z fromValue:@(0) toValue:@(M_PI * 2) duration:duration fillMode:fileModel repeatCount:count];
    [imageView.layer addAnimation:turnViewAnimation forKey:@"turn"];
}

/** 停止加载动画 */
- (void)ymStopLoadAnimation {
    UIImageView * imageView = [self viewWithTag:9999];
    [imageView.layer removeAnimationForKey:@"turn"];
    [imageView removeFromSuperview];
}

#pragma mark - 动态属性
static char kExpandTouchKey;
/** 扩大点击范围 */
- (UIButton *(^)(BOOL))ymExpandTouch {
    return ^UIButton * (BOOL expand) {
        self.setProperty(&kExpandTouchKey, @(expand));
        return self;
    };
}

static char kAllowHighlight;
- (BOOL)allowHighlight {
    return [self.getProperty(&kAllowHighlight) boolValue];
}
- (void)setAllowHighlight:(bool)allow {
    self.setProperty(&kAllowHighlight, @(allow));
}

static char kHighlightAlpha;
- (CGFloat)highlightAlpha {
    return [self.getProperty(&kHighlightAlpha) floatValue];
}
- (void)setHighlightAlpha:(CGFloat)alpha {
    self.setProperty(&kHighlightAlpha, @(alpha));
}
#pragma mark - 重写
/** 扩大点击范围 */
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    BOOL isExpand = [self.getProperty(&kExpandTouchKey) boolValue];
    if (isExpand) {
        // 扩大触摸范围
        CGFloat widthDelta = MAX(bounds.size.width * 1.2, 0);
        CGFloat heightDelta = MAX(bounds.size.height * 1.2, 0);
        bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    }
    return CGRectContainsPoint(bounds, point);
}

@end


#pragma mark - 按钮点击时间间隔（https://mp.weixin.qq.com/s/zJKvtDDyI8tMv-UBpjDo6A）
@interface UIControl ()
/// 是否可以点击
@property (nonatomic, assign) BOOL isIgnoreClick;

/// 上次按钮响应的方法名
@property (nonatomic, strong) NSString * oldSelName;

@end


@implementation UIControl (YMClickInterval)

/// 替换
+ (void)ymExchangeClickMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 方法替换
        SEL originalSel = @selector(sendAction:to:forEvent:);
        SEL newSel = @selector(ymSendAction:to:forEvent:);
        Method originalMethod = class_getInstanceMethod(self , originalSel);
        Method newMethod = class_getInstanceMethod(self , newSel);
        
        // 如果发现方法已经存在，返回NO；也可以用来做检查用，这里是为了避免源方法没有存在的情况;
        // 如果方法没有存在,我们则先尝试添加被替换的方法的实现
        BOOL isAddNewMethod = class_addMethod(self, originalSel, method_getImplementation(newMethod), "v@:");
        if (isAddNewMethod) {
            class_replaceMethod(self, newSel, method_getImplementation(originalMethod), "v@:");
        } else {
            method_exchangeImplementations(originalMethod, newMethod);
        }
    });
}

/// 按钮交互事件发送方法
- (void)ymSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    // 如果响应者是按钮并且设置了交互时间间隔，才会进入限制逻辑
    if ([self isKindOfClass:[UIButton class]] && self.ymClickInterval > 0) {
        NSString *currentSELName = NSStringFromSelector(action);
        if (self.isIgnoreClick && [self.oldSelName isEqualToString:currentSELName]) {
            return;
        }
        
        self.isIgnoreClick = YES;
        self.oldSelName = currentSELName;
        [self performSelector:@selector(ymIgnoreClickState:)
                   withObject:@(NO)
                   afterDelay:self.ymClickInterval];
    }
    [self ymSendAction:action to:target forEvent:event];
}

- (void)ymIgnoreClickState:(NSNumber *)ignoreClickState {
    self.isIgnoreClick = ignoreClickState.boolValue;
    self.oldSelName = @"";
}

#pragma mark getter/setter
- (NSString *)oldSelName {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOldSelName:(NSString *)oldSelName {
    objc_setAssociatedObject(self, @selector(oldSelName), oldSelName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isIgnoreClick {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsIgnoreClick:(BOOL)isIgnoreClick {
    objc_setAssociatedObject(self, @selector(isIgnoreClick), @(isIgnoreClick), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)ymClickInterval {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setYmClickInterval:(NSTimeInterval)ymClickInterval {
    objc_setAssociatedObject(self, @selector(ymClickInterval), @(ymClickInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

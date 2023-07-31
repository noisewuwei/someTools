//
//  YMButton.m
//  macOS_Test
//
//  Created by 海南有趣 on 2020/7/30.
//  Copyright © 2020 黄玉洲. All rights reserved.
//

#import "YMButton.h"
#import "YMButtonCell.h"
#import <objc/message.h>
#import <objc/runtime.h>
@interface NSObject (YMButton)

#pragma mark - 动态属性生成和获取
@property (copy, nonatomic) id (^setProperty)(char*, id value);
@property (copy, nonatomic) id (^getProperty)(char*);

@end

#pragma mark - ======= NSObject (YMButton) =======
@implementation NSObject (YMButton)

#pragma mark - 动态属性生成和获取
@dynamic setProperty;
- (id (^)(char *, id))setProperty {
    return ^id (char* key, id value) {
        objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return self;
    };
}

@dynamic getProperty;
- (id (^)(char *))getProperty {
    return ^id (char* key) {
        return objc_getAssociatedObject(self, key);
    };
}

@end

#define YMMsgSend(...)       ((void (*)(void *, SEL, id))objc_msgSend)(__VA_ARGS__)
#define YMMsgTarget(target)  (__bridge void *)(target)
@interface YMButton ()
{
    YMButtonStatus _status;
}

/// 鼠标监听
@property (strong, nonatomic) NSTrackingArea * trackingArea;

/// 高亮状态
@property (assign, nonatomic) BOOL isHighlight;

/// 显示手光标
@property (assign, nonatomic) BOOL handCursor;

/// 圆角
@property (assign, nonatomic) CGFloat radius;
/// 圆角位置
@property (assign, nonatomic) YMButtonCorners radiusCorners;

/// 文字对齐
@property (assign, nonatomic) YMButtonAlign   align;
/// 图片排版
@property (assign, nonatomic) YMButtonPosition position;
/// 重新加载cell
@property (assign, nonatomic) BOOL   reloadCell;

/// 图标间距
@property (assign, nonatomic) CGFloat   space;

// 私有
@property (strong, nonatomic) NSAttributedString * privateAttributedString;

// 私有
@property (strong, nonatomic) NSFont * privateFont;

@end

@implementation YMButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bordered = NO;
        self.bezelStyle = NSBezelStyleRegularSquare;
        self.align = YMButtonAlign_Center;
        self.position = YMButtonPosition_Left;
        [self layoutView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.bordered = NO;
        self.bezelStyle = NSBezelStyleRegularSquare;
        self.align = YMButtonAlign_Center;
        self.position = YMButtonPosition_Left;
        [self layoutView];
    }
    return self;
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    
}

#pragma mark 事件
/// 添加事件
- (YMButton * _Nonnull (^)(id _Nonnull, SEL _Nonnull))ymAction {
    return ^YMButton *(id targer, SEL action) {
        self.target = targer;
        self.action = action;
        return self;
    };
}

#pragma mark 光标样式
- (YMButton * _Nonnull (^)(BOOL))ymHandCursor {
    return ^YMButton *(BOOL showHandCursor) {
        self.handCursor = showHandCursor;
        return self;
    };
}

#pragma markk 圆角
- (YMButton * _Nonnull (^)(CGFloat, YMButtonCorners))ymRadius {
    return ^YMButton *(CGFloat radius, YMButtonCorners radiusType) {
        self.radius = radius;
        self.radiusCorners = radiusType;
        return self;
    };
}

#pragma mark 排版
- (YMButton * _Nonnull (^)(YMButtonAlign, YMButtonPosition))ymTypography {
    return ^YMButton *(YMButtonAlign align, YMButtonPosition position) {
        self.align = align;
        self.position = position;
        return self;
    };
}
- (YMButton * _Nonnull (^)(YMButtonPosition))ymImagePosition {
    return ^YMButton *(YMButtonPosition position) {
        self.imagePosition = position;
        return self;
    };
}

#pragma mark 按钮标题
static char kButtonTitleKey;
- (void)setTitle:(NSString *)title status:(YMButtonStatus)status {
    NSMutableDictionary * mDic = [self.getProperty(&kButtonTitleKey) mutableCopy];
    if (!mDic) {
        mDic = [NSMutableDictionary dictionary];
    }
    [mDic setObject:title forKey:[NSString stringWithFormat:@"%ld", (long)status]];
    self.setProperty(&kButtonTitleKey, mDic);
}

- (NSString *)titleWithStatus:(YMButtonStatus)status {
    return [self.getProperty(&kButtonTitleKey) objectForKey:[NSString stringWithFormat:@"%ld", (long)status]];
}

- (YMButton * _Nonnull (^)(NSString * _Nonnull, YMButtonStatus))ymTitle {
    return ^YMButton *(NSString * title, YMButtonStatus status) {
        [self setTitle:title status:status];
        return self;
    };
}

#pragma mark 文本属性
- (YMButton * _Nonnull (^)(NSFont * _Nonnull))ymFont {
    return ^YMButton *(NSFont * font) {
        self.privateFont = font;
        return self;
    };
}

#pragma mark 按钮标题富文本
static char kButtonTitleAttributeKey;
- (void)setTitleAttribute:(NSAttributedString *)titleAttribute status:(YMButtonStatus)status {
    NSMutableDictionary * mDic = [self.getProperty(&kButtonTitleAttributeKey) mutableCopy];
    if (!mDic) {
        mDic = [NSMutableDictionary dictionary];
    }
    [mDic setObject:titleAttribute forKey:[NSString stringWithFormat:@"%ld", (long)status]];
    self.setProperty(&kButtonTitleAttributeKey, mDic);
}

- (NSAttributedString *)titleAttributeWithStatus:(YMButtonStatus)status {
    return [self.getProperty(&kButtonTitleAttributeKey) objectForKey:[NSString stringWithFormat:@"%ld", (long)status]];
}

- (YMButton * _Nonnull (^)(NSAttributedString * _Nonnull, YMButtonStatus))ymTitleAttribute {
    return ^YMButton *(NSAttributedString * titleAttribute, YMButtonStatus status) {
        [self setTitleAttribute:titleAttribute status:status];
        return self;
    };
}

#pragma mark 按钮颜色
static char kButtonTitleColorKey;
- (void)setTitleColor:(NSColor *)titleColor status:(YMButtonStatus)status {
    NSMutableDictionary * mDic = [self.getProperty(&kButtonTitleColorKey) mutableCopy];
    if (!mDic) {
        mDic = [NSMutableDictionary dictionary];
    }
    [mDic setObject:titleColor forKey:[NSString stringWithFormat:@"%ld", (long)status]];
    self.setProperty(&kButtonTitleColorKey, mDic);
}

- (NSColor *)titleColorWithStatus:(YMButtonStatus)status {
    return [self.getProperty(&kButtonTitleColorKey) objectForKey:[NSString stringWithFormat:@"%ld", (long)status]];
}

- (YMButton * _Nonnull (^)(NSColor * _Nonnull, YMButtonStatus))ymTitleColor {
    return ^YMButton *(NSColor * titleColor, YMButtonStatus status) {
        [self setTitleColor:titleColor status:status];
        return self;
    };
}

#pragma mark 按钮图片
static char kButtonImageKey;
- (void)setImage:(NSImage *)backImage status:(YMButtonStatus)status {
    NSMutableDictionary * mDic = [self.getProperty(&kButtonImageKey) mutableCopy];
    if (!mDic) {
        mDic = [NSMutableDictionary dictionary];
    }
    [mDic setObject:backImage forKey:[NSString stringWithFormat:@"%ld", (long)status]];
    self.setProperty(&kButtonImageKey, mDic);
}

- (NSImage *)imageWithStatus:(YMButtonStatus)status {
    return [self.getProperty(&kButtonImageKey) objectForKey:[NSString stringWithFormat:@"%ld", (long)status]];
}

- (YMButton * _Nonnull (^)(NSImage * _Nonnull, YMButtonStatus))ymImage {
    return ^YMButton *(NSImage * image, YMButtonStatus status) {
        [self setImage:image status:status];
        return self;
    };
}

- (NSImage *)backImage {
    NSImage  * backgroundImage = [self backImageWithStatus:_status] ?: [self backImageWithStatus:YMButtonStatus_Normal];
    return backgroundImage;
}


- (YMButton * _Nonnull (^)(CGFloat))ymSpace {
    return ^YMButton *(CGFloat space) {
        self.space = space;
        return self;
    };
}

#pragma mark 按钮背景图片
static char kButtonBackImageKey;
- (void)setBackImage:(NSImage *)backImage status:(YMButtonStatus)status {
    NSMutableDictionary * mDic = [self.getProperty(&kButtonBackImageKey) mutableCopy];
    if (!mDic) {
        mDic = [NSMutableDictionary dictionary];
    }
    if (backImage) {
        [mDic setObject:backImage forKey:[NSString stringWithFormat:@"%ld", (long)status]];
    } else {
        [mDic removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)status]];
    }
    self.setProperty(&kButtonBackImageKey, mDic);
}

- (NSImage *)backImageWithStatus:(YMButtonStatus)status {
    return [self.getProperty(&kButtonBackImageKey) objectForKey:[NSString stringWithFormat:@"%ld", (long)status]];
}

- (YMButton * _Nonnull (^)(NSImage *, YMButtonStatus))ymBackImage {
    return ^YMButton *(NSImage * backImage, YMButtonStatus status) {
        [self setBackImage:backImage status:status];
        return self;
    };
}

- (void)layout{
    [super layout];
    [self setNeedsDisplay];
}

- (void)reset {
    _isHighlight = NO;
    if ([self isEnabled]) {
        _status = YMButtonStatus_Normal;
    } else {
        _status = YMButtonStatus_Disabled;
    }
    [self setNeedsDisplay];
}

- (void)setNeedsDisplay {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) self = weakSelf;
        if (self.superview) {
            if (!self.enabled) {
                _status = YMButtonStatus_Disabled;
            }
            [self setNeedsDisplay:YES];
        }
    });
}

- (void)drawRect:(NSRect)dirtyRect {
    NSString * title = [self titleWithStatus:_status] ?: [self titleWithStatus:YMButtonStatus_Normal];
    NSColor  * titleColor = [self titleColorWithStatus:_status] ?: [self titleColorWithStatus:YMButtonStatus_Normal];
    NSAttributedString * titleAttribute = [self titleAttributeWithStatus:_status] ?: [self titleAttributeWithStatus:YMButtonStatus_Normal];
    NSImage  * backgroundImage = [self backImageWithStatus:_status] ?: [self backImageWithStatus:YMButtonStatus_Normal];
    NSImage  * image = [self imageWithStatus:_status] ?: [self imageWithStatus:YMButtonStatus_Normal];
    
    if (![self.cell isKindOfClass:[YMButtonCell class]]) {
        YMButtonCell * cell = [[YMButtonCell alloc] initWithAlign:(kButtonCellAlign)_align
                                                    imagePosition:(kButtonImagePosition)_position];
        cell.bordered = NO;
        cell.backgroundColor = [NSColor clearColor];
        cell.target = self.target;
        cell.action = self.action;
        cell.imageEdge = self.space > 0 ?: 5;
        self.cell = cell;
    }
    
    
    if (titleColor && [self.cell isKindOfClass:[YMButtonCell class]])
        ((YMButtonCell *)self.cell).textColor = titleColor;
    if (image)
        self.cell.image = image;
    
    // 富文本和普通文本只能使用一个
    if (titleAttribute) {
        if (![self.privateAttributedString isEqual:titleAttribute]) {
            self.privateAttributedString = titleAttribute;
        }
    } else {
        self.cell.font = self.privateFont;
        self.cell.title = title ? title : @" ";
    }
    
//    if (_radiusCorners) {
//        NSBezierPath *bezierPath;
//        if (_radiusCorners == YMButtonCorners_All) {
//            bezierPath = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:_radius yRadius:_radius];
//        } else {
//            bezierPath = [NSBezierPath bezierPath];
//            CGFloat topRightRadius = _radiusCorners & YMButtonCorners_TopLeft ? _radius : 0.0;
//            CGFloat topLeftRadius = _radiusCorners & YMButtonCorners_TopRight ? _radius : 0.0;
//            CGFloat bottomLeftRadius = _radiusCorners & YMButtonCorners_BottomLeft ? _radius : 0.0;
//            CGFloat bottomRightRadius = _radiusCorners & YMButtonCorners_BottomRight ? _radius : 0.0;
//
//            //右上
//            CGPoint topRightPoint = CGPointMake(dirtyRect.origin.x+dirtyRect.size.width, dirtyRect.origin.y+dirtyRect.size.height);
//            topRightPoint.x -= topRightRadius;
//            topRightPoint.y -= topRightRadius;
//            [bezierPath appendBezierPathWithArcWithCenter:topRightPoint radius:topRightRadius startAngle:0 endAngle:90];
//
//            //左上
//            CGPoint topLeftPoint = CGPointMake(dirtyRect.origin.x, dirtyRect.origin.y+dirtyRect.size.height);
//            topLeftPoint.x += topLeftRadius;
//            topLeftPoint.y -= topLeftRadius;
//            [bezierPath appendBezierPathWithArcWithCenter:topLeftPoint radius:topLeftRadius startAngle:90 endAngle:180];
//
//            //左下
//            CGPoint bottomLeftPoint = dirtyRect.origin;
//            bottomLeftPoint.x += bottomLeftRadius;
//            bottomLeftPoint.y += bottomLeftRadius;
//            [bezierPath appendBezierPathWithArcWithCenter:bottomLeftPoint radius:bottomLeftRadius startAngle:180 endAngle:270];
//
//            //右下
//            CGPoint bottomRightPoint = CGPointMake(dirtyRect.origin.x+dirtyRect.size.width, dirtyRect.origin.y);
//            bottomRightPoint.x -= bottomRightRadius;
//            bottomRightPoint.y += bottomRightRadius;
//            [bezierPath appendBezierPathWithArcWithCenter:bottomRightPoint radius:bottomRightRadius startAngle:270 endAngle:360];
//        }
//        [NSGraphicsContext saveGraphicsState];
//        [bezierPath addClip];
//        [backgroundImage drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
//        [NSGraphicsContext restoreGraphicsState];
//    } else {
//        [backgroundImage drawInRect:dirtyRect];
//    }
    
    [super drawRect:dirtyRect];
}

#pragma mark - setter private
- (void)setPrivateAttributedString:(NSAttributedString *)privateAttributedString {
    if (privateAttributedString) {
        _privateAttributedString = privateAttributedString;
        self.attributedTitle = privateAttributedString;
    }
}

- (void)setPrivateFont:(NSFont *)privateFont {
    if (privateFont) {
        _privateFont = privateFont;
        self.font = privateFont;
    }
}

#pragma mark 懒加载

@end




@interface YMButton (YMButtonMouse)

@end

@implementation YMButton (YMButtonMouse)

- (void)updateTrackingAreas {
    if (![self isKindOfClass:[YMButton class]]) {
        return;
    }
    if (_trackingArea == nil) {
        NSTrackingAreaOptions options =
        NSTrackingActiveAlways |
        NSTrackingInVisibleRect |
        NSTrackingMouseEnteredAndExited |
        NSTrackingEnabledDuringMouseDrag;
        _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                         options:options
                                                           owner:self
                                                        userInfo:nil];
        [self addTrackingArea:_trackingArea];
    }
}

- (void)mouseEntered:(NSEvent *)event {
    if (_trackingArea && [self isEnabled]) {
        if (self.enterBlock) {
            self.enterBlock(self);
        }
        
        if (_isHighlight) {
            _status = YMButtonStatus_Highlight;
        } else {
            _status = YMButtonStatus_Enter;
        }
        [self setNeedsDisplay];
        
        // 显示小手
        if (_handCursor) {
            [[NSCursor pointingHandCursor] set];
        }
    }
}

- (void)mouseExited:(NSEvent *)event{
    if (_trackingArea && [self isEnabled]) {
        if (self.exitedBlock) {
            self.exitedBlock(self);
        }
        _status = YMButtonStatus_Normal;
        [self setNeedsDisplay];
    }
    
    // 显示箭头
    if (_handCursor) {
        [[NSCursor arrowCursor] set];
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (![self isEnabled]) {
        return;
    }
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    if (CGRectContainsPoint(self.bounds, point)) {
        _isHighlight = YES;
        _status = YMButtonStatus_Highlight;
        [self setNeedsDisplay];
    }
}

- (void)mouseUp:(NSEvent *)event {
    if (![self isEnabled]) {
        return;
    }
    
    _isHighlight = NO;
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    BOOL isContain = CGRectContainsPoint(self.bounds, point);
    if (isContain) {
        _status = YMButtonStatus_Enter;
        if (self.target && self.action && [self.target respondsToSelector:self.action]) {
            YMMsgSend(YMMsgTarget(self.target), self.action, self);
        }
    } else {
        _status = YMButtonStatus_Normal;
    }
    [self setNeedsDisplay];
}

@end

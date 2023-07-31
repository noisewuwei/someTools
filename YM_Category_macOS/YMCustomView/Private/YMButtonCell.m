//
//  YMButtonCell.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/28.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "YMButtonCell.h"
#import "YMButton.h"
@interface YMButtonCell ()
{
    kButtonCellAlign _align;
    kButtonImagePosition _position;
}

@end

@implementation YMButtonCell

- (instancetype)init {
    if (self = [super init]) {
        _imageEdge = 5;
        _align = kButtonCellAlign_Center;
        _position = kButtonImagePosition_Left;
    }
    return self;
}

- (instancetype)initWithAlign:(kButtonCellAlign)align imagePosition:(kButtonImagePosition)position {
    if (self = [super init]) {
        _imageEdge = 5;
        _align = align;
        _position = position;
    }
    return self;
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    // 如果存在图片，获取图片显示的宽度和高度（做了自适应）
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    YMButton * button = (YMButton *)controlView;
    if (button.image) {
        CGSize size = button.image.size;
        CGFloat maxHeight = controlView.bounds.size.height * 0.8;
        imageHeight = size.height > maxHeight ? maxHeight : size.height;
        imageWidth = imageHeight * size.width / size.height;
    }
    
    NSSize titleSize =  [title size];
    CGFloat startX = frame.origin.x;
    CGFloat startY = frame.origin.y;
    
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat titleX = 0;
    CGFloat titleY = 0;
    
    if (_align == kButtonCellAlign_Center) {
        titleX = startX + (frame.size.width - titleSize.width) / 2.0;
        titleY = startY + (frame.size.height - titleSize.height) / 2.0;
        if (_position == kButtonImagePosition_Top && imageWidth > 0) {
            imageX = startX + (frame.size.width - imageWidth) / 2.0;
            imageY = titleY - _imageEdge - imageHeight;
            if (imageY < 0) {
                imageY = 0;
                titleY = imageY + _imageEdge + imageHeight;
            }
        }
        else if (_position == kButtonImagePosition_Bottom && imageWidth > 0) {
            imageX = startX + (frame.size.width - imageWidth) / 2.0;
            imageY = titleY + _imageEdge + imageHeight;
        }
        else if (_position == kButtonImagePosition_Left && imageWidth > 0) {
            CGFloat wholeWidth = imageWidth + _imageEdge + titleSize.width;
            imageX = startX + (wholeWidth > frame.size.width ? -((wholeWidth - frame.size.width) / 2.0) : (frame.size.width - wholeWidth) / 2.0);
            titleX = imageX + imageWidth + _imageEdge;
            imageY = startY + (frame.size.height - imageHeight) / 2.0;
        }
        else if (_position == kButtonImagePosition_Right) {
            CGFloat wholeWidth = imageWidth + _imageEdge + titleSize.width;
            titleX = startX + (wholeWidth > frame.size.width ? -((wholeWidth - frame.size.width) / 2.0) : (frame.size.width - wholeWidth) / 2.0);
            imageX = titleX + titleSize.width + _imageEdge;
            imageY = startY + (frame.size.height - imageHeight) / 2.0;
        }
    } else if (_align == kButtonCellAlign_Left) {
        titleX = startX;
        titleY = startY + (frame.size.height - titleSize.height) / 2.0;
        if (_position == kButtonImagePosition_Top && imageWidth > 0) {
            imageX = startX + (frame.size.width - imageWidth) / 2.0;
            imageY = titleY - _imageEdge - imageHeight;
        }
        else if (_position == kButtonImagePosition_Bottom && imageWidth > 0) {
            imageX = startX + (frame.size.width - imageWidth) / 2.0;
            imageY = titleY + _imageEdge + imageHeight;
        }
        else if (_position == kButtonImagePosition_Left && imageWidth > 0) {
            imageX = startX;
            titleX = imageX + imageWidth + _imageEdge;
            imageY = startY + (frame.size.height - imageHeight) / 2.0;
        }
        else if (_position == kButtonImagePosition_Right && imageWidth > 0) {
            titleX = startX;
            imageX = titleX + titleSize.width + _imageEdge;
            imageY = startY + (frame.size.height - imageHeight) / 2.0;
        }
    } else if (_align == kButtonCellAlign_Right) {
        titleX = startX + frame.size.width - titleSize.width;
        titleY = startY + (frame.size.height - titleSize.height) / 2.0;
        if (_position == kButtonImagePosition_Top && imageWidth > 0) {
            imageX = startX + (frame.size.width - imageWidth) / 2.0;
            imageY = titleY - _imageEdge - imageHeight;
        }
        else if (_position == kButtonImagePosition_Bottom && imageWidth > 0) {
            imageX = startX + (frame.size.width - imageWidth) / 2.0;
            imageY = titleY + _imageEdge + imageHeight;
        }
        else if (_position == kButtonImagePosition_Left && imageWidth > 0) {
            imageX = titleX - _imageEdge - imageWidth;
            imageY = startY + (frame.size.height - imageHeight) / 2.0;
        }
        else if (_position == kButtonImagePosition_Right && imageWidth > 0) {
            imageX = startX + frame.size.width - imageWidth;
            titleX = imageX - titleSize.width - _imageEdge;
            imageY = startY + (frame.size.height - imageHeight) / 2.0;
        }
    }
    
    // 绘制背景
    if (button.backImage) {
        [self drawBackImage:button.backImage button:button];
    }
    // 绘制标题
    NSRect rectTitle = CGRectMake(titleX, titleY, titleSize.width, titleSize.height);
    rectTitle.origin.y = titleY;
    NSMutableAttributedString * titleStr = [[self attributeWithTitle:title button:button] mutableCopy];
    if (self.textColor) {
        [titleStr addAttribute:NSForegroundColorAttributeName
                         value:self.textColor
                         range:NSMakeRange(0, titleStr.string.length)];
    }
    
    [titleStr drawInRect:rectTitle];
    
    // 绘制图标
    if (button.image) {
        [button.image drawInRect:CGRectMake(imageX, imageY, imageWidth, imageHeight)];
    }
    
    
    return frame;
}

/// 该方法用于防止系统自己绘画图标
- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    YMButton * button = (YMButton *)controlView;
    // 绘制背景
    if (button.backImage) {
        [self drawBackImage:button.backImage button:button];
    }
    if (button.title.length == 0 || [button.title isEqual:@"Button"]) {
        [image drawInRect:frame];
    }
}

- (void)drawBackImage:(NSImage *)image button:(YMButton *)button {
    NSBezierPath *bezierPath;
    if (button.radiusCorners == YMButtonCorners_All) {
        bezierPath = [NSBezierPath bezierPathWithRoundedRect:button.bounds
                                                     xRadius:button.radius
                                                     yRadius:button.radius];
    } else {
        NSRect dirtyRect = button.bounds;
        bezierPath = [NSBezierPath bezierPath];
        CGFloat topRightRadius =
        button.radiusCorners & YMButtonCorners_TopLeft ? button.radius : 0.0;
        CGFloat topLeftRadius =
        button.radiusCorners & YMButtonCorners_TopRight ? button.radius : 0.0;
        CGFloat bottomLeftRadius =
        button.radiusCorners & YMButtonCorners_BottomLeft ? button.radius : 0.0;
        CGFloat bottomRightRadius =
        button.radiusCorners & YMButtonCorners_BottomRight ? button.radius : 0.0;

        //右上
        CGPoint topRightPoint = CGPointMake(dirtyRect.origin.x+dirtyRect.size.width, dirtyRect.origin.y+dirtyRect.size.height);
        topRightPoint.x -= topRightRadius;
        topRightPoint.y -= topRightRadius;
        [bezierPath appendBezierPathWithArcWithCenter:topRightPoint radius:topRightRadius startAngle:0 endAngle:90];

        //左上
        CGPoint topLeftPoint = CGPointMake(dirtyRect.origin.x, dirtyRect.origin.y+dirtyRect.size.height);
        topLeftPoint.x += topLeftRadius;
        topLeftPoint.y -= topLeftRadius;
        [bezierPath appendBezierPathWithArcWithCenter:topLeftPoint radius:topLeftRadius startAngle:90 endAngle:180];

        //左下
        CGPoint bottomLeftPoint = dirtyRect.origin;
        bottomLeftPoint.x += bottomLeftRadius;
        bottomLeftPoint.y += bottomLeftRadius;
        [bezierPath appendBezierPathWithArcWithCenter:bottomLeftPoint radius:bottomLeftRadius startAngle:180 endAngle:270];

        //右下
        CGPoint bottomRightPoint = CGPointMake(dirtyRect.origin.x+dirtyRect.size.width, dirtyRect.origin.y);
        bottomRightPoint.x -= bottomRightRadius;
        bottomRightPoint.y += bottomRightRadius;
        [bezierPath appendBezierPathWithArcWithCenter:bottomRightPoint radius:bottomRightRadius startAngle:270 endAngle:360];
    }
    
    [NSGraphicsContext saveGraphicsState];
    [bezierPath addClip];
    [button.backImage drawInRect:button.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    [NSGraphicsContext restoreGraphicsState];
}

#pragma mark getter
- (NSAttributedString *)attributeWithTitle:(NSAttributedString *)title
                                    button:(YMButton *)button {
    NSColor * color = [self attributeColorWithAttribute:title];
    NSMutableAttributedString * titleStr =[[NSMutableAttributedString alloc] initWithAttributedString:title];
    if (color) {
        [titleStr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, titleStr.length)];
    }
    return titleStr;
}


- (NSColor *)attributeColorWithAttribute:(NSAttributedString *)attribute {
    NSColor *color = [self attribute:attribute attributeName:NSForegroundColorAttributeName atIndex:0];
    if (!color) {
        CGColorRef ref = (__bridge CGColorRef)([self attribute:attribute attributeName:(NSString *)kCTForegroundColorAttributeName atIndex:0]);
        if (ref) {
            color = [NSColor colorWithCGColor:ref];
        }
    }
    if (color && ![color isKindOfClass:[NSColor class]]) {
        if (CFGetTypeID((__bridge CFTypeRef)(color)) == CGColorGetTypeID()) {
            color = [NSColor colorWithCGColor:(__bridge CGColorRef)(color)];
        } else {
            color = nil;
        }
    }
    return color;
}

- (id)attribute:(NSAttributedString *)attribute attributeName:(NSString *)attributeName atIndex:(NSUInteger)index {
    if (!attributeName) return nil;
    if (index > attribute.length || attribute.length == 0) return nil;
    if (attribute.length > 0 && index == attribute.length) index--;
    return [attribute attribute:attributeName atIndex:index effectiveRange:NULL];
}


@end

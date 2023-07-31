//
//  YMLabel.m
//  ToDesk
//
//  Created by 海南有趣 on 2020/7/27.
//  Copyright © 2020 rayootech. All rights reserved.
//

#import "YMLabel.h"

#pragma mark - YMLabelCell
@interface YMLabelCell : NSTextFieldCell
{
    ymVerticalAlign _align;
}
@end

@implementation YMLabelCell

- (instancetype)initWithAlign:(ymVerticalAlign)align {
    if (self = [super init]) {
        _align = align;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _align = ymVerticalAlign_Center;
    }
    return self;
}

- (NSRect)drawingRectForBounds:(NSRect)rect {
    NSRect newRect = [super drawingRectForBounds:rect];
    NSSize textSize = [self cellSizeForBounds:rect];
    CGFloat heightDelta = newRect.size.height - textSize.height;
    if (heightDelta > 0) {
        newRect.size.height = textSize.height;
        newRect.origin.y += heightDelta * 0.5-1;
    }
    return newRect;
}

//- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame {
//// super would normally draw text at the top of the cell
//    CGFloat fontSize = self.font.boundingRectForFont.size.height;
//    NSInteger offset;
//    switch (_align) {
//        case ymVerticalAlign_Top:
//            offset = 0;
//            break;
//        case ymVerticalAlign_Center:
//            offset = floor((NSHeight(frame) - ceilf(fontSize))/2);
//            break;
//        default:
//            break;
//    }
//
//    NSRect centeredRect = NSInsetRect(frame, 0, offset);
//
//    return centeredRect;
//}
//
// - (void)editWithFrame:(NSRect)aRect
//                inView:(NSView *)controlView
//                editor:(NSText *)editor
//              delegate:(id)delegate event:(NSEvent *)event {
//     [super editWithFrame:[self adjustedFrameToVerticallyCenterText:aRect]
//                   inView:controlView
//                   editor:editor
//                 delegate:delegate
//                    event:event];
//}
//
//- (void)selectWithFrame:(NSRect)aRect
//                 inView:(NSView *)controlView
//                 editor:(NSText *)editor
//               delegate:(id)delegate
//                  start:(NSInteger)start
//                 length:(NSInteger)length {
//    [super selectWithFrame:[self adjustedFrameToVerticallyCenterText:aRect]
//                    inView:controlView
//                    editor:editor
//                  delegate:delegate
//                     start:start
//                    length:length];
//}
//
// - (void)drawInteriorWithFrame:(NSRect)frame
//                        inView:(NSView *)view {
//     [super drawInteriorWithFrame:
//      [self adjustedFrameToVerticallyCenterText:frame] inView:view];
//}

- (void)mouseDown:(NSEvent *)event {
    
}

- (void)mouseUp:(NSEvent *)event {
   
}


@end








#pragma mark - YMLabelCell
@interface YMLabel ()
{
    NSString * _stringValue;
}
@property (strong, nonatomic) YMLabelCell * textFieleCell;


@end

@implementation YMLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bordered = NO;
        self.drawsBackground = NO;
        self.cell.wraps = NO;
        self.cell.scrollable = YES;
        [self verticalAlign:ymVerticalAlign_Center];
    }
    return self;
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    
}

#pragma mark setter
/// 垂直居中
- (void)verticalAlign:(ymVerticalAlign)align {
    _textFieleCell = [[YMLabelCell alloc] initWithAlign:align];
    self.cell = _textFieleCell;
}

- (void)setStringValue:(NSString *)stringValue {
    if (stringValue) {
        [super setStringValue:stringValue];
        _stringValue = stringValue;
    }
}

/// 事件穿透到指定视图
- (NSView *)hitTest:(NSPoint)point {
    return nil;
}

#pragma mark getter
- (NSString *)stringValue {
    return _stringValue;
}

- (void)mouseDown:(NSEvent *)event {
    
}

- (void)mouseUp:(NSEvent *)event {
    
}

#pragma mark 懒加载

@end

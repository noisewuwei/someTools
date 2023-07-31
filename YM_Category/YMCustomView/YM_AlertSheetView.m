//
//  YM_AlertSheetView.m
//  ToDesk-iOS
//
//  Created by 海南有趣 on 2020/7/24.
//  Copyright © 2020 海南有趣. All rights reserved.
//

#import "YM_AlertSheetView.h"
#import "UIView+YMCustomView.h"
#import "UIColor+YMCustomView.h"
#import "UIImage+YMCustomView.h"
#import <CoreText/CoreText.h>
#pragma mark - YM_AlertSheetAction
@interface YM_AlertSheetAction ()
{
    NSString * _title;
    UIImage  * _image;
    AlertSheetActionBlock _block;
    kAlertSheetAction _actionStyle;
}

@end

@implementation YM_AlertSheetAction : NSObject

+ (YM_AlertSheetAction *)actionTitle:(NSString *)title image:(UIImage *)image style:(kAlertSheetAction)style block:(AlertSheetActionBlock)block {
    YM_AlertSheetAction * action = [[YM_AlertSheetAction alloc] initWithTitle:title image:image style:style block:block];
    return action;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image style:(kAlertSheetAction)style block:(AlertSheetActionBlock)block {
    if (self = [super init]) {
        _title = title;
        _image = image;
        _block = block;
        _actionStyle = style;
        _backgroundColor = [UIColor whiteColor];
        _titleFont = [UIFont systemFontOfSize:16.0];
        switch (style) {
            case kAlertSheetAction_Default:
                _titleColor = [UIColor colorWithRed:0 / 255.0 green:119 / 255.0 blue:244 / 255.0 alpha:1];
                break;
            case kAlertSheetAction_Cancel:
                _titleColor = _titleColor = [UIColor redColor];
            break;
            default: break;
        }
    }
    return self;
}

- (void)clear {
    _title = nil;
    _image = nil;
    _block = nil;
}

#pragma mark getter
- (kAlertSheetAction)actionStyle {
    return _actionStyle;
}

@end


#pragma mark - YM_AlertSheetView

static CGFloat alertMargin = 10;
static CGFloat itemHeight = 50;
@interface YM_AlertSheetView ()
{
    NSString * _title;
    NSString * _message;
    CGFloat _navigationBarHeight;
    BOOL _isVertical;
}

@property (strong, nonatomic) UIView * backView;

@property (strong, nonatomic) UIView * containView;
@property (strong, nonatomic) UIView * containTopView;
@property (strong, nonatomic) UIButton * cancelBtn;

@property (strong, nonatomic) UIScrollView * wordScrollView;
@property (strong, nonatomic) UILabel * titleLab;
@property (strong, nonatomic) UILabel * messageLab;

@property (strong, nonatomic) UIScrollView * itemScrollView;

@property (strong, nonatomic) NSMutableArray <YM_AlertSheetAction *> * items;
@property (strong, nonatomic) YM_AlertSheetAction * cancelAction;

@end

@implementation YM_AlertSheetView

- (void)dealloc {
    
}

- (instancetype)initWithTitle:(NSString *)title message:(nullable NSString *)message {
    if (self = [super init]) {
        _title = title;
        _message = message;
        [self initData];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = [[UIScreen mainScreen] bounds];
    [self layoutView];
}

#pragma mark 数据
- (void)initData {
    _items = [NSMutableArray array];
    _navigationBarHeight = -1;
    
    _titleFont = [UIFont systemFontOfSize:18.0f];
    _titleColor = [UIColor blackColor];
    
    _messgeFont = [UIFont systemFontOfSize:13.0f];
    _messgeColor = [UIColor grayColor];
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    // 背景色
    [self addSubview:self.backView];
    _backView.frame = self.bounds;
    
    // 容器视图
    [self addSubview:self.containView];
    _containView.frame = CGRectMake(alertMargin, [self naviHeight], self.width - alertMargin*2, self.height - [self naviHeight] - [self safeAreaBottom]);
    
    // 取消按钮
    if (_cancelAction) {
        [_containView addSubview:self.cancelBtn];
        _cancelBtn.frame = CGRectMake(0, _containView.height - alertMargin - itemHeight, _containView.width, itemHeight);
    }
    
    [_containView addSubview:self.containTopView];
    [_containTopView addSubview:self.itemScrollView];
    [_containTopView addSubview:self.wordScrollView];
    
    
    // 计算其余按钮所需的高度
    CGFloat itemsHeight = [_items count] * itemHeight;
    
    // 计算文本所需的高度
    CGFloat labelMaxWidth = self.width - alertMargin * 2;
    CGFloat titleHeight = [self sizeWithString:_title maxSize:CGSizeMake(labelMaxWidth, 0) font:_titleFont].height;
    CGFloat messageHeight = [self sizeWithString:_message maxSize:CGSizeMake(labelMaxWidth, 0) font:_messgeFont].height;
    CGFloat wordViewHeight = titleHeight + messageHeight;
    
    // 计算出文本和按钮最终需要的高度
    // 顶部视图的最大高度
    CGFloat containTopViewMaxHeight = _containView.height - _cancelBtn.height - alertMargin*2;
    if (itemsHeight + wordViewHeight > containTopViewMaxHeight) {
        CGFloat maxItemsHeight = 4 * itemHeight;
        if (itemsHeight > maxItemsHeight) {
            itemsHeight = maxItemsHeight;
        }
        wordViewHeight = containTopViewMaxHeight - itemsHeight;
    }
    
    // 顶部视图的高度
    CGFloat containTopViewHeight = itemsHeight + wordViewHeight;
    _containTopView.frame = CGRectMake(0, _containView.height - _cancelBtn.height - alertMargin*2 - containTopViewHeight, _containView.width, containTopViewHeight);
    
    // 按钮视图的高度
    _itemScrollView.frame = CGRectMake(0, _containTopView.height - itemsHeight, _containTopView.width, itemsHeight);
    CGFloat itemsNeedHeight = [_items count] * itemHeight;
    if (itemsNeedHeight > itemsHeight) {
        _itemScrollView.contentSize = CGSizeMake(0, itemsNeedHeight);
    }
    
    // 删除子视图
    for (UIView * subview in _itemScrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIColor * lineColor = [UIColor colorWithRed:176 / 255.0 green:182 / 255.0 blue:183 / 255.0 alpha:1];
    for (NSInteger i = 0; i < [_items count]; i++) {
        CGFloat y = i * itemHeight;
        
        UIView * line = [UIView new];
        line.frame = CGRectMake(0, y, _itemScrollView.width, 1);
        line.backgroundColor = lineColor;
        [_itemScrollView addSubview:line];
        
        YM_AlertSheetAction * action = _items[i];
        UIButton * button = [self buttonWithTitle:action.title
                                       titleColor:action.titleColor
                                        titleFont:action.titleFont
                                            image:action.image
                                        backColor:action.backgroundColor
                                           action:@selector(otherBtnAction:)];
        button.tag = 1000 + i;
        [_itemScrollView addSubview:button];
        button.frame = CGRectMake(0, y+1, _itemScrollView.width, itemHeight);
    }
    
    
    // 文本视图的高度
    _wordScrollView.frame = CGRectMake(0, 0, _containTopView.width, wordViewHeight);
    CGFloat wordNeedHeight = titleHeight + messageHeight;
    if (wordNeedHeight > wordViewHeight) {
        _wordScrollView.contentSize = CGSizeMake(0, wordNeedHeight);
    }
    [_wordScrollView addSubview:self.titleLab];
    _titleLab.frame = CGRectMake(alertMargin / 2.0, alertMargin / 2.0 , labelMaxWidth, titleHeight);
    [_wordScrollView addSubview:self.messageLab];
    _messageLab.frame = CGRectMake(alertMargin / 2.0, _titleLab.bottom, labelMaxWidth, messageHeight);
}

/// 动画显示
- (void)animationShow {
    _backView.alpha = 0;
    _containView.top = self.height;
    [UIView animateWithDuration:_animationDuration ? _animationDuration : 0.25 animations:^{
        _backView.alpha = 1;
        CGFloat safeAreaHeight = [self safeAreaHeight];
        safeAreaHeight = safeAreaHeight > 0 ? safeAreaHeight - 10 : safeAreaHeight;
        _containView.top = self.height - _containView.height -  safeAreaHeight;
    }];
}

/// 动画隐藏
- (void)animationHide {
    _backView.alpha = 1;
    [UIView animateWithDuration:_animationDuration ? _animationDuration : 0.25 animations:^{
        _backView.alpha = 0;
        _containView.top = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (_didRemoveBlock) {
            _didRemoveBlock();
        }
    }];
}

/// 显示提示框
- (void)show {
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self layoutView];
    [self animationShow];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _isVertical = screenSize.width > screenSize.height;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

#pragma mark 事件
- (void)otherBtnAction:(UIButton *)sender {
    NSInteger index = sender.tag - 1000;
    YM_AlertSheetAction * action = _items[index];
    if (action.block) {
        action.block(index);
    }
    [self animationHide];
}

- (void)cancelBtnAction {
    for (YM_AlertSheetAction * action in _items) {
        [action clear];
    }
    if (_cancelAction.block) {
        _cancelAction.block(-1);
    }
    [self animationHide];
}

#pragma mark public
- (void)addAction:(YM_AlertSheetAction *)action {
    if (action.actionStyle == kAlertSheetAction_Cancel) {
        _cancelAction = action;
    } else {
        [_items addObject:action];
    }
}

#pragma mark setter
- (void)setBackColor:(UIColor *)backColor {
    _backColor = backColor;
}

#pragma mark getter
/// 获取文本所需大小
/// @param string 对该字符串进行计算
/// @param maxSize 大小限制
/// @param font 该字符串所要显示的字体
- (CGSize)sizeWithString:(NSString *)string maxSize:(CGSize)maxSize font:(UIFont *)font
{
    if (!string || string.length == 0) {
        return CGSizeMake(0, 0);
    }
    
    NSDictionary *attribute = @{NSFontAttributeName:font};
    
    CGSize retSize = [string boundingRectWithSize:maxSize
                                          options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                       attributes:attribute
                                          context:nil].size;
    return retSize;
}

- (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

/// 获取底部安全高度
- (CGFloat)safeAreaHeight {
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    } else {
        return 0;
    }
}

#pragma mark private
- (CGFloat)navigationHeight {
    if (_navigationBarHeight >= 0) {
        return _navigationBarHeight;
    }
    _navigationBarHeight = 0;
    UIViewController * controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController * tabbarController = (UITabBarController *)controller;
        for (UINavigationController * nav in tabbarController.viewControllers) {
            if ([nav isKindOfClass:[UINavigationController class]]) {
                _navigationBarHeight = nav.navigationBar.bounds.size.height;
                break;
            }
        }
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController * navController = (UINavigationController *)controller;
       _navigationBarHeight = navController.navigationBar.bounds.size.height;
    } else if ([controller isKindOfClass:[UIViewController class]]) {
       _navigationBarHeight = controller.navigationController.navigationBar.bounds.size.height;
    }
    return _navigationBarHeight;
}

- (CGFloat)naviHeight {
    return [self navigationHeight] + [self statusHeight];
}

- (CGFloat)statusHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

/** 获取安全区域 */
- (CGFloat)safeAreaBottom {
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    } else {
        return 0;
    }
}


#pragma mark 懒加载
- (UIView *)backView {
    if (!_backView) {
        UIView * view = [UIView new];
        view.frame = self.bounds;
        view.backgroundColor = _backColor ? _backColor : [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
        view.userInteractionEnabled = NO;
        _backView = view;
    }
    return _backView;
}

- (UIView *)containView {
    if (!_containView) {
        UIView * view = [UIView new];
//        view.backgroundColor = [UIColor redColor];
        _containView = view;
    }
    return _containView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:_cancelAction.title forState:UIControlStateNormal];
        button.titleLabel.font = _cancelAction.titleFont;
        [button setTitleColor:_cancelAction.titleColor forState:UIControlStateNormal];
        [button setTitleColor:_cancelAction.titleColor.ymAlpha(0.5) forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIColor whiteColor].toImage forState:UIControlStateNormal];
        [button setBackgroundImage:[self imageFromColor:[UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1]] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 10;
        _cancelBtn = button;
    }
    return _cancelBtn;
}

- (UIView *)containTopView {
    if (!_containTopView) {
        UIView * view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 10;
        view.clipsToBounds = YES;
        _containTopView = view;
    }
    return _containTopView;
}

- (UIScrollView *)itemScrollView {
    if (!_itemScrollView) {
        UIScrollView * scroll = [UIScrollView new];
        scroll.delaysContentTouches = NO;
        _itemScrollView = scroll;
    }
    return _itemScrollView;
}

- (UIScrollView *)wordScrollView {
    if (!_wordScrollView) {
        UIScrollView * scroll = [UIScrollView new];
        scroll.delaysContentTouches = NO;
        _wordScrollView = scroll;
    }
    return _wordScrollView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        UILabel * label = [UILabel new];
        label.font = _titleFont;
        label.textColor = _titleColor;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = _title;
        _titleLab = label;
    }
    return _titleLab;
}

- (UILabel *)messageLab {
    if (!_messageLab) {
        UILabel * label = [UILabel new];
        label.font = _messgeFont;
        label.textColor = _messgeColor;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = _message;
        _messageLab = label;
    }
    return _messageLab;
}

- (UIButton *)buttonWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                    titleFont:(UIFont *)titleFont
                        image:(UIImage *)image
                    backColor:(UIColor *)backColor
                       action:(SEL)action {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.clipsToBounds = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[self imageFromColor:backColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageFromColor:[UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1]] forState:UIControlStateHighlighted];
    button.backgroundColor = backColor;
    
    CGSize titleLabSize = [self sizeWithString:title maxSize:CGSizeMake(0, itemHeight) font:titleFont];
    UILabel * titleLab = [UILabel new];
    titleLab.size = CGSizeMake(titleLabSize.width, itemHeight);
    titleLab.center = CGPointMake(_containView.width / 2.0, itemHeight / 2.0);
    titleLab.text = title;
    titleLab.textColor = titleColor;
    titleLab.font = titleFont;
    titleLab.textAlignment = NSTextAlignmentCenter;
    [button addSubview:titleLab];
    
    UIImageView * imageView = [UIImageView new];
    imageView.size = CGSizeMake(image.size.width, image.size.height);
    imageView.right = titleLab.left - 5;
    imageView.centerY = titleLab.centerY;
    imageView.image = image;
    [button addSubview:imageView];
    
    return button;
}

@end



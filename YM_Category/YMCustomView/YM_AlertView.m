//
//  YM_AlertView.m
//  YM_AlertView
//
//  Created by 黄玉洲 on 2018/6/20.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_AlertView.h"
#import "YM_AlertButtonTableView.h"
#import "UIColor+YMCustomView.h"
#import "UIView+YMCustomView.h"
#pragma mark - YM_AlertView
@interface YM_AlertView ()
{
    NSString * _title;                  // 标题
    UIFont   * _titleFont;
    NSString * _message;                // 内容
    UIFont   * _messageFont;
    
    YM_AlertViewItem * _cancelButtonItem;      // 取消按钮标题
    NSArray  <YM_AlertViewItem *> * _otherButtonItems; // 其他按钮标题
    
    CGFloat _screenWidth;       // 屏幕宽度
    CGFloat _screenHeight;      // 屏幕高度
    
    CGFloat _whiteViewWidth;    // 白色视图宽度
    CGFloat _whiteViewHeight;   // 白色视图高度
    
    CGFloat _iPhone_width;      // 参照设计图的宽度
    CGFloat _iPhone_height;     // 参照设计图的高度
    CGFloat _width_ratio;       // 宽度屏幕比例
    
    CGFloat _titleLabelY;       // 标题的起始Y坐标
    
    CGFloat _labelX;            // 标题和内容的起始坐标X
    CGFloat _labelWidth;        // 标题和内容的宽度
    
    CGFloat _buttonHeight;      // 按钮的高度
    
    NSInteger _numberOfButtons; // 获取按钮个数
    
    CGFloat _whiteViewMargin;   // 当白色界面超出屏幕宽度时，做一个边距限制，使其不遮挡住状态栏
    
    CGFloat _bottomDistance;    // 滚动视图与按钮的距离
}

@property (strong, nonatomic) UIView * backView;                // 背景视图
@property (strong, nonatomic) UIView * whiteView;               // 白色视图
@property (strong, nonatomic) UIScrollView * scrollView;        // 滚动视图
@property (strong, nonatomic) UILabel * titleLabel;             // 标题
@property (strong, nonatomic) UILabel * messageLabel;           // 内容

@property (strong, nonatomic) UIView * separatorView;           // 分隔线

@property (strong, nonatomic) YM_AlertButtonTableView * buttonTableView;


@property (nonatomic, strong) UIButton * cancelButton;          // 取消按钮
@property (nonatomic, strong) NSMutableArray <YM_AlertViewItem *> * buttonTitles;    // 所有按钮title，可用来获取按钮个数

@property (nonatomic, strong) UIColor * lineColor;              // 线条颜色
@property (nonatomic, strong) NSString * boldFont;              // 加粗字体
@property (nonatomic, strong) NSString * fineFont;              // 无加粗字体

@end


@implementation YM_AlertView

/// 初始化方法
/// @param title 标题
/// @param message 内容
/// @param cancelButtonItem 取消按钮
/// @param otherButtonItems 其他按钮
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
             cancelButtonItem:(YM_AlertViewItem *)cancelButtonItem
             otherButtonItems:(NSArray <YM_AlertViewItem *> *)otherButtonItems {
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if (self) {
        _title = title;
        _message = message;
        
        _cancelButtonItem = cancelButtonItem;
        _otherButtonItems = otherButtonItems;
        
        [self initData];
        [self initUI];
    }
    
    return self;
}

#pragma mark - 初始化方法
- (void)initData
{
    // 获取屏幕宽高
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    // 设计图的宽高
    _iPhone_width = 375.0;
    _iPhone_height = 667.0;
    
    // 宽度比例
    _width_ratio = _screenWidth / _iPhone_width;
    
    // 白色界面的宽度
    _whiteViewWidth = 275 * _width_ratio;
    
    // 默认值（标题只限制一行）
    _titleLabelY = 15.0;
    _labelX = 5.0;
    _labelWidth = _whiteViewWidth - _labelX * 2.0;
    _buttonHeight = kAlertBtnHeight;
    _animationDuration = 0.8;
    _whiteViewMargin = 64;
    _bottomDistance = 5;
    
    // 线条颜色/字体样式
    _boldFont = @"Arial-BoldMT";
    _titleFont = [UIFont fontWithName:_boldFont size:16.0];
    _fineFont = @"Arial";
    _messageFont = [UIFont fontWithName:_fineFont size:14.0];
    _lineColor = [UIColor grayColor];
    
    // 所有按钮的Item
    _buttonTitles= [[NSMutableArray alloc] init];
    if (_cancelButtonItem) {
        [_buttonTitles addObject:_cancelButtonItem];
    }
    [_buttonTitles addObjectsFromArray:_otherButtonItems];
}

- (void)initUI
{
    // 设置界面大小
    self.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
    
    // 添加黑色背景视图
    [self addSubview:self.backView];
    
    // 添加白色视图
    [self addSubview:self.whiteView];
    [_whiteView addSubview:self.scrollView];
    [_scrollView addSubview:self.titleLabel];
    [_scrollView addSubview:self.messageLabel];
    
    // 分隔线
    [_whiteView addSubview:self.separatorView];
    
    // 按钮滚动视图
    if (_buttonTitles.count > 2) {
        [_whiteView addSubview:self.buttonTableView];
    }
    
    // 添加按钮
    [self referenceButtonNumSetPage];
}

#pragma mark 界面配置
/// 重新计算白色视图的高度
- (void)againCalculateWhiteViewHeight:(CGFloat)buttonsScrollViewHeight {
    // 获取标题所需的高度
    CGSize titleLabelSize = [self calculateRectWithSize:CGSizeMake(_labelWidth, 0)
                                              andString:_title
                                                andFont:_titleFont];
    
    // 获取内容所需高度
    CGSize messageLabelSize = [self calculateRectWithSize:CGSizeMake(_labelWidth, 0)
                                                andString:_message
                                                  andFont:_messageFont];
    
    // 获取白色界面应有的高度，大于屏幕高度(-40)则设置为屏幕高度(-40)
    // 计算scrollView应有的高度和内容大小
    _whiteViewHeight = _titleLabelY + titleLabelSize.height + messageLabelSize.height + _buttonHeight + _bottomDistance;
    
    // 获取scrollView的滚动范围
    CGSize contentSize = CGSizeMake(0, 0);
    CGFloat scrollViewHeight = 0;
    if (_whiteViewHeight >= _screenHeight - _whiteViewMargin) {
        contentSize = CGSizeMake(0, _whiteViewHeight - _buttonHeight - _titleLabelY);
        _whiteViewHeight = _screenHeight - _whiteViewMargin;
    } else{
        contentSize = CGSizeMake(0, _whiteViewHeight - _buttonHeight);
    }
    
    BOOL moreThanMax = (buttonsScrollViewHeight / [UIScreen mainScreen].bounds.size.height) > 0.34;
    CGFloat buttonMaxHeight = 0;
    if (moreThanMax) {
        buttonMaxHeight = [UIScreen mainScreen].bounds.size.height * 0.34;
    } else {
        buttonMaxHeight = buttonsScrollViewHeight;
    }
    scrollViewHeight = _whiteViewHeight - buttonMaxHeight;
    
    // 标题Label
    _titleLabel.frame = CGRectMake( _labelX, _titleLabelY, _labelWidth, titleLabelSize.height);
    
    // _messageLabel的Y坐标
    CGFloat messagePointY = _titleLabel.bounds.size.height + _titleLabelY;
    if (!_title || [_title isEqual:@""]) {
        messagePointY = _titleLabelY;
    }
    
    // 内容Label
    _messageLabel.frame = CGRectMake(_labelX, messagePointY, _labelWidth, messageLabelSize.height);
    
    // scrollView
    _scrollView.frame = CGRectMake(0, 0, _whiteViewWidth, scrollViewHeight);
    _scrollView.contentSize = contentSize;

    _separatorView.frame = CGRectMake(0, _scrollView.bottom-0.5, _scrollView.width, 0.5);
    
    if (_buttonTitles.count > 2) {
        _buttonTableView.frame = CGRectMake(0, _separatorView.bottom, _scrollView.width, buttonMaxHeight);
    } else {
        _buttonTableView.frame = CGRectZero;
    }
    
    
    // 重新配置白色界面的高度和位置
    CGRect whiteViewRect = _whiteView.frame;
    whiteViewRect.size.height = _whiteViewHeight;
    _whiteView.frame = whiteViewRect;
    _whiteView.center = self.center;
}

/// 根据按钮的个数来配置界面
- (void)referenceButtonNumSetPage {
    BOOL moreThan2 = [_buttonTitles count] > 2;
    if (moreThan2) {
        [self loadVerticalButtons];
    } else {
        [self loadHorizontalButtons];
    }
}

/// 按钮小于等于2个时进行加载
- (void)loadHorizontalButtons {
    [self againCalculateWhiteViewHeight:_buttonHeight];
    
    // 计算每个按钮的宽度并加载
    CGFloat buttonWidth = _whiteViewWidth / [_buttonTitles count] / 1.0;
    for (int i = 0; i < [_buttonTitles count]; i++) {
        // 按钮
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonWidth * i, _scrollView.bottom, buttonWidth, _buttonHeight);
        button.tag = 100 + i;
        [button setTitle:_buttonTitles[i].text forState:UIControlStateNormal];
        [button setTitleColor:_buttonTitles[i].textColor forState:UIControlStateNormal];
        [button setTitleColor:_buttonTitles[i].textColor.ymAlpha(0.5) forState:UIControlStateHighlighted];
        button.titleLabel.font = _buttonTitles[i].textFont;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_whiteView addSubview:button];
        
        if (_buttonTitles.count == 1) {
            break;
        }
        // 垂直线
        UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(buttonWidth, 5, 0.5, _buttonHeight - 10)];
        verticalLine.backgroundColor = _lineColor;
        verticalLine.tag = 300 + i;
        [button addSubview:verticalLine];
    }
}


/// 按钮大于3个时进行加载
- (void)loadVerticalButtons {
    // 计算每个按钮的宽度
    CGFloat totalHeight = _buttonHeight * [_buttonTitles count];
    [self againCalculateWhiteViewHeight:totalHeight];
}

/**
 *  获取指定索引按钮的标题
 *
 *  @param buttonIndex 指定索引
 *
 *  @return 返回标题
 */
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    NSInteger buttonTag = buttonIndex + 100;
    NSInteger labelTag = buttonIndex + 200;
    UIButton * button = (UIButton *)[_whiteView viewWithTag:buttonTag];
    UILabel * label = (UILabel *)[button viewWithTag:labelTag];
    return label.text;
}

#pragma mark - 获取字符串所需高度（宽度自设）
/**
 *  显示界面
 *
 *  @param size   大小限制
 *  @param string 对该字符串进行计算
 *  @param font   该字符串所要显示的字体
 *
 *  @return 字符串所需尺寸
 */
- (CGSize)calculateRectWithSize:(CGSize)size andString:(NSString *)string andFont:(UIFont *)font
{
    if (!string) {
        string = @"";
    }
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    CGSize retSize = [string boundingRectWithSize:size
                                          options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                       attributes:attribute
                                          context:nil].size;
    return retSize;
}

#pragma mark - 界面显隐
/**
 *  显示界面
 */
- (void)show
{
    // 创建新的window
    [self createNewWindow];
    
    // 将当前界面添加到旧的window上
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    // 启用动画
    [self animationEffect];
}

/**
 *  创建一个新的window(用于遮挡状态栏)
 */
- (void)createNewWindow
{
    if (!_myWindow) {
        _myWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _myWindow.backgroundColor = [UIColor clearColor];
        _myWindow.windowLevel = UIWindowLevelStatusBar;
        
        UIView * view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        view.backgroundColor = [UIColor clearColor];
        [_myWindow addSubview:view];
    }
    [_myWindow makeKeyAndVisible];
}

/// 动画效果
- (void)animationEffect
{
    if (_animationType == 0) {
        return;
    }
    // 由小变大
    else if (_animationType == 1){
        CGAffineTransform affine = CGAffineTransformIdentity;
        affine = CGAffineTransformScale(affine, 0.5, 0.5);
        _whiteView.transform = affine;
        [UIView animateWithDuration:_animationDuration animations:^{
            self.whiteView.transform = CGAffineTransformIdentity;
        }];
    }
    // 由大变小
    else if(_animationType == 2){
        self.alpha = 0;
        self.transform = CGAffineTransformScale(self.transform, 1.5, 1.6);;
        [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformIdentity;
            self.alpha = 1;
        } completion:nil];
    }
}

/**
 *  移除当前界面
 */
- (void)removePage
{
    _myWindow = nil;
    [self removeFromSuperview];
}

#pragma mark - 按钮事件
/**
 *  按钮事件
 *
 *  @param sender 被点击的按钮
 */
- (void)buttonPressed:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    [self.delegate myAlertView:self clickedButtonAtIndex:index];
    [self removePage];
}

#pragma mark 重写
- (BOOL)touchesShouldCancelInContentView:(UIView*)view {
     return YES;
}

#pragma mark property
- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
        _backView.backgroundColor = [UIColor grayColor];
        _backView.alpha = 0.5;
    }
    return _backView;
}

- (UIView *)whiteView
{
    if (!_whiteView) {
        _whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _whiteViewWidth, 100)];
        _whiteView.center = self.center;
        _whiteView.layer.cornerRadius = 10;
        _whiteView.layer.masksToBounds = YES;
        _whiteView.alpha = 1;
        _whiteView.backgroundColor = [UIColor whiteColor];
    }
    return _whiteView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delaysContentTouches = NO;
    }
    return _scrollView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = _title;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = _titleFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.text = _message;
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = _messageFont;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [UIView new];
        _separatorView.backgroundColor = _lineColor;
    }
    return _separatorView;
}

- (YM_AlertButtonTableView *)buttonTableView {
    if (!_buttonTableView) {
        _buttonTableView = [[YM_AlertButtonTableView alloc] initWithItems:_buttonTitles];
        
        __weak __typeof(self) weakSelf = self;
        _buttonTableView.didSelectedBlock = ^(NSInteger index) {
            __strong __typeof(weakSelf) self = weakSelf;
            [self.delegate myAlertView:self clickedButtonAtIndex:index];
            [self removePage];
        };
    }
    return _buttonTableView;
}


#pragma mark setter
- (void)setTitle:(NSString *)title
{
    if (title) {
        _title = title;
        _titleLabel.text = _title;
    }
}

- (void)setMessage:(NSString *)message
{
    if (message) {
        _message = message;
        _messageLabel.text = _message;
    }
}



@end


//
//  YM_PayPasswordAlertView.m
//  YM_PayPasswordView
//
//  Created by huangyuzhou on 2018/10/31.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PayPasswordAlertView.h"
#import "YM_PasswordInputView.h"
#import "UIView+YMPwdExtension.h"

#define kColorComplete [UIColor colorWithRed:0.214 green:0.526 blue:1.000 alpha:1.000]
#define kColorNormal   [UIColor colorWithWhite:0.584 alpha:1.000]
#define kColorMask     [UIColor colorWithWhite:0.000 alpha:0.400]
#define kFrameAlert    CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width*0.8, 168)
#define kColorLine     [UIColor colorWithWhite:0.824 alpha:1.000]
#define kColorCancel   [UIColor colorWithRed:0.967 green:0.159 blue:0.047 alpha:1.000]

static const CGFloat duration = 0.25;

@interface YM_PayPasswordAlertView ()

@property (strong, nonatomic) UIView         * maskView;         // 遮罩
@property (strong, nonatomic) UILabel        * titleLabel;       // 标题
@property (strong, nonatomic) YM_PasswordInputView * pwdInputView;     // 输入区
@property (strong, nonatomic) UIButton       * completeBtn;      // 确定
@property (assign, nonatomic, getter=isComplete) BOOL complete;  // 是否完成
@property (copy, nonatomic) NSString * pwd;                      // 密码

@end

@implementation YM_PayPasswordAlertView


#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    // 设置默认值
    self.length = 6;
    
    CGFloat padding = 20.f; // 密码框两边边距
    CGFloat margin = 15.f;  // 边距
    CGFloat width = [UIScreen mainScreen].bounds.size.width*0.8; // 视图容器宽度
    CGFloat titleH = 20.f; // 标题标签高度
    CGFloat inputH = (width-padding*2)/self.length; // 输入框高度
    CGFloat btnH = 44.f; // 按钮高度
    CGFloat height = titleH+inputH+btnH+margin*4+1.f; // 视图容器高度
    
    
    self.frame = CGRectMake(0, 0, width, height);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 8.f;
    
    // 标题标签
    self.titleLabel.frame = CGRectMake(padding, margin, inputH*self.length, titleH);
    [self addSubview:self.titleLabel];
    
    // 上分隔线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom+margin, self.width, 0.5)];
    topLine.backgroundColor = kColorLine;
    [self addSubview:topLine];
    
    // 密码输入视图
    self.pwdInputView.frame = CGRectMake(padding, topLine.bottom+margin, inputH*self.length, inputH);
    [self addSubview:self.pwdInputView];
    __weak typeof(&*self)weakSelf = self;
    // 输入框回调
    self.pwdInputView.inputDidCompletion = ^(NSString *pwd) {
        if (pwd.length == weakSelf.pwdInputView.length) {
            weakSelf.pwd = pwd;
            weakSelf.complete = YES;
        }else {
            weakSelf.pwd = @"";
            weakSelf.complete = NO;
        }
    };
    
    // 下分割线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.pwdInputView.bottom+margin, self.width, 0.5)];
    bottomLine.backgroundColor = kColorLine;
    [self addSubview:bottomLine];
    
    // 垂直分隔线
    UIView *bottomVLine = [[UIView alloc] initWithFrame:CGRectMake((self.width-0.5)*0.5, bottomLine.bottom, 0.5, btnH)];
    bottomVLine.backgroundColor = kColorLine;
    [self addSubview:bottomVLine];
    
    // 取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setFrame:CGRectMake(0, bottomLine.bottom, (self.width-0.5)*0.5, btnH)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:kColorCancel forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.completeBtn];
    
    // 确定按钮
    self.completeBtn.frame = CGRectMake(bottomVLine.right, bottomLine.bottom, (self.width-0.5)*0.5, btnH);
    [self addSubview:cancelBtn];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - 设置器/读取器
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setLength:(NSUInteger)length
{
    _length = length;
    self.pwdInputView.length = length;
}

- (void)setComplete:(BOOL)complete
{
    _complete = complete;
    if (complete) {
        self.completeBtn.enabled = YES;
        [self.completeBtn setTitleColor:kColorComplete forState:UIControlStateNormal];
    }else {
        self.completeBtn.enabled = NO;
        [self.completeBtn setTitleColor:kColorNormal forState:UIControlStateNormal];
    }
}

- (YM_PasswordInputView *)pwdInputView
{
    if (!_pwdInputView) {
        _pwdInputView = [[YM_PasswordInputView alloc] init];
    }
    return _pwdInputView;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication].windows lastObject].bounds];
        _maskView.backgroundColor = kColorMask;
        _maskView.alpha = 0.f;
    }
    return _maskView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithWhite:0.202 alpha:1.000];
        _titleLabel.font = [UIFont systemFontOfSize:16.f];
    }
    return _titleLabel;
}

- (UIButton *)completeBtn
{
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_completeBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_completeBtn setTitleColor:kColorNormal forState:UIControlStateNormal];
        [_completeBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_completeBtn setEnabled:NO];
        [_completeBtn addTarget:self action:@selector(complete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

#pragma mark - 共有方法
/**
 显示视图
 */
- (void)show
{
    UIWindow *keyWindow = [[UIApplication sharedApplication].windows lastObject];
    [keyWindow addSubview:self.maskView];
    [keyWindow addSubview:self];
    
    self.center = CGPointMake(keyWindow.center.x, (keyWindow.frame.size.height - 216) * 0.5);
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    
    __weak typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.maskView.alpha = 1.f;
        weakSelf.alpha = 1.f;
        weakSelf.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        if (finished) {
            [weakSelf.pwdInputView becomeFirstResponder];
        }
    }];
}

#pragma mark - 私有方法
/**
 移除当前密码输入界面
 */
- (void)dismiss
{
    [self.pwdInputView endEditing:YES];
    __weak typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.alpha = 0.f;
        weakSelf.maskView.alpha = 0.f;
        weakSelf.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished) {
        if (finished) {
            weakSelf.complete = NO;
            [weakSelf removeFromSuperview];
            [weakSelf.maskView removeFromSuperview];
        }
    }];
}

/**
 完成输入
 */
- (void)complete:(id)sender
{
    if (_completeAction) {
        _completeAction(self.pwd);
    }
    [self dismiss];
}

/**
 取消输入
 */
- (void)cancel:(id)sender
{
    [self dismiss];
}



@end

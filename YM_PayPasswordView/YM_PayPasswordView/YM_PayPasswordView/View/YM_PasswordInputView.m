//
//  YM_PasswordInputView.m
//  YM_PayPasswordView
//
//  Created by huangyuzhou on 2018/10/31.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_PasswordInputView.h"

#define kColorBorder [UIColor colorWithWhite:0.824 alpha:1.000]
static const CGFloat dotDiameter = 10.f; // 密码点直径

@interface YM_PasswordInputView ()

@property (strong, nonatomic) NSMutableArray *secureDots; // 密码黑点
@property (strong, nonatomic) UITextField *responder;     // 键盘响应器

@end

@implementation YM_PasswordInputView


#pragma mark - 生命周期
- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    [self addNotifications];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    [self addNotifications];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = dotDiameter * 0.5; // 每个点的大小
    CGFloat lineX = 0.f;                // 垂直线x坐标
    CGFloat lineY = 0.f;                // 垂直线y坐标
    CGSize  lineSize = CGSizeMake(0.5, self.frame.size.height); // 线的大小
    CGFloat w = self.frame.size.width / self.length; // 输入框宽度
    
    // 加载垂直线
    for (int i = 0; i < self.length-1; i++) {
        UIView * line = self.subviews[i];
        lineX = w * (i + 1);
        line.frame = CGRectMake(lineX, lineY, lineSize.width, lineSize.height);
    }
    
    // 安全点位置调整
    for (int i = 0; i < self.secureDots.count; i++) {
        CAShapeLayer * dot = self.secureDots[i];
        dot.position = CGPointMake(w * (0.5 + i) - margin, self.frame.size.height * 0.5 - margin);
    }
}

#pragma mark - 重写
/**
 成为第一响应者
 */
- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    [self addSubview:self.responder];
    [self.responder becomeFirstResponder];
    return YES;
}

/**
 取消第一响应者
 */
- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    [self endEditing:YES];
    return YES;
}

/**
 设置编辑状态
 */
- (BOOL)endEditing:(BOOL)force
{
    [super endEditing:force];
    if (force) {
        self.responder.text = nil;
        [self.secureDots enumerateObjectsUsingBlock:^(CAShapeLayer *_Nonnull dot, NSUInteger idx, BOOL * _Nonnull stop) {
            dot.hidden = YES;
        }];
    }
    return force;
}

#pragma mark - 设置器/读取器
- (void)setLength:(NSUInteger)length
{
    _length = length;
    if (length > 0) {
        [self configurViewWithLength:length];
    }
}

- (NSMutableArray *)secureDots
{
    if (!_secureDots) {
        _secureDots = [NSMutableArray arrayWithCapacity:self.length];
    }
    return _secureDots;
}

- (UITextField *)responder
{
    if (!_responder) {
        _responder = [[UITextField alloc] initWithFrame:CGRectZero];
        _responder.clearsOnBeginEditing = YES;
        _responder.keyboardType = UIKeyboardTypeNumberPad;
        _responder.hidden = YES;
    }
    return _responder;
}

#pragma mark - 私有方法
/**
 配置安全点
 */
- (void)configurViewWithLength:(NSUInteger)length
{
    
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = kColorBorder.CGColor;
    
    // 分隔线
    for (int i = 0; i < length - 1; i++) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithWhite:0.824 alpha:1.000];
        [self addSubview:line];
    }
    
    // 安全点绘制
    [self.secureDots removeAllObjects];
    for (int i = 0; i < length; i++) {
        CAShapeLayer *dot = [CAShapeLayer layer];
        dot.fillColor = [UIColor blackColor].CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, dotDiameter, dotDiameter)];
        dot.path = path.CGPath;
        dot.hidden = YES;
        [self.layer addSublayer:dot];
        
        [self.secureDots addObject:dot];
    }
}

/**
 注册通知
 */
- (void)addNotifications
{
    __weak typeof(&*self)weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        NSUInteger length = weakSelf.responder.text.length;
        if (length <= weakSelf.length && weakSelf.inputDidCompletion) {
            self.inputDidCompletion(weakSelf.responder.text);
        }else if (length > weakSelf.length) {
            self.responder.text = [weakSelf.responder.text substringToIndex:weakSelf.length];
        }
        [self.secureDots enumerateObjectsUsingBlock:^(CAShapeLayer *dot, NSUInteger idx, BOOL * stop) {
            dot.hidden = idx < length ? NO : YES;
        }];
    }];
}

@end

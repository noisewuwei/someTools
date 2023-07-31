//
//  YM_ValidateCodeView.m
//  YM_ValidateCodeView
//
//  Created by huangyuzhou on 2018/9/21.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_ValidateCodeView.h"
#define ARC4RAND_MAX 0x100000000
@interface YM_ValidateCodeView ()

/** 验证码数量 */
@property (assign, nonatomic) NSInteger  codeNumber;

/** 验证码 */
@property (copy, nonatomic)   NSString * codeStr;

/** 验证码背景 */
@property (strong, nonatomic) UIView   * bgView;

/** 验证码区间 */
@property (strong, nonatomic) NSArray  * randomCodes;

@end

@implementation YM_ValidateCodeView

- (instancetype)initWithCodeNumber:(NSInteger)codeNumber {
    if ([super init]) {
        _codeNumber = codeNumber;
        [self initData];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshCode];
}

#pragma mark - 数据
- (void)initData {
    _randomCodes = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
}

/// 自定义验证码的取值范围
- (void)customRandomCodes:(NSArray <NSString *> *)codes {
    if (codes.count > 0) {
        _randomCodes = codes;
    }
}

/** 刷新验证码 */
- (void)refreshCode {
    for(NSInteger i = 0; i < _codeNumber; i++) {
        NSInteger index = arc4random() % ([_randomCodes count] - 1);
        NSString * oneText = [_randomCodes objectAtIndex:index];
        _codeStr = (i==0) ? oneText : [_codeStr stringByAppendingString:oneText];
    }
    [self layoutView];
    
    if (self.validateCodeBlock) {
        self.validateCodeBlock(_codeStr);
    }
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    if (_bgView) {
        [_bgView removeFromSuperview];
        _bgView= nil;
    }
    [self addSubview:self.bgView];
    
    CGSize textSize = [@"W" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    int randWidth = self.frame.size.width / _codeStr.length - textSize.width;
    int randHeight = self.frame.size.height - textSize.height;
    
    for (int i = 0; i < _codeStr.length; i++) {
        
        CGFloat px = arc4random() % (randWidth == 0 ? 1 : randWidth) + i*(self.frame.size.width-3) / _codeStr.length;
        CGFloat py = arc4random()%(randHeight == 0 ? 1 : randHeight);
        UILabel * label = [[UILabel alloc] initWithFrame: CGRectMake(px+3, py, textSize.width, textSize.height)];
        label.textColor = [self getRandomBgColorWithAlpha:1];
        label.text = [NSString stringWithFormat:@"%C",[_codeStr characterAtIndex:i]];
        label.font = [UIFont systemFontOfSize:20];
        if (_isRatation) {
            //随机-1到1
            double r = (double)arc4random() / ARC4RAND_MAX * 2 - 1.0f;
            if (r>0.3) {
                r=0.3;
            }else if(r<-0.3){
                r=-0.3;
            }
            label.transform = CGAffineTransformMakeRotation(r);
        }
        
        [_bgView addSubview:label];
    }
    
    for (int i = 0; i<10; i++) {
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGFloat pX = arc4random() % (int)CGRectGetWidth(self.frame);
        CGFloat pY = arc4random() % (int)CGRectGetHeight(self.frame);
        [path moveToPoint:CGPointMake(pX, pY)];
        CGFloat ptX = arc4random() % (int)CGRectGetWidth(self.frame);
        CGFloat ptY = arc4random() % (int)CGRectGetHeight(self.frame);
        [path addLineToPoint:CGPointMake(ptX, ptY)];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.strokeColor = [[self getRandomBgColorWithAlpha:0.2] CGColor];//layer的边框色
        layer.lineWidth = 1.0f;
        layer.strokeEnd = 1;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.path = path.CGPath;
        [_bgView.layer addSublayer:layer];
    }
}

#pragma mark - 手势
- (void)tapAction:(UIGestureRecognizer *)recognize {
    [self refreshCode];
}

#pragma mark - private
- (UIColor *)getRandomBgColorWithAlpha:(CGFloat)alpha {
    float red = arc4random() % 100 / 100.0;
    float green = arc4random() % 100 / 100.0;
    float blue = arc4random() % 100 / 100.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return color;
}

#pragma mark - 懒加载
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:self.bounds];
        [_bgView setBackgroundColor:[self getRandomBgColorWithAlpha:0.5]];
    }
    return _bgView;
}

@end

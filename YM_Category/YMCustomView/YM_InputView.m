//
//  YM_InputView.m
//  KKCap
//
//  Created by 黄玉洲 on 2020/4/12.
//  Copyright © 2020 TouchingApp. All rights reserved.
//

#import "YM_InputView.h"
#import <Masonry/Masonry.h>
@interface YM_InputView ()
{
    UITapGestureRecognizer * _tapGesture;
    NSString * _content;
}
@property (strong, nonatomic) UIView * leftView;
@property (strong, nonatomic) UIView * rightView;

@property (strong, nonatomic) UIView * separatorView;

@property (strong, nonatomic) UITextField * textField;

@end

@implementation YM_InputView

- (instancetype)initWithLeftView:(UIView *)leftView
                       rightView:(UIView *)rightView {
    if (self = [super init]) {
        _leftView = leftView;
        _rightView = rightView;
        _textViewEdit = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = _corner;
    self.clipsToBounds = YES;
    [self layoutView];
    [self refreshPlaceholderAttribute];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {
    if (_leftView) {
        [self addSubview:_leftView];
        [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_leftEdge);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(_leftView.bounds.size.width);
            make.height.mas_equalTo(_leftView.bounds.size.height);
        }];
        
        [self addSubview:self.separatorView];
        [_separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_leftView.mas_right);
            make.width.mas_equalTo(1);
            make.centerY.mas_equalTo(self);
            make.height.mas_equalTo(16);
        }];
    }
    
    if (_rightView) {
        [self addSubview:_rightView];
        [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.right.mas_equalTo(-_rightEdge);
            make.width.mas_equalTo(_rightView.bounds.size.width);
            make.height.mas_equalTo(_rightView.bounds.size.height);
        }];
    }
    
    [self addSubview:self.textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        if (_separatorView) {
            make.left.mas_equalTo(_separatorView.mas_right).offset(11);
        } else {
            make.left.mas_equalTo(_leftEdge);
        }
        if (_rightView) {
            make.right.mas_equalTo(_rightView.mas_left);
        } else {
            make.right.mas_equalTo(-_rightEdge);
        }
        make.top.bottom.mas_equalTo(0);
    }];
}

/// 设置右侧视图是否展示
/// @param isShow 是否展示
- (void)setRightViewShow:(BOOL)isShow {
    if (_rightView) {
        _rightView.hidden = !isShow;
        
//        [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
//            if (_separatorView) {
//                make.left.mas_equalTo(_separatorView.mas_right).offset(11);
//            } else {
//                make.left.mas_equalTo(0);
//            }
//            if (_rightView && isShow) {
//                make.right.mas_equalTo(_rightView.mas_left);
//            } else {
//                make.right.mas_equalTo(0);
//            }
//            make.top.bottom.mas_equalTo(0);
//        }];
    }
}

#pragma mark - 事件
- (void)tapGestureAction:(UIGestureRecognizer *)recognize {
    _tapGestureBlock(self);
}

#pragma mark - setter
- (void)setSeparatorViewColor:(UIColor *)separatorViewColor {
    if (separatorViewColor) {
        _separatorViewColor = separatorViewColor;
        _separatorView.backgroundColor = separatorViewColor;
    }
}

- (void)setTextViewEdit:(BOOL)textViewEdit {
    _textViewEdit = textViewEdit;
    _textField.userInteractionEnabled = textViewEdit;
}

- (void)setTapGestureBlock:(void (^)(YM_InputView *))tapGestureBlock {
    if (tapGestureBlock) {
        _tapGestureBlock = tapGestureBlock;
        
        if (_tapGesture) {
            [self removeGestureRecognizer:_tapGesture];
            _tapGesture = nil;
        }
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [self addGestureRecognizer:_tapGesture];
    }
}

- (void)setContent:(NSString *)content {
    _content = content;
    _textField.text = content;
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    _textField.font = textFont;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _textField.textColor = textColor;
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    [self refreshPlaceholderAttribute];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor {
    _placeHolderColor = placeHolderColor;
    [self refreshPlaceholderAttribute];
}

- (void)setPlaceHolderFont:(UIFont *)placeHolderFont {
    _placeHolderFont = placeHolderFont;
    [self refreshPlaceholderAttribute];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
    _attributedPlaceholder = attributedPlaceholder;
    _textField.attributedPlaceholder = attributedPlaceholder;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    _delegate = delegate;
    _textField.delegate = delegate;
}

/// 刷新富文本
- (void)refreshPlaceholderAttribute {
    UIColor * color = _placeHolderColor ?: [UIColor greenColor];
    NSString * placeHolder = _placeHolder ?: @"";
    UIFont * font = _placeHolderFont ?: _textField.font;
    
    NSRange range = NSMakeRange(0, placeHolder.length);
    NSMutableAttributedString * mAttibute = [[NSMutableAttributedString alloc] initWithString:placeHolder];
    if (_textField) {
        [mAttibute addAttribute:NSForegroundColorAttributeName value:color range:range];
        [mAttibute addAttribute:NSFontAttributeName value:font range:range];
        _textField.attributedPlaceholder = mAttibute;
    }
}

- (void)setCorner:(CGFloat)corner {
    _corner = corner;
}

- (void)setLeftEdge:(CGFloat)leftEdge {
    _leftEdge = leftEdge;
}

- (void)setRightEdge:(CGFloat)rightEdge {
    _rightEdge = rightEdge;
}

#pragma mark - getter
- (NSString *)content {
    return _textField.text;
}

- (UIView *)leftView {
    return _leftView;
}

- (UIView *)rightView {
    return _rightView;
}

#pragma mark - 懒加载
- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [UIView new];
        _separatorView.backgroundColor = _separatorViewColor;
    }
    return _separatorView;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField new];
        _textField.font = _textFont;
        _textField.textColor = _textColor ?: [UIColor blackColor];
        _textField.text = _content;
        _textField.delegate = _delegate;
    }
    return _textField;
}

@end

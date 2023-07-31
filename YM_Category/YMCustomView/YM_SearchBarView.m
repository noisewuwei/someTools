//
//  YM_SearchBarView.m
//  KKCap
//
//  Created by 海南有趣 on 2020/4/16.
//  Copyright © 2020 TouchingApp. All rights reserved.
//

#import "YM_SearchBarView.h"
#import <CoreText/CoreText.h>

#pragma mark - YM_SeachBar
@interface YM_SeachBar : UIView

@property (copy, nonatomic) NSString * deleteImageName;

@property (strong, nonatomic) UITextField * textField;

@property (strong, nonatomic) UIImageView * imageView;

@property (copy, nonatomic) void(^startEditBlock)(void);
@property (copy, nonatomic) void(^endEditBlock)(void);
@property (copy, nonatomic) void(^contentDidChangeBlock)(NSString * content);

@end

@interface YM_SeachBar () {
    NSString * _placeHolder;       // 占位符
    UIFont   * _placeHolderFont;   // 占位符字体
    UIColor  * _placeHolderColor;  // 占位符颜色
    UIImage  * _icon;              // 占位符视图
    
    CGFloat  _spaceWidth; // 图片和输入框的距离（默认10）
}

@property (copy, nonatomic)   NSString * content;
@property (strong, nonatomic) UIFont   * contentFont;
@property (strong, nonatomic) UIColor  * contentColor;

@end

@implementation YM_SeachBar

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
                      content:(NSString *)content
                 contentColor:(UIColor *)contentColor
                  contentFont:(UIFont *)contentFont
                  placeHolder:(NSString *)placeHolder
             placeHolderColor:(UIColor *)placeHolderColor
              placeHolderFont:(UIFont *)placeHolderFont
                         icon:(UIImage *)icon {
    if (self = [super initWithFrame:frame]) {
        _placeHolder = placeHolder;
        _placeHolderColor = placeHolderColor;
        _placeHolderFont = placeHolderFont;
        _icon = icon;
        _spaceWidth = 5;
        _content = content;
        _contentFont = contentFont;
        _contentColor = contentColor;
        [self registerNotification];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutView];
}

- (void)layoutView {
    [self addSubview:self.imageView];
    
    [self addSubview:self.textField];
}

#pragma mark 通知
/** 创建通知 */
- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditing:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidEndEditing:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}


/** 开始编辑输入框时 */
- (void)textFieldDidBeginEditing:(NSNotification *)notify {
    UITextField * textField = notify.object;
    if (![textField isEqual:_textField]) {
        return;
    }
    if (_startEditBlock) {
        _startEditBlock();
    }
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.imageView.frame;
        frame.origin.x = self->_spaceWidth+2;
        self.imageView.frame = frame;
        
        frame = self.textField.frame;
        frame.origin.x = self.imageView.frame.origin.x + self.imageView.frame.size.width + self->_spaceWidth;
        frame.size.width = self.bounds.size.width - frame.origin.x;
        self.textField.frame = frame;
    }];
}

/** 结束编辑输入框时 */
- (void)textFieldDidEndEditing:(NSNotification *)notify {
    UITextField * textField = notify.object;
    if (![textField isEqual:_textField]) {
        return;
    }
    if (_endEditBlock) {
        _endEditBlock();
    }
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.imageView.frame;
        frame.origin.x = self.bounds.size.width / 2.0 - self->_spaceWidth - self.imageView.bounds.size.width;
        self.imageView.frame = frame;
        
        frame = self.textField.frame;
        frame.origin.x = self.bounds.size.width / 2.0;
        frame.size.width = self.bounds.size.width - frame.origin.x;
        self.textField.frame = frame;
    }];
}

/** 输入框内容发生变化时 */
- (void)textFieldDidChange:(NSNotification *)notify {
    UITextField * textField = notify.object;
    if (![textField isEqual:_textField]) {
        return;
    }
    if (_contentDidChangeBlock) {
        _contentDidChangeBlock(_textField.text);
    }
}

#pragma mark - setter
- (void)setContent:(NSString *)content {
    _content = content;
    _textField.text = content;
}

- (void)setContentFont:(UIFont *)contentFont {
    if (contentFont) {
        _contentFont = contentFont;
        _textField.font = contentFont;
    }
}

- (void)setContentColor:(UIColor *)contentColor {
    if (contentColor) {
        _contentColor = contentColor;
        _textField.textColor = contentColor;
    }
}

#pragma mark 懒加载
- (UIImageView *)imageView {
    if (!_imageView) {
        UIImage * image = _icon;
        CGSize imageSize = image.size;
//        if (imageSize.height > self.height) {
//            CGFloat maxHeight = self.height - 10;
//            CGFloat fitWidth = imageSize.width * maxHeight / imageSize.height;
//            imageSize = CGSizeMake(fitWidth, maxHeight);
//        }
        UIImageView * imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = CGRectMake(self.bounds.size.width / 2.0 - imageSize.width - _spaceWidth, (self.bounds.size.height - imageSize.height) / 2.0, imageSize.width, imageSize.height);
        imageView.image = image;
        _imageView = imageView;
    }
    return _imageView;
}

- (UITextField *)textField {
    if (!_textField) {
        UITextField * textField = [UITextField new];
        textField.frame = CGRectMake(self.bounds.size.width / 2.0, 0, self.bounds.size.width / 2.0, self.bounds.size.height);
        textField.text = _content;
        textField.font = _contentFont;
        textField.textColor = _contentColor;
        
        // 富文本
        NSRange range = NSMakeRange(0, _placeHolder.length);
        NSMutableAttributedString * mAttribute = [[NSMutableAttributedString alloc] initWithString:_placeHolder];;
        [mAttribute addAttribute:NSFontAttributeName
                           value:_placeHolderFont
                           range:range];
        [mAttribute addAttribute:NSForegroundColorAttributeName
                           value:_placeHolderColor
                           range:range];
        textField.attributedPlaceholder = mAttribute;
        
        UIButton *button =  [textField valueForKey:@"_clearButton"];
        [button setImage:[UIImage imageNamed:@"public_delete"] forState:UIControlStateNormal];
        textField.clearButtonMode = UITextFieldViewModeAlways;
        
        _textField = textField;
    }
    return _textField;
}


@end

#pragma mark - YM_SearchBarView
@interface YM_SearchBarView ()

@property (strong, nonatomic) YM_SeachBar * searchBar;

@end

@implementation YM_SearchBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cancelBtnWidth = 60;
        _cancelBtnColor = [UIColor whiteColor];
        _cancelBtnFont = [UIFont systemFontOfSize:14.0f];
        _cancelBtnTitle = @"取消";
        
        _content = @"";
        _contentFont = [UIFont systemFontOfSize:14.0f];
        _contentColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutView];
}

#pragma mark 界面
/** 布局 */
- (void)layoutView {
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(self.bounds.size.width - _cancelBtnWidth, 0, _cancelBtnWidth, self.bounds.size.height);
    [cancelBtn setTitle:_cancelBtnTitle forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = _cancelBtnFont;
    [cancelBtn setTitleColor:_cancelBtnColor forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    [self addSubview:self.searchBar];
}

#pragma mark - 事件
- (void)cancelAction {
    [_searchBar endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(searchBarDidCancel:)]) {
        [self.delegate searchBarDidCancel:self];
    }
}

#pragma mark 动画
/** 开始编辑 */
- (void)startEdit {
    if ([self.delegate respondsToSelector:@selector(searchBarDidStartEdit:)]) {
        [self.delegate searchBarDidStartEdit:self];
    }
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.searchBar.frame;
        frame.size.width = self.bounds.size.width - self->_cancelBtnWidth;
        self.searchBar.frame = frame;
    }];
}

/** 结束编辑 */
- (void)endEdit {
    if ([self.delegate respondsToSelector:@selector(searchBarDidEndEdit:)]) {
        [self.delegate searchBarDidEndEdit:self];
    }
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.searchBar.frame;
        frame.size.width = self.bounds.size.width - self->_cancelBtnWidth;
        self.searchBar.frame = frame;
    }];
}

#pragma mark 懒加载
- (YM_SeachBar *)searchBar {
    if (!_searchBar) {
        YM_SeachBar * view =
        [[YM_SeachBar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)
                                   content:_content
                              contentColor:_contentColor
                               contentFont:_contentFont
                               placeHolder:_placeHolder
                          placeHolderColor:_placeHolderColor
                           placeHolderFont:_placeHolderFont
                                      icon:_icon];
        view.backgroundColor = _inputViewBackColor;
        view.layer.cornerRadius = 5;
        view.clipsToBounds = YES;
        view.deleteImageName = _deleteImageName;
        
        __weak __typeof(self) weakSelf = self;
        view.startEditBlock = ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self startEdit];
        };
        
        view.endEditBlock = ^{
            __strong __typeof(weakSelf) self = weakSelf;
            [self endEdit];
        };
        
        view.contentDidChangeBlock = ^(NSString *content) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self->_contentDidChangeBlock) {
                self->_contentDidChangeBlock(content);
            }
            
            if ([self.delegate respondsToSelector:@selector(searchBar:contentDidChange:)]) {
                [self.delegate searchBar:self contentDidChange:content];
            }
        };
        
        _searchBar = view;
    }
    return _searchBar;
}

@end

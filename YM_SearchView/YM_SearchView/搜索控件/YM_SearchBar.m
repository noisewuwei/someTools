//
//  YM_SearchBar.m
//  YM_SearchView
//
//  Created by 黄玉洲 on 2018/5/22.
//  Copyright © 2018年 黄玉洲. All rights reserved.
//

#import "YM_SearchBar.h"

#define SELF_WIDTH self.frame.size.width
#define SELF_HEIGHT self.frame.size.height

@interface YM_SearchBar ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView  * placeHolderView;// 占位符视图
@property (nonatomic, strong) UILabel * placeHolderLab; // 占位符文字
@property (nonatomic, strong) UIImageView * searchIV;   // 放大镜
@property (nonatomic, strong) UITextField * textField;  // 输入框

@end

@implementation YM_SearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initUI];
        [self createNotification];
    }
    return self;
}

#pragma mark - 初始化
- (void)initData
{
    _placeHolder = @"";
}

- (void)initUI
{
    self.backgroundColor = [UIColor cyanColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    
    // 输入框视图
    [self addSubview:self.inputView];
    
    // 放大镜
    [self addSubview:self.placeHolderView];
    [_placeHolderView addSubview:self.placeHolderLab];
    [_placeHolderView addSubview:self.searchIV];
    
    // 输入框
    [self addSubview:self.textField];
    
    
    [self addSubview:self.cancelBtn];
}

#pragma mark - 通知
/**
 *  创建通知
 */
- (void)createNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditing)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

/**
 *  点击输入框时
 */
- (void)textFieldDidBeginEditing
{
    [self placeHolderMoveToLeftIsAnimation:YES];
}

/**
 *  输入框内容发生变化时
 */
- (void)textFieldDidChange
{
    if (_textField.text.length > 0) {
        _placeHolderLab.text = @"";
    }else{
        _placeHolderLab.text = _placeHolder;
    }
}

#pragma mark - 事件
- (void)cancelBtnAction:(UIButton *)sender
{
    _textField.text = @"";
    [_textField resignFirstResponder];
    if (_placeHolder.length > 0) {
        _placeHolderLab.text = _placeHolder;
        [self placeHolderMoveToRightIsAnimation:YES];
    }
}

#pragma mark - 界面
/**
 *  占位符向右移动
 *
 *  @param is 是否使用动画
 */
- (void)placeHolderMoveToRightIsAnimation:(BOOL)is
{
    if (is && _isChangeLocation) {
        [UIView animateWithDuration:0.5 animations:^{
            _placeHolderView.frame = CGRectMake(SELF_WIDTH / 4.0,0,SELF_WIDTH - SELF_WIDTH / 4.0 - 30,SELF_HEIGHT);
            _placeHolderLab.frame = CGRectMake(25, 0, _placeHolderView.bounds.size.width - 25, SELF_HEIGHT);
        } completion:nil];
    }else if(_isChangeLocation){
        _placeHolderView.frame = CGRectMake(SELF_WIDTH / 4.0,0,SELF_WIDTH - SELF_WIDTH / 4.0 - 30,SELF_HEIGHT);
        _placeHolderLab.frame = CGRectMake(25, 0, _placeHolderView.bounds.size.width - 25, SELF_HEIGHT);
    }
}

/**
 *  占位符向左移动
 *
 *  @param is 是否使用动画
 */
- (void)placeHolderMoveToLeftIsAnimation:(BOOL)is
{
    if (is) {
        [UIView animateWithDuration:0.5 animations:^{
            _placeHolderView.frame = CGRectMake(5, 0, SELF_WIDTH - 30, SELF_HEIGHT);
            _placeHolderLab.frame = CGRectMake(25, 0, _placeHolderView.bounds.size.width - 25, SELF_HEIGHT);
        } completion:nil];
    }else{
        _placeHolderView.frame = CGRectMake(5, 0, SELF_WIDTH - 30, SELF_HEIGHT);
        _placeHolderLab.frame = CGRectMake(25, 0, _placeHolderView.bounds.size.width - 25, SELF_HEIGHT);
    }
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(didSearchWithKeyword:)]) {
        [self.delegate didSearchWithKeyword:textField.text];
    }
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - setter
- (void)setPlaceHolder:(NSString *)placeHolder
{
    if (placeHolder) {
        _placeHolder = placeHolder;
        _placeHolderLab.text = placeHolder;
        
        // 如果有占位符就让视图右移
        if (_placeHolder.length > 0) {
            [self placeHolderMoveToRightIsAnimation:NO];
        }
    }
}

- (void)setSearchImage:(UIImage *)searchImage
{
    if (searchImage) {
        _searchIV.image = searchImage;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}

- (void)setFont:(UIFont *)font
{
    if (font) {
        _font = font;
        _textField.font = font;
        _placeHolderLab.font = font;
    }
}

- (void)setIsChangeLocation:(BOOL)isChangeLocation
{
    _isChangeLocation = isChangeLocation;
    // 如果有占位符就让视图右移
    if (_placeHolder.length > 0 && _isChangeLocation) {
        [self placeHolderMoveToRightIsAnimation:NO];
    }
    else if (!_isChangeLocation){
        [self placeHolderMoveToLeftIsAnimation:NO];
    }
}

#pragma mark - property
- (UIView *)placeHolderView
{
    if (!_placeHolderView) {
        _placeHolderView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, SELF_WIDTH - 30, SELF_HEIGHT)];
    }
    return _placeHolderView;
}

- (UILabel *)placeHolderLab
{
    if (!_placeHolderLab) {
        _placeHolderLab = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, _placeHolderView.bounds.size.width - 25, SELF_HEIGHT)];
        _placeHolderLab.font = [UIFont fontWithName:@"Arial" size:15.0f];
        _placeHolderLab.textColor = [UIColor grayColor];
    }
    return _placeHolderLab;
}

- (UIImageView *)searchIV
{
    if (!_searchIV) {
        _searchIV = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 15, 15)];
        _searchIV.center = CGPointMake(_searchIV.center.x, SELF_HEIGHT / 2.0);
        _searchIV.image = [UIImage imageNamed:@"search"];
    }
    return _searchIV;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(25, 0, SELF_WIDTH - 25 - 30, SELF_HEIGHT)];
        _textField.font = [UIFont fontWithName:@"Arial" size:15.0f];
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeyDone;
    }
    return _textField;
}



- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(SELF_WIDTH - 35, 0, 30, SELF_HEIGHT);
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
        [_cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

@end

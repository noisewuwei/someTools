//
//  YM_TableViewCell.m
//
//  Created by 黄玉洲 on 2019/5/8.
//  Copyright © 2019年 Louis. All rights reserved.
//

#import "YM_TableViewCell.h"

#pragma mark - YMSideslipCellAction
@interface YMSideslipCellAction ()

@property (nonatomic, copy) void (^handler)(YMSideslipCellAction *action, NSIndexPath *indexPath);

@property (nonatomic, assign) YMSideslipActionStyle style;

@end

@implementation YMSideslipCellAction

+ (instancetype)rowActionWithStyle:(YMSideslipActionStyle)style
                             title:(NSString *)title
                           handler:(void (^)(YMSideslipCellAction *action, NSIndexPath *indexPath))handler {
    YMSideslipCellAction *action = [YMSideslipCellAction new];
    action.title = title;
    action.handler = handler;
    action.style = style;
    action.backgroundColor = action.style == YMSideslipActionStyle_Normal ?
    [UIColor colorWithRed:200/255.0 green:199/255.0 blue:205/255.0 alpha:1] : [UIColor redColor];
    action.fontSize = 17;
    action.titleColor = [UIColor whiteColor];
    return action;
}

/** 按钮长度 */
- (CGFloat)margin {
    return _margin == 0 ? 15 : _margin;
}

@end

#pragma mark - YMTableViewCell
@interface YM_TableViewCell () <UIGestureRecognizerDelegate>
{
    /** 该cell所在的的TablevIEW */
    UITableView * _tableView;
    
    /** 保存侧滑按钮 */
    NSArray <YMSideslipCellAction *> * _actions;
    
    /** cell手势 */
    UIPanGestureRecognizer * _panGesture;
    
    /** tableView手势 */
    UIPanGestureRecognizer * _tableViewPan;
}

/** cell是否已展开 */
@property (nonatomic, assign) BOOL sideslip;

/** cell展开形态 */
@property (nonatomic, assign) YMSideslipState state;

@end

@implementation YM_TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self enterMethod];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self enterMethod];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat x = 0;
    if (_sideslip) x = self.contentView.frame.origin.x;
    
    [super layoutSubviews];
    
    CGFloat height = _sideslipBtnHeight <= 0 ? self.frame.size.height : _sideslipBtnHeight;
    CGFloat totalWidth = 0;
    for (UIButton *btn in _btnContainView.subviews) {
        btn.frame = CGRectMake(totalWidth, 0, btn.frame.size.width, height);
        totalWidth += btn.frame.size.width;
    }
 
    _btnContainView.frame = CGRectMake(self.frame.size.width - totalWidth, (self.frame.size.height - height) / 2.0, totalWidth, height);
    
    // 侧滑状态旋转屏幕时, 保持侧滑
    if (_sideslip) [self setContentViewX:x];
    
    CGRect frame = self.contentView.frame;
    frame.size.width = self.bounds.size.width;
    self.contentView.frame = frame;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (_sideslip) [self hiddenSideslip];
}

#pragma mark - 入口方法
/** 入口 */
- (void)enterMethod {
    _maxSlidesMargin = 30;
    [self tableView];
    [self addGesture];
}

#pragma mark - 界面
/** 布局 */
- (void)layoutView {

}

#pragma mark - 手势
/** 添加手势 */
- (void)addGesture {
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewPan:)];
    _panGesture.delegate = self;
    [self.contentView addGestureRecognizer:_panGesture];
    self.contentView.backgroundColor = [UIColor clearColor];
}

/** cell手势 */
- (void)contentViewPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:pan.view];
    UIGestureRecognizerState state = pan.state;
    [pan setTranslation:CGPointZero inView:pan.view];
    
    if (state == UIGestureRecognizerStateChanged) {
        CGRect frame = self.contentView.frame;
        frame.origin.x += point.x;
        // 向右滑时，距离侧滑按钮的最大距离
        if (frame.origin.x > 0) {
            frame.origin.x = 0;
            self.state = YMSideslipState_Hide;
        }
        // 向左滑时，距离侧滑按钮的最大距离
        else if (frame.origin.x < -_maxSlidesMargin - _btnContainView.frame.size.width) {
            frame.origin.x = -_maxSlidesMargin - _btnContainView.frame.size.width;
        } else {
            self.state = YMSideslipState_Showing;
        }
        self.contentView.frame = frame;
    } else if (state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [pan velocityInView:pan.view];
        if (self.contentView.frame.origin.x == 0) {
            return;
        } else if (self.contentView.frame.origin.x > 5) {
            [self hiddenWithBounceAnimation];
        } else if (fabs(self.contentView.frame.origin.x) >= 40 && velocity.x <= 0) {
            [self showSideslip];
        } else {
            [self hiddenSideslip];
        }
        
    } else if (state == UIGestureRecognizerStateCancelled) {
        [self.tableView hiddenAllSideslip];
    }
}

/** UITableView手势 */
- (void)tableViewPan:(UIPanGestureRecognizer *)pan {
    if (!self.tableView.scrollEnabled &&
        pan.state == UIGestureRecognizerStateBegan) {
        [self.tableView hiddenAllSideslip];
    }
}

#pragma mark - <UIGestureRecognizerDelegate>
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGesture) {
        // 若 tableView 不能滚动时, 还触发手势, 则隐藏侧滑
        if (!self.tableView.scrollEnabled) {
            [self.tableView hiddenAllSideslip];
            return NO;
        }
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [gesture translationInView:gesture.view];
        
        // 如果手势相对于水平方向的角度大于45°, 则不触发侧滑
        BOOL shouldBegin = fabs(translation.y) <= fabs(translation.x);
        if (!shouldBegin) return NO;
        
        // 询问代理是否需要侧滑
        if ([_delegate respondsToSelector:@selector(sideslipCell:canSideslipRowAtIndexPath:)]) {
            shouldBegin = [_delegate sideslipCell:self canSideslipRowAtIndexPath:self.indexPath] || _sideslip;
        }
        
        if (shouldBegin) {
            // 向代理获取侧滑展示内容数组
            if ([_delegate respondsToSelector:@selector(sideslipCell:editActionsForRowAtIndexPath:)]) {
                NSArray <YMSideslipCellAction*> * actions = [_delegate sideslipCell:self editActionsForRowAtIndexPath:self.indexPath];
                if (!actions || actions.count == 0) return NO;
                [self setActions:actions];
                self.state = YMSideslipState_Showing;
            } else {
                return NO;
            }
        }
        return shouldBegin;
    } else if (gestureRecognizer == _tableViewPan) {
        if (self.tableView.scrollEnabled) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 侧滑操作
/** 侧滑回弹效果 */
- (void)hiddenWithBounceAnimation {
    self.state = YMSideslipState_Showing;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:-10];
    } completion:^(BOOL finished) {
        [self hiddenSideslip];
    }];
}

/** 隐藏侧滑 */
- (void)hiddenSideslip {
    if (self.contentView.frame.origin.x == 0) return;
    self.state = YMSideslipState_Showing;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:0];
    } completion:^(BOOL finished) {
        [_btnContainView removeFromSuperview];
        _btnContainView = nil;
        self.state = YMSideslipState_Hide;
    }];
}

/** 显示侧滑 */
- (void)showSideslip {
    self.state = YMSideslipState_Showing;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self setContentViewX:-_btnContainView.frame.size.width];
    } completion:^(BOOL finished) {
        self.state = YMSideslipState_Show;
    }];
}

#pragma mark - 按钮事件
- (void)actionBtnDidClicked:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(sideslipCell:rowAtIndexPath:didSelectedAtIndex:)]) {
        [self.delegate sideslipCell:self rowAtIndexPath:self.indexPath didSelectedAtIndex:btn.tag];
    }
    if (btn.tag < _actions.count) {
        YMSideslipCellAction *action = _actions[btn.tag];
        if (action.handler) action.handler(action, self.indexPath);
    }
    self.state = YMSideslipState_Show;
}

#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (_sideslip) [self.tableView hiddenAllSideslip];
}

#pragma mark - setter
/** 设置self.contentView的横坐标位置 */
- (void)setContentViewX:(CGFloat)x {
    CGRect frame = self.contentView.frame;
    frame.origin.x = x;
    self.contentView.frame = frame;
}

- (void)setActions:(NSArray <YMSideslipCellAction *> *)actions {
    _actions = actions;
    
    if (_btnContainView) {
        [_btnContainView removeFromSuperview];
        _btnContainView = nil;
    }
    _btnContainView = [UIView new];
    [self insertSubview:_btnContainView belowSubview:self.contentView];
    
    for (int i = 0; i < actions.count; i++) {
        YMSideslipCellAction *action = actions[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.adjustsImageWhenHighlighted = NO;
        [btn setTitle:action.title forState:UIControlStateNormal];
        btn.backgroundColor = action.backgroundColor;
        btn.titleLabel.font = [UIFont systemFontOfSize:action.fontSize];
        [btn setTitleColor:action.titleColor forState:UIControlStateNormal];
        if (action.image) {
            [btn setImage:action.image forState:UIControlStateNormal];
        }
        
        CGFloat width = [action.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : btn.titleLabel.font} context:nil].size.width;
        width += (action.image ? action.image.size.width : 0);
        btn.frame = CGRectMake(0, 0, width + action.margin*2, 0);
        
        btn.tag = i;
        [btn addTarget:self action:@selector(actionBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_btnContainView addSubview:btn];
    }
}

/** 设置cell状态 */
- (void)setState:(YMSideslipState)state {
    _state = state;
    [self stateDidChange:state];
    // 侧滑未展示
    if (state == YMSideslipState_Hide) {
        self.tableView.scrollEnabled = YES;
        self.tableView.allowsSelection = YES;
        for (YM_TableViewCell * cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:YM_TableViewCell.class]) {
                cell.sideslip = NO;
            }
        }
        
    }
    // 侧滑正在展示过程
    else if (state == YMSideslipState_Showing) {
        
    }
    // 侧滑已展示
    else if (state == YMSideslipState_Show) {
        self.tableView.scrollEnabled = NO;
        self.tableView.allowsSelection = NO;
        for (YM_TableViewCell * cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:YM_TableViewCell.class]) {
                cell.sideslip = YES;
            }
        }
    }
}

#pragma mark - 用于重写
- (void)stateDidChange:(YMSideslipState)state {}

#pragma mark - getter
- (NSIndexPath *)indexPath {
    return [self.tableView indexPathForCell:self];
}

- (UITableView *)tableView {
    if (!_tableView) {
        id view = self.superview;
        while (view && [view isKindOfClass:[UITableView class]] == NO) {
            view = [view superview];
        }
        _tableView = (UITableView *)view;
        _tableViewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewPan:)];
        _tableViewPan.delegate = self;
        [_tableView addGestureRecognizer:_tableViewPan];
    }
    return _tableView;
}

@end

#pragma mark - UITableView (YMCategorySideslip)
@implementation UITableView (YMCategorySideslip)

/** 收起所有侧滑cell */
- (void)hiddenAllSideslip {
    for (YM_TableViewCell * cell in self.visibleCells) {
        if ([cell isKindOfClass:YM_TableViewCell.class]) {
            [cell hiddenSideslip];
        }
    }
}

@end

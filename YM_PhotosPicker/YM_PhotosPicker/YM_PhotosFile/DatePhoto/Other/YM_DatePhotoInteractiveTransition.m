//
//  YM_DatePhotoInteractiveTransition.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoInteractiveTransition.h"
#import <UIKit/UIKit.h>

/** viewController */
#import "YM_DatePhotoPreviewViewController.h"
#import "YM_DatePhotoViewController.h"
#import "YM_DatePhotoPreviewBottomView.h"

/** model */
#import "YM_PhotoModel.h"

/** view */
#import "YM_DatePhotoPreviewViewCell.h"
#import "YM_DatePhotoViewCell.h"


@interface YM_DatePhotoInteractiveTransition ()
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UIViewController *vc;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *bgView;
@property (weak, nonatomic) YM_DatePhotoViewCell *tempCell;
@property (weak, nonatomic) YM_DatePhotoPreviewViewCell *fromCell;
@property (strong, nonatomic) UIImageView *tempImageView;
@property (nonatomic, assign) CGPoint transitionImgViewCenter;
@property (nonatomic, assign) CGFloat beginX;
@property (nonatomic, assign) CGFloat beginY;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@end

@implementation YM_DatePhotoInteractiveTransition

- (void)addPanGestureForViewController:(UIViewController *)viewController{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizeDidUpdate:)];
    self.vc = viewController;
    [viewController.view addGestureRecognizer:pan];
}
- (void)gestureRecognizeDidUpdate:(UIPanGestureRecognizer *)gestureRecognizer {
    CGFloat scale = 0;
    
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGFloat transitionY = translation.y;
    scale = transitionY / ((gestureRecognizer.view.frame.size.height - 50) / 2);
    if (scale > 1.f) {
        scale = 1.f;
    }
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (scale < 0) {
                [gestureRecognizer cancelsTouchesInView];
                return;
            }
            if (![(YM_DatePhotoPreviewViewController *)self.vc bottomView].userInteractionEnabled && iOS11_Later) {
                [(YM_DatePhotoPreviewViewController *)self.vc setSubviewAlphaAnimate:NO duration:0.3f];
            }
            [(YM_DatePhotoPreviewViewController *)self.vc setStopCancel:YES];
            self.beginX = [gestureRecognizer locationInView:gestureRecognizer.view].x;
            self.beginY = [gestureRecognizer locationInView:gestureRecognizer.view].y;
            self.interation = YES;
            [self.vc.navigationController popViewControllerAnimated:YES];
            break;
        case UIGestureRecognizerStateChanged:
            if (self.interation) {
                if (scale < 0.f) {
                    scale = 0.f;
                }
                CGFloat imageViewScale = 1 - scale * 0.5;
                if (imageViewScale < 0.4) {
                    imageViewScale = 0.4;
                }
                self.tempImageView.center = CGPointMake(self.transitionImgViewCenter.x + translation.x, self.transitionImgViewCenter.y + translation.y);
                self.tempImageView.transform = CGAffineTransformMakeScale(imageViewScale, imageViewScale);
                
                [self updateInterPercent:1 - scale * scale];
                
                [self updateInteractiveTransition:scale];
            }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.interation) {
                if (scale < 0.f) {
                    scale = 0.f;
                }
                self.interation = NO;
                if (scale < 0.15f){
                    [self cancelInteractiveTransition];
                    [self interPercentCancel];
                }else {
                    [self finishInteractiveTransition];
                    [self interPercentFinish];
                }
            }
            break;
        default:
            if (self.interation) {
                self.interation = NO;
                [self cancelInteractiveTransition];
                [self interPercentCancel];
            }
            break;
    }
}
- (void)beginInterPercent{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    YM_DatePhotoPreviewViewController *fromVC = (YM_DatePhotoPreviewViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    YM_DatePhotoViewController *toVC = (YM_DatePhotoViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    YM_PhotoModel *model = [fromVC.modelArray objectAtIndex:fromVC.currentModelIndex];
    
    YM_DatePhotoPreviewViewCell *fromCell = [fromVC currentPreviewCell:model];
    YM_DatePhotoViewCell *toCell = [toVC currentPreviewCell:model];
    self.fromCell = fromCell;
    
    UIView *containerView = [transitionContext containerView];
    CGRect tempImageViewFrame;
    if (model.subType == YM_PhotoModelMediaSubType_Photo) {
        self.tempImageView = fromCell.imageView;
        tempImageViewFrame = [fromCell.imageView convertRect:fromCell.imageView.bounds toView:containerView];
    }else {
        if (!fromCell.playerLayer.player) {
            self.tempImageView = fromCell.imageView;
            tempImageViewFrame = [fromCell.imageView convertRect:fromCell.imageView.bounds toView:containerView];
        }else {
            tempImageViewFrame = containerView.bounds;
            [fromCell.playerLayer removeFromSuperlayer];
            self.playerLayer = fromCell.playerLayer;
            self.tempImageView = [[UIImageView alloc] init];
            self.tempImageView.layer.masksToBounds = YES;
            [self.tempImageView.layer addSublayer:self.playerLayer];
            if (kDevice_Is_iPhoneX) {
                tempImageViewFrame = CGRectMake(tempImageViewFrame.origin.x, tempImageViewFrame.origin.y + kTopMargin, tempImageViewFrame.size.width, tempImageViewFrame.size.height);
            }
        }
    }
    self.tempImageView.clipsToBounds = YES;
    self.tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    BOOL contains = YES;
    if (!toCell) {
        contains = [toVC scrollToModel:model];
        toCell = [toVC currentPreviewCell:model];
    }
    self.bgView = [[UIView alloc] initWithFrame:containerView.bounds];
    self.bgView.backgroundColor = [UIColor whiteColor];
    CGFloat scaleX;
    CGFloat scaleY;
    if (self.beginX < tempImageViewFrame.origin.x) {
        scaleX = 0;
    }else if (self.beginX > CGRectGetMaxX(tempImageViewFrame)) {
        scaleX = 1.0f;
    }else {
        scaleX = (self.beginX - tempImageViewFrame.origin.x) / tempImageViewFrame.size.width;
    }
    if (self.beginY < tempImageViewFrame.origin.y) {
        scaleY = 0;
    }else if (self.beginY > CGRectGetMaxY(tempImageViewFrame)){
        scaleY = 1.0f;
    }else {
        scaleY = (self.beginY - tempImageViewFrame.origin.y) / tempImageViewFrame.size.height;
    }
    self.tempImageView.layer.anchorPoint = CGPointMake(scaleX, scaleY);
    
    self.tempImageView.frame = tempImageViewFrame;
    self.transitionImgViewCenter = self.tempImageView.center;
    [containerView addSubview:toVC.view];
    [containerView addSubview:fromVC.view];
    [toVC.view insertSubview:self.bgView belowSubview:toVC.bottomView];
    [toVC.view insertSubview:self.tempImageView belowSubview:toVC.bottomView];
    if (!fromVC.bottomView.userInteractionEnabled) {
        self.bgView.backgroundColor = [UIColor blackColor];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [toVC.navigationController setNavigationBarHidden:NO];
        toVC.navigationController.navigationBar.alpha = 0;
        toVC.bottomView.alpha = 0;
    }else {
        self.bgView.backgroundColor = [UIColor whiteColor];
    }
    toVC.navigationController.navigationBar.userInteractionEnabled = NO;
    fromVC.collectionView.hidden = YES;
    toCell.hidden = YES;
    fromVC.view.backgroundColor = [UIColor clearColor];
    
    CGRect rect = [toCell.imageView convertRect:toCell.imageView.bounds toView: containerView];
    if (toCell) {
        [toVC scrollToPoint:toCell rect:rect];
    }
    self.tempCell = toCell;
}
- (void)updateInterPercent:(CGFloat)scale{
    YM_DatePhotoPreviewViewController *fromVC = (YM_DatePhotoPreviewViewController *)[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.alpha = scale;
    self.bgView.alpha = fromVC.view.alpha;
    
    if (!fromVC.bottomView.userInteractionEnabled) {
        YM_DatePhotoViewController *toVC = (YM_DatePhotoViewController *)[self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        toVC.bottomView.alpha = 1 - scale;
        toVC.navigationController.navigationBar.alpha = 1 - scale;
    }
}
- (void)interPercentCancel{
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    YM_DatePhotoPreviewViewController *fromVC = (YM_DatePhotoPreviewViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    YM_DatePhotoViewController *toVC = (YM_DatePhotoViewController *)[self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (!fromVC.bottomView.userInteractionEnabled) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [toVC.navigationController setNavigationBarHidden:YES];
        toVC.navigationController.navigationBar.alpha = 1;
    }
    [UIView animateWithDuration:0.2f animations:^{
        fromVC.view.alpha = 1;
        self.tempImageView.transform = CGAffineTransformIdentity;
        self.tempImageView.center = self.transitionImgViewCenter;
        self.bgView.alpha = 1;
        if (!fromVC.bottomView.userInteractionEnabled) {
            toVC.bottomView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        toVC.navigationController.navigationBar.userInteractionEnabled = YES;
        fromVC.collectionView.hidden = NO;
        if (!fromVC.bottomView.userInteractionEnabled) {
            fromVC.view.backgroundColor = [UIColor blackColor];
        }else {
            fromVC.view.backgroundColor = [UIColor whiteColor];
        }
        self.tempCell.hidden = NO;
        self.tempCell = nil;
        [self.tempImageView removeFromSuperview];
        self.tempImageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        [self.fromCell againAddImageView];
        self.playerLayer = nil;
        [self.bgView removeFromSuperview];
        self.bgView = nil;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
//完成
- (void)interPercentFinish {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIView *containerView = [transitionContext containerView];
    YM_DatePhotoPreviewViewController *fromVC = (YM_DatePhotoPreviewViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    YM_DatePhotoViewController *toVC = (YM_DatePhotoViewController *)[self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSTimeInterval duration = fromVC.manager.configuration.popInteractiveTransitionDuration;
    UIViewAnimationOptions option = fromVC.manager.configuration.transitionAnimationOption;
    
    CGRect tempImageViewFrame = self.tempImageView.frame;
    self.tempImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    self.tempImageView.transform = CGAffineTransformIdentity;
    self.tempImageView.frame = tempImageViewFrame;
    self.playerLayer.frame = CGRectMake(0, 0, self.tempCell.imageView.hx_w, self.tempCell.imageView.hx_h);
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:option animations:^{
        if (self.tempCell) {
            self.tempImageView.frame = [self.tempCell.imageView convertRect:self.tempCell.imageView.bounds toView: containerView];
        }else {
            self.tempImageView.center = self.transitionImgViewCenter;
            self.tempImageView.alpha = 0;
            self.tempImageView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        }
        fromVC.view.alpha = 0;
        self.bgView.alpha = 0;
        toVC.navigationController.navigationBar.alpha = 1;
        toVC.bottomView.alpha = 1;
    }completion:^(BOOL finished) {
        toVC.navigationController.navigationBar.userInteractionEnabled = YES;
        [self.tempCell bottomViewPrepareAnimation];
        self.tempCell.hidden = NO;
        [self.tempCell bottomViewStartAnimation];
        self.playerLayer = nil;
        [self.tempImageView removeFromSuperview];
        [self.bgView removeFromSuperview];
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    [self beginInterPercent];
}


@end

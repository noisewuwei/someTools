//
//  YM_DatePhotoViewPresentTransition.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/7.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_DatePhotoViewPresentTransition.h"
#import "YM_PhotoView.h"
#import "YM_PhotoSubViewCell.h"
#import "YM_PhotoView.h"
#import "YM_DatePhotoPreviewViewController.h"
#import "YM_DatePhotoPreviewBottomView.h"
#import "YM_DatePhotoPreviewViewCell.h"

@interface YM_DatePhotoViewPresentTransition ()
@property (strong, nonatomic) YM_PhotoView *photoView ;
@property (assign, nonatomic) YM_DatePhotoViewPresentTransitionType type;
@end

@implementation YM_DatePhotoViewPresentTransition

+ (instancetype)transitionWithTransitionType:(YM_DatePhotoViewPresentTransitionType)type photoView:(YM_PhotoView *)photoView {
    return [[self alloc] initWithTransitionType:type photoView:photoView];
}

- (instancetype)initWithTransitionType:(YM_DatePhotoViewPresentTransitionType)type photoView:(YM_PhotoView *)photoView {
    self = [super init];
    if (self) {
        self.type = type;
        self.photoView = photoView;
    }
    return self;
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    if (self.type == YM_DatePhotoViewPresentTransitionType_Present) {
        return 0.45f;
    }else {
        return 0.25f;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    switch (self.type) {
        case YM_DatePhotoViewPresentTransitionType_Present:
            [self presentAnimation:transitionContext];
            break;
            
        case YM_DatePhotoViewPresentTransitionType_Dismiss:
            [self dismissAnimation:transitionContext];
            break;
    }
}
- (void)presentAnim:(id<UIViewControllerContextTransitioning>)transitionContext Image:(UIImage *)image Model:(YM_PhotoModel *)model FromVC:(UIViewController *)fromVC ToVC:(YM_DatePhotoPreviewViewController *)toVC cell:(YM_PhotoSubViewCell *)cell{
    model.tempImage = image;
    UIView *containerView = [transitionContext containerView];
    UIImageView *tempView = [[UIImageView alloc] initWithImage:image];
    UIView *tempBgView = [[UIView alloc] initWithFrame:containerView.bounds];
    tempView.clipsToBounds = YES;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    tempView.frame = [cell.imageView convertRect:cell.imageView.bounds toView:containerView];
    if (!image) {
        tempView.image = cell.imageView.image;
    }
    [tempBgView addSubview:tempView];
    [containerView addSubview:toVC.view];
    [toVC.view insertSubview:tempBgView atIndex:0];
    toVC.collectionView.hidden = YES;
    model.endDateImageSize = CGSizeZero;
    CGFloat imgWidht = model.endDateImageSize.width;
    CGFloat imgHeight = model.endDateImageSize.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - kTopMargin - kBottomMargin;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        if (kDevice_Is_iPhoneX) {
            height = [UIScreen mainScreen].bounds.size.height - kTopMargin - 21;
        }
    }
    toVC.navigationController.navigationBar.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.75f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        tempView.frame = CGRectMake((width - imgWidht) / 2, (height - imgHeight) / 2 + kTopMargin, imgWidht, imgHeight);
    } completion:^(BOOL finished) {
        toVC.collectionView.hidden = NO;
        [tempBgView removeFromSuperview];
        [tempView removeFromSuperview];
        toVC.navigationController.navigationBar.userInteractionEnabled = YES;
        [transitionContext completeTransition:YES];
    }];
}
/**
 *  实现present动画
 */
- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    YM_DatePhotoPreviewViewController *toVC = (YM_DatePhotoPreviewViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UICollectionView *collectionView = (UICollectionView *)self.photoView.collectionView;
    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)fromVC;
        fromVC = nav.viewControllers.lastObject;
    }else if ([fromVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)fromVC;
        if ([tabBar.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tabBar.selectedViewController;
            fromVC = nav.viewControllers.lastObject;
        }else {
            fromVC = tabBar.selectedViewController;
        }
    }
    YM_PhotoSubViewCell *cell = (YM_PhotoSubViewCell *)[collectionView cellForItemAtIndexPath:self.photoView.currentIndexPath];
    YM_PhotoModel *model = cell.model;
    if (model.asset) {
        kWeakSelf
        [YM_PhotoTools getHighQualityFormatPhotoForPHAsset:model.asset size:CGSizeMake(model.endImageSize.width * 0.8, model.endImageSize.height * 0.8) completion:^(UIImage *image, NSDictionary *info) {
            kStrongSelf
            [self presentAnim:transitionContext Image:image Model:model FromVC:fromVC ToVC:toVC cell:cell];
        } error:^(NSDictionary *info) {
            kStrongSelf
            [self presentAnim:transitionContext Image:model.thumbPhoto Model:model FromVC:fromVC ToVC:toVC cell:cell];
        }];
    }else {
        [self presentAnim:transitionContext Image:model.thumbPhoto Model:model FromVC:fromVC ToVC:toVC cell:cell];
    }
}

/**
 *  实现dimiss动画
 */
- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    YM_DatePhotoPreviewViewController *fromVC = (YM_DatePhotoPreviewViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    YM_PhotoModel *model = nil;
    if ([fromVC.modelArray count] > fromVC.currentModelIndex) {
        model = [fromVC.modelArray objectAtIndex:fromVC.currentModelIndex];
    }
    YM_DatePhotoPreviewViewCell *fromCell = [fromVC currentPreviewCell:model];
    UIImageView *tempView;
    if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
        tempView = [[UIImageView alloc] initWithImage:model.thumbPhoto];
    }else {
        tempView = [[UIImageView alloc] initWithImage:fromCell.imageView.image];
    }
    UICollectionView *collectionView = (UICollectionView *)self.photoView.collectionView;
    
    if ([toVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)toVC;
        toVC = nav.viewControllers.lastObject;
    }else if ([toVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)toVC;
        if ([tabBar.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tabBar.selectedViewController;
            toVC = nav.viewControllers.lastObject;
        }else {
            toVC = tabBar.selectedViewController;
        }
    }
    
    YM_PhotoSubViewCell *cell = (YM_PhotoSubViewCell *)[collectionView cellForItemAtIndexPath:[self.photoView currentModelIndexPath:model]];
    if (!tempView.image) {
        tempView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    }
    tempView.clipsToBounds = YES;
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    UIView *containerView = [transitionContext containerView];
    tempView.frame = [fromCell.imageView convertRect:fromCell.imageView.bounds toView:containerView];
    [containerView addSubview:tempView];
    if (model.type == YM_PhotoModelMediaType_CameraPhoto) {
        CGPoint center = tempView.center;
        tempView.hx_size = model.endImageSize;
        tempView.center = center;
    }
    
    CGRect rect = [cell convertRect:cell.bounds toView:containerView];
    cell.hidden = YES;
    fromVC.view.hidden = YES;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        if (cell) {
            tempView.frame = rect;
        }else {
            tempView.alpha = 0;
            tempView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        }
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [tempView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}


@end

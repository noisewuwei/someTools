//
//  YM_Demo2ViewController.m
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/3.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import "YM_Demo2ViewController.h"
#import "YM_PhotoPicker.h"

static const CGFloat kPhotoViewMargin = 18.0;

@interface YM_Demo2ViewController ()<YM_PhotoViewDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) YM_PhotoManager *manager;
@property (strong, nonatomic) YM_PhotoView *photoView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) YM_DatePhotoToolManager *toolManager;

@property (strong, nonatomic) UIButton *bottomView;

@property (assign, nonatomic) BOOL needDeleteItem;

@property (assign, nonatomic) BOOL showHud;

@end

@implementation YM_Demo2ViewController

- (UIButton *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomView setTitle:@"删除" forState:UIControlStateNormal];
        [_bottomView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bottomView setBackgroundColor:[UIColor redColor]];
        _bottomView.frame = CGRectMake(0, self.view.hx_h - 50, self.view.hx_w, 50);
        _bottomView.alpha = 0;
    }
    return _bottomView;
}
- (YM_DatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[YM_DatePhotoToolManager alloc] init];
    }
    return _toolManager;
}

- (YM_PhotoManager *)manager {
    if (!_manager) {
        _manager = [[YM_PhotoManager alloc] initWithType:YM_PhotoManagerType_All];
        _manager.configuration.openCamera = YES;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.photoMaxNum = 9;
        _manager.configuration.videoMaxNum = 1;
        _manager.configuration.maxNum = 9;
        _manager.configuration.videoMaxDuration = 500.f;
        _manager.configuration.saveSystemAblum = YES;
        //        _manager.configuration.reverseDate = YES;
        _manager.configuration.showDateSectionHeader = NO;
        _manager.configuration.selectTogether = NO;
        _manager.configuration.cellSelectedBgColor = [UIColor purpleColor];
        _manager.configuration.cellSelectedTitleColor = [UIColor blackColor];
        _manager.configuration.selectedTitleColor = [UIColor yellowColor];
//        _manager.configuration.singleSelected = YES;
        //        _manager.configuration.rowCount = 3;
        //        _manager.configuration.movableCropBox = YES;
        //        _manager.configuration.movableCropBoxEditSize = YES;
        //        _manager.configuration.movableCropBoxCustomRatio = CGPointMake(1, 1);
        _manager.configuration.requestImageAfterFinishingSelection = YES;
        kWeakSelf
        //        _manager.configuration.replaceCameraViewController = YES;
        _manager.configuration.shouldUseCamera = ^(UIViewController *viewController, YM_PhotoConfigurationCameraType cameraType, YM_PhotoManager *manager) {
            
            // 这里拿使用系统相机做例子
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = (id)weakSelf;
            imagePickerController.allowsEditing = NO;
            NSString *requiredMediaTypeImage = ( NSString *)kUTTypeImage;
            NSString *requiredMediaTypeMovie = ( NSString *)kUTTypeMovie;
            NSArray *arrMediaTypes;
            if (cameraType == YM_PhotoConfigurationCameraType_Photo) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage,nil];
            }else if (cameraType == YM_PhotoConfigurationCameraType_Video) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeMovie,nil];
            }else {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage, requiredMediaTypeMovie,nil];
            }
            [imagePickerController setMediaTypes:arrMediaTypes];
            // 设置录制视频的质量
            [imagePickerController setVideoQuality:UIImagePickerControllerQualityTypeHigh];
            //设置最长摄像时间
            [imagePickerController setVideoMaximumDuration:60.f];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        };
    }
    return _manager;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    YM_PhotoModel *model;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        model = [YM_PhotoModel photoModelWithImage:image];
        if (self.manager.configuration.saveSystemAblum) {
            [YM_PhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:model.thumbPhoto];
        }
    }else  if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
        float second = 0;
        second = urlAsset.duration.value/urlAsset.duration.timescale;
        model = [YM_PhotoModel photoModelWithVideoURL:url videoTime:second];
        if (self.manager.configuration.saveSystemAblum) {
            [YM_PhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:url];
        }
    }
    if (self.manager.configuration.useCameraComplete) {
        self.manager.configuration.useCameraComplete(model);
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    
    
    CGFloat width = scrollView.frame.size.width;
    YM_PhotoView *photoView = [YM_PhotoView photoManager:self.manager];
    photoView.frame = CGRectMake(kPhotoViewMargin, kPhotoViewMargin, width - kPhotoViewMargin * 2, 0);
    photoView.delegate = self;
    //    photoView.outerCamera = YES;
    photoView.previewShowDeleteButton = YES;
    //    photoView.hideDeleteButton = YES;
    photoView.showAddCell = YES;
    [photoView.collectionView reloadData];
    photoView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:photoView];
    self.photoView = photoView;
    
    //    [self.view showLoadingHUDText:nil];
    //    HXWeakSelf
    //    [YM_PhotoTools getSelectedModelArrayWithManager:self.manager complete:^(NSArray<YM_PhotoModel *> *modelArray) {
    //        [self.manager addModelArray:modelArray];
    //        [self.photoView refreshView];
    //        [self.view handleLoading];
    //    }];
    
    //    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"草稿" style:UIBarButtonItemStylePlain target:self action:@selector(savaClick)];
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithTitle:@"相册/相机" style:UIBarButtonItemStylePlain target:self action:@selector(didNavBtnClick)];
    
    self.navigationItem.rightBarButtonItems = @[cameraItem];
    
    [self.view addSubview:self.bottomView];
}
- (void)dealloc {
    NSSLog(@"dealloc");
}
- (void)savaClick {
    //    [self.view showLoadingHUDText:@"保存中"];
    //    HXWeakSelf
    //    [YM_PhotoTools saveSelectModelArrayWithManager:self.manager success:^{
    //        [self.view handleLoading];
    //    } failed:^{
    //        [self.view showImageHUDText:@"保存草稿失败啦!"];
    //    }];
    
    
    //    NSMutableArray *gifModel = [NSMutableArray array];
    //    for (YM_PhotoModel *model in self.manager.afterSelectedArray) {
    //        if (model.type == YM_PhotoModelMediaTypePhotoGif && !model.gifImageData) {
    //            [gifModel addObject:model];
    //        }
    //    }
    //    if (gifModel.count) {
    //        HXWeakSelf
    //        [self.toolManager gifModelAssignmentData:gifModel success:^{
    //            BOOL success = [YM_PhotoTools saveSelectModelArray:self.manager.afterSelectedArray fileName:@"ModelArray"];
    //            if (!success) {
    //                [self.view showImageHUDText:@"保存草稿失败啦!"];
    //            }else {
    //                [self.view handleLoading];
    //            }
    //        } failed:^{
    //            [self.view showImageHUDText:@"保存草稿失败啦!"];
    //        }];
    //    }else {
    //        BOOL success = [YM_PhotoTools saveSelectModelArray:self.manager.afterSelectedArray fileName:@"ModelArray"];
    //        if (!success) {
    //            [self.view showImageHUDText:@"保存草稿失败啦!"];
    //        }else {
    //            [self.view handleLoading];
    //        }
    //    }
}
- (void)didNavBtnClick {
    //    [YM_PhotoTools deleteLocalSelectModelArrayWithManager:self.manager];
    
    if (self.manager.configuration.specialModeNeedHideVideoSelectBtn && !self.manager.configuration.selectTogether && self.manager.configuration.videoMaxNum == 1) {
        if (self.manager.afterSelectedVideoArray.count) {
            [self.view showImageHUDText:@"请先删除视频"];
            return;
        }
    }
    [self.photoView goPhotoViewController];
}

- (void)photoView:(YM_PhotoView *)photoView changeComplete:(NSArray<YM_PhotoModel *> *)allList photos:(NSArray<YM_PhotoModel *> *)photos videos:(NSArray<YM_PhotoModel *> *)videos original:(BOOL)isOriginal {
    //    NSSLog(@"所有:%ld - 照片:%ld - 视频:%ld",allList.count,photos.count,videos.count);
    //    NSSLog(@"所有:%@ - 照片:%@ - 视频:%@",allList,photos,videos);
    //    HXWeakSelf
    //    [self.toolManager getSelectedImageDataList:allList success:^(NSArray<NSData *> *imageDataList) {
    //        NSSLog(@"%ld",imageDataList.count);
    //    } failed:^{
    //
    //    }];
    //    if (!self.showHud) {
    //        self.showHud = YES;
    //        [self.toolManager writeSelectModelListToTempPathWithList:allList success:^(NSArray<NSURL *> *allURL, NSArray<NSURL *> *photoURL, NSArray<NSURL *> *videoURL) {
    //            NSSLog(@"allUrl - %@\nimageUrls - %@\nvideoUrls - %@",allURL,photoURL,videoURL);
    //            NSMutableArray *array = [NSMutableArray array];
    //            for (NSURL *url in allURL) {
    //                [array addObject:url.absoluteString];
    //            }
    //            [[[UIAlertView alloc] initWithTitle:nil message:[array componentsJoinedByString:@"\n\n"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
    ////            [self.view showImageHUDText:[array componentsJoinedByString:@"\n"]];
    //        } failed:^{
    //
    //        }];
    //    }
    
    // 获取图片
    //    [self.toolManager getSelectedImageList:allList requestType:HXDatePhotoToolManagerRequestTypeOriginal success:^(NSArray<UIImage *> *imageList) {
    //
    //    } failed:^{
    //
    //    }];
    
    //    [YM_PhotoTools selectListWriteToTempPath:allList requestList:^(NSArray *imageRequestIds, NSArray *videoSessions) {
    //        NSSLog(@"requestIds - image : %@ \nsessions - video : %@",imageRequestIds,videoSessions);
    //    } completion:^(NSArray<NSURL *> *allUrl, NSArray<NSURL *> *imageUrls, NSArray<NSURL *> *videoUrls) {
    //        NSSLog(@"allUrl - %@\nimageUrls - %@\nvideoUrls - %@",allUrl,imageUrls,videoUrls);
    //    } error:^{
    //        NSSLog(@"失败");
    //    }];
    NSLog(@"%s", __func__);
}

- (void)photoView:(YM_PhotoView*)photoView imageChangeComplete:(NSArray<UIImage *> *)imageList {
    NSLog(@"%s", __func__);
    NSSLog(@"%@",imageList);
}

- (void)photoView:(YM_PhotoView*)photoView deleteNetworkPhoto:(NSString *)networkPhotoUrl {
    NSLog(@"%s", __func__);
    NSSLog(@"%@",networkPhotoUrl);
}

- (void)photoView:(YM_PhotoView*)photoView updateFrame:(CGRect)frame {
    NSLog(@"%s", __func__);
    NSSLog(@"%@",NSStringFromCGRect(frame));
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame) + kPhotoViewMargin);
    
}

- (void)photoView:(YM_PhotoView*)photoView currentDeleteModel:(YM_PhotoModel *)model currentIndex:(NSInteger)index {
    NSLog(@"%s", __func__);
    NSSLog(@"%@ --> index - %ld",model,index);
}

- (BOOL)photoViewShouldDeleteCurrentMoveItem:(YM_PhotoView*)photoView {
    NSLog(@"%s", __func__);
    return self.needDeleteItem;
}
- (void)photoView:(YM_PhotoView*)photoView gestureRecognizerBegan:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __func__);
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = 0.5;
    }];
    NSSLog(@"长按手势开始了 - %ld",indexPath.item);
}
- (void)photoView:(YM_PhotoView*)photoView gestureRecognizerChange:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __func__);
    CGPoint point = [longPgr locationInView:self.view];
    if (point.y >= self.bottomView.hx_y) {
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomView.alpha = 1;
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            self.bottomView.alpha = 0.5;
        }];
    }
    NSSLog(@"长按手势改变了 %@ - %ld",NSStringFromCGPoint(point), indexPath.item);
}
- (void)photoView:(YM_PhotoView*)photoView gestureRecognizerEnded:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __func__);
    CGPoint point = [longPgr locationInView:self.view];
    if (point.y >= self.bottomView.hx_y) {
        self.needDeleteItem = YES;
        [self.photoView deleteModelWithIndex:indexPath.item];
    }else {
        self.needDeleteItem = NO;
    }
    NSSLog(@"长按手势结束了 - %ld",indexPath.item);
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.alpha = 0;
    }];
}


@end

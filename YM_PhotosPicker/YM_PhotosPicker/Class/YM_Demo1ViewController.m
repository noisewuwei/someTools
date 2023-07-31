//
//  YM_Demo1ViewController.m
//  照片选择器
//
//  Created by 洪欣 on 17/2/17.
//  Copyright © 2017年 洪欣. All rights reserved.
//

#import "YM_Demo1ViewController.h"
#import "YM_PhotoPicker.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "YM_DatePhotoBottomView.h"
@interface YM_Demo1ViewController ()<YM_AlbumListViewControllerDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *total;
//@property (weak, nonatomic) IBOutlet UILabel *photo;
//@property (weak, nonatomic) IBOutlet UILabel *video;
@property (weak, nonatomic) IBOutlet UILabel *original;
@property (weak, nonatomic) IBOutlet UISwitch *camera;
@property (strong, nonatomic) YM_PhotoManager *manager;
@property (weak, nonatomic) IBOutlet UITextField *photoText;
@property (weak, nonatomic) IBOutlet UITextField *videoText;
@property (weak, nonatomic) IBOutlet UITextField *columnText;
@property (weak, nonatomic) IBOutlet UISwitch *addCamera; 
@property (weak, nonatomic) IBOutlet UISwitch *showHeaderSection;
@property (weak, nonatomic) IBOutlet UISwitch *reverse;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectedTypeView;
@property (weak, nonatomic) IBOutlet UISwitch *saveAblum;
@property (weak, nonatomic) IBOutlet UISwitch *icloudSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *downloadICloudAsset;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tintColor;
@property (weak, nonatomic) IBOutlet UISwitch *hideOriginal;
@property (weak, nonatomic) IBOutlet UISwitch *synchTitleColor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *navBgColor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *navTitleColor;
@property (weak, nonatomic) IBOutlet UISwitch *useCustomCamera;
@property (strong, nonatomic) UIColor *bottomViewBgColor; 
@property (weak, nonatomic) IBOutlet UITextField *clarityText;
@property (weak, nonatomic) IBOutlet UISwitch *photoCanEditSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *videoCanEditSwitch;

@end

@implementation YM_Demo1ViewController

- (YM_PhotoManager *)manager
{
    if (!_manager) {
        _manager = [[YM_PhotoManager alloc] initWithType:YM_PhotoManagerType_Photo];
        _manager.configuration.videoMaxNum = 5;
        _manager.configuration.deleteTemporaryPhoto = NO;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.saveSystemAblum = YES; 
//        _manager.configuration.supportRotation = NO;
//        _manager.configuration.cameraCellShowPreview = NO;
//        _manager.configuration.themeColor = [UIColor redColor];
        _manager.configuration.navigationBar = ^(UINavigationBar *navigationBar) {
//            [navigationBar setBackgroundImage:[UIImage imageNamed:@"APPCityPlayer_bannerGame"] forBarMetrics:UIBarMetricsDefault];
//            navigationBar.barTintColor = [UIColor redColor];
        };
//        _manager.configuration.sectionHeaderTranslucent = NO;
//        _manager.configuration.navBarBackgroudColor = [UIColor redColor];
//        _manager.configuration.sectionHeaderSuspensionBgColor = [UIColor redColor];
//        _manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
//        _manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
//        _manager.configuration.selectedTitleColor = [UIColor redColor];
        _manager.configuration.requestImageAfterFinishingSelection = YES;
        kWeakSelf
        _manager.configuration.photoListBottomView = ^(YM_DatePhotoBottomView *bottomView) {
            kStrongSelf
            bottomView.bgView.barTintColor = self.bottomViewBgColor;
        };
        _manager.configuration.previewBottomView = ^(YM_DatePhotoPreviewBottomView *bottomView) {
            kStrongSelf
            bottomView.bgView.barTintColor = self.bottomViewBgColor;
        };
        _manager.configuration.albumListCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"albumList:%@",collectionView);
        };
        _manager.configuration.photoListCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"photoList:%@",collectionView);
        };
        _manager.configuration.previewCollectionView = ^(UICollectionView *collectionView) {
//            NSSLog(@"preview:%@",collectionView);
        };
//        _manager.configuration.movableCropBox = YES;
//        _manager.configuration.movableCropBoxEditSize = YES;
//        _manager.configuration.movableCropBoxCustomRatio = CGPointMake(1, 1);
        
        // 使用自动的相机  这里拿系统相机做示例 
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
        
        _manager.configuration.videoCanEdit = NO;
        _manager.configuration.photoCanEdit = NO;
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空选择" style:UIBarButtonItemStylePlain target:self action:@selector(didRightClick)];
    self.scrollView.delegate = self;
    if ([UIScreen mainScreen].bounds.size.width == 320) {
        self.clarityText.text = @"0.8";
    }else if ([UIScreen mainScreen].bounds.size.width == 375) {
        self.clarityText.text = @"1.4";
    }else {
        self.clarityText.text = @"1.7";
    }
    
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    if (!ifs) {
        
    }
    NSDictionary *info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    NSSLog(@"%@",info);
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)didRightClick {
    [self.manager clearSelectedList];
    self.total.text = @"总数量：0   ( 照片：0   视频：0 )";
    self.original.text = @"NO";
}
- (IBAction)goAlbum:(id)sender {
    self.manager.configuration.clarityScale = self.clarityText.text.floatValue;
    if (self.tintColor.selectedSegmentIndex == 0) {
        self.manager.configuration.themeColor = self.view.tintColor;
        self.manager.configuration.cellSelectedTitleColor = nil;
    }else if (self.tintColor.selectedSegmentIndex == 1) {
        self.manager.configuration.themeColor = [UIColor redColor];
        self.manager.configuration.cellSelectedTitleColor = [UIColor redColor];
    }else if (self.tintColor.selectedSegmentIndex == 2) {
        self.manager.configuration.themeColor = [UIColor whiteColor];
        self.manager.configuration.cellSelectedTitleColor = [UIColor whiteColor];
    }else if (self.tintColor.selectedSegmentIndex == 3) {
        self.manager.configuration.themeColor = [UIColor blackColor];
        self.manager.configuration.cellSelectedTitleColor = [UIColor blackColor];
    }else if (self.tintColor.selectedSegmentIndex == 4) {
        self.manager.configuration.themeColor = [UIColor orangeColor];
        self.manager.configuration.cellSelectedTitleColor = [UIColor orangeColor];
    }else {
        self.manager.configuration.themeColor = self.view.tintColor;
        self.manager.configuration.cellSelectedTitleColor = nil;
    }
    
    if (self.navBgColor.selectedSegmentIndex == 0) {
        self.manager.configuration.navBarBackgroudColor = nil;
        self.manager.configuration.statusBarStyle = UIStatusBarStyleDefault;
        self.manager.configuration.sectionHeaderTranslucent = YES;
        self.bottomViewBgColor = nil;
        self.manager.configuration.cellSelectedBgColor = nil;
        self.manager.configuration.selectedTitleColor = nil;
        self.manager.configuration.sectionHeaderSuspensionBgColor = nil;
        self.manager.configuration.sectionHeaderSuspensionTitleColor = nil;
    }else if (self.navBgColor.selectedSegmentIndex == 1) {
        self.manager.configuration.navBarBackgroudColor = [UIColor redColor];
        self.manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        self.manager.configuration.sectionHeaderTranslucent = NO;
        self.bottomViewBgColor = [UIColor redColor];
        self.manager.configuration.cellSelectedBgColor = [UIColor redColor];
        self.manager.configuration.selectedTitleColor = [UIColor redColor];
        self.manager.configuration.sectionHeaderSuspensionBgColor = [UIColor redColor];
        self.manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
    }else if (self.navBgColor.selectedSegmentIndex == 2) {
        self.manager.configuration.navBarBackgroudColor = [UIColor whiteColor];
        self.manager.configuration.statusBarStyle = UIStatusBarStyleDefault;
        self.manager.configuration.sectionHeaderTranslucent = NO;
        self.bottomViewBgColor = [UIColor whiteColor];
        self.manager.configuration.cellSelectedBgColor = self.manager.configuration.themeColor;
        self.manager.configuration.cellSelectedTitleColor = [UIColor whiteColor];
        self.manager.configuration.selectedTitleColor = [UIColor whiteColor];
        self.manager.configuration.sectionHeaderSuspensionBgColor = [UIColor whiteColor];
        self.manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor blackColor];
    }else if (self.navBgColor.selectedSegmentIndex == 3) {
        self.manager.configuration.navBarBackgroudColor = [UIColor blackColor];
        self.manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        self.manager.configuration.sectionHeaderTranslucent = NO;
        self.bottomViewBgColor = [UIColor blackColor];
        self.manager.configuration.cellSelectedBgColor = [UIColor blackColor];
        self.manager.configuration.selectedTitleColor = [UIColor blackColor];
        self.manager.configuration.sectionHeaderSuspensionBgColor = [UIColor blackColor];
        self.manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
    }else if (self.navBgColor.selectedSegmentIndex == 4) {
        self.manager.configuration.navBarBackgroudColor = [UIColor orangeColor];
        self.manager.configuration.statusBarStyle = UIStatusBarStyleLightContent;
        self.manager.configuration.sectionHeaderTranslucent = NO;
        self.bottomViewBgColor = [UIColor orangeColor];
        self.manager.configuration.cellSelectedBgColor = [UIColor orangeColor];
        self.manager.configuration.selectedTitleColor = [UIColor orangeColor];
        self.manager.configuration.sectionHeaderSuspensionBgColor = [UIColor orangeColor];
        self.manager.configuration.sectionHeaderSuspensionTitleColor = [UIColor whiteColor];
    }else {
        self.manager.configuration.navBarBackgroudColor = nil;
        self.manager.configuration.statusBarStyle = UIStatusBarStyleDefault;
        self.manager.configuration.sectionHeaderTranslucent = YES;
        self.bottomViewBgColor = nil;
        self.manager.configuration.cellSelectedBgColor = nil;
        self.manager.configuration.selectedTitleColor = nil;
        self.manager.configuration.sectionHeaderSuspensionBgColor = nil;
        self.manager.configuration.sectionHeaderSuspensionTitleColor = nil;
    }
    
    if (self.navTitleColor.selectedSegmentIndex == 0) {
        self.manager.configuration.navigationTitleColor = nil;
    }else if (self.navTitleColor.selectedSegmentIndex == 1) {
        self.manager.configuration.navigationTitleColor = [UIColor redColor];
    }else if (self.navTitleColor.selectedSegmentIndex == 2) {
        self.manager.configuration.navigationTitleColor = [UIColor whiteColor];
    }else if (self.navTitleColor.selectedSegmentIndex == 3) {
        self.manager.configuration.navigationTitleColor = [UIColor blackColor];
    }else if (self.navTitleColor.selectedSegmentIndex == 4) {
        self.manager.configuration.navigationTitleColor = [UIColor orangeColor];
    }else {
        self.manager.configuration.navigationTitleColor = nil;
    }
    self.manager.configuration.hideOriginalBtn = self.hideOriginal.on;
    self.manager.configuration.filtrationICloudAsset = self.icloudSwitch.on;
    self.manager.configuration.photoMaxNum = self.photoText.text.integerValue;
    self.manager.configuration.videoMaxNum = self.videoText.text.integerValue;
    self.manager.configuration.rowCount = self.columnText.text.integerValue;
    self.manager.configuration.downloadICloudAsset = self.downloadICloudAsset.on;
    self.manager.configuration.saveSystemAblum = self.saveAblum.on;
    self.manager.configuration.showDateSectionHeader = self.showHeaderSection.on;
    self.manager.configuration.reverseDate = self.reverse.on;
    self.manager.configuration.navigationTitleSynchColor = self.synchTitleColor.on;
    self.manager.configuration.replaceCameraViewController = self.useCustomCamera.on;
    self.manager.configuration.openCamera = self.addCamera.on;
    
//    [self.view hx_presentAlbumListViewControllerWithManager:self.manager delegate:self];
    
//    [self hx_presentAlbumListViewControllerWithManager:self.manager delegate:self];
    kWeakSelf
    [self hx_presentAlbumListViewControllerWithManager:self.manager done:^(NSArray<YM_PhotoModel *> *allList, NSArray<YM_PhotoModel *> *photoList, NSArray<YM_PhotoModel *> *videoList, NSArray<UIImage *> *imageList, BOOL original, YM_AlbumListViewController *viewController) {
        kStrongSelf
        self.total.text = [NSString stringWithFormat:@"总数量：%ld   ( 照片：%ld   视频：%ld )",allList.count, photoList.count, videoList.count];
        self.original.text = original ? @"YES" : @"NO";
        NSSLog(@"all - %@",allList);
        NSSLog(@"photo - %@",photoList);
        NSSLog(@"video - %@",videoList);
        NSSLog(@"image - %@",imageList);
    } cancel:^(YM_AlbumListViewController *viewController) {
        NSSLog(@"取消了");
    }];
    
//    YM_AlbumListViewController *vc = [[YM_AlbumListViewController alloc] init];
//    vc.delegate = self;
//    vc.manager = self.manager;
//    YM_CustomNavigationController *nav = [[YM_CustomNavigationController alloc] initWithRootViewController:vc];

//    [self presentViewController:nav animated:YES completion:nil];
}
- (IBAction)selectTypeClick:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.manager.type = YM_PhotoManagerType_Photo;
    }else if (sender.selectedSegmentIndex == 1) {
        self.manager.type = YM_PhotoManagerType_Video;
    }else {
        self.manager.type = YM_PhotoManagerType_All;
    }
    [self.manager clearSelectedList];
}
- (void)albumListViewController:(YM_AlbumListViewController *)albumListViewController didDoneAllImage:(NSArray<UIImage *> *)imageList {
    NSSLog(@"imageList:%@",imageList);
}
- (void)albumListViewController:(YM_AlbumListViewController *)albumListViewController didDoneAllList:(NSArray<YM_PhotoModel *> *)allList photos:(NSArray<YM_PhotoModel *> *)photoList videos:(NSArray<YM_PhotoModel *> *)videoList original:(BOOL)original {
    self.total.text = [NSString stringWithFormat:@"总数量：%ld   ( 照片：%ld   视频：%ld )",allList.count, photoList.count, videoList.count];
    //    [NSString stringWithFormat:@"%ld个",allList.count];
    //    self.photo.text = [NSString stringWithFormat:@"%ld张",photos.count];
    //    self.video.text = [NSString stringWithFormat:@"%ld个",videos.count];
    self.original.text = original ? @"YES" : @"NO";
    NSSLog(@"all - %@",allList);
    NSSLog(@"photo - %@",photoList);
    NSSLog(@"video - %@",videoList);
}
- (IBAction)tb:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.navigationTitleSynchColor = sw.on;
}
- (IBAction)yc:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.hideOriginalBtn = sw.on;
}

- (IBAction)same:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.selectTogether = sw.on;
}

- (IBAction)isLookGIFPhoto:(UISwitch *)sender {
    self.manager.configuration.lookGifPhoto = sender.on;
}

- (IBAction)isLookLivePhoto:(UISwitch *)sender {
    self.manager.configuration.lookLivePhoto = sender.on;
}
- (IBAction)photoCanEditClick:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.photoCanEdit = sw.on;
}
- (IBAction)videoCaneEditClick:(UISwitch *)sender {
    self.manager.configuration.videoCanEdit = sender.on;
}

- (IBAction)addCamera:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.manager.configuration.openCamera = sw.on;
} 
- (void)dealloc {
    NSSLog(@"dealloc");
}
@end

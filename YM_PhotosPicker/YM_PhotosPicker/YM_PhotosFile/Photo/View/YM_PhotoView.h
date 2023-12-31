//
//  YM_PhotoView.h
//  YM_PhotosPicker
//
//  Created by huangyuzhou on 2018/8/6.
//  Copyright © 2018年 huangyuzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YM_PhotoManager.h"
#import "YM_CollectionView.h"
@class YM_PhotoView;

@protocol YM_PhotoViewDelegate <NSObject>
@optional

/**
 照片/视频发生改变时调用 - 选择、移动顺序、删除
 @param photoView   视图本身
 @param allList     所有类型的模型数组
 @param photos      照片类型的模型数组
 @param videos      视频类型的模型数组
 @param isOriginal  是否原图
 */
- (void)photoView:(YM_PhotoView *)photoView
   changeComplete:(NSArray<YM_PhotoModel *> *)allList
           photos:(NSArray<YM_PhotoModel *> *)photos
           videos:(NSArray<YM_PhotoModel *> *)videos
         original:(BOOL)isOriginal;

/**
 照片/视频发生改变时调用 - 选择、移动顺序、删除
 @param photoView 视图本身
 @param imageList 图片数组
 */
- (void)photoView:(YM_PhotoView *)photoView imageChangeComplete:(NSArray<UIImage *> *)imageList;

/**
 当view高度改变时调用
 @param photoView 视图本身
 @param frame 位置大小
 */
- (void)photoView:(YM_PhotoView *)photoView updateFrame:(CGRect)frame;

/**
 点击取消时调用
 @param photoView self
 */
- (void)photoViewDidCancel:(YM_PhotoView *)photoView;

/**
 删除网络图片时调用
 
 @param photoView 视图本身
 @param networkPhotoUrl 被删除的图片地址
 */
- (void)photoView:(YM_PhotoView *)photoView deleteNetworkPhoto:(NSString *)networkPhotoUrl;

/**
 当前删除的模型
 
 @param photoView self
 @param model 模型
 @param index 下标
 */
- (void)photoView:(YM_PhotoView *)photoView currentDeleteModel:(YM_PhotoModel *)model currentIndex:(NSInteger)index;

/**
 长按手势结束时是否删除当前拖动的cell
 
 @param photoView 视图本身
 @return 是否删除
 */
- (BOOL)photoViewShouldDeleteCurrentMoveItem:(YM_PhotoView *)photoView;

/**
 长按手势发生改变时调用
 
 @param photoView 视图本身
 @param longPgr 长按手势识别器
 */
- (void)photoView:(YM_PhotoView *)photoView gestureRecognizerChange:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath;

/**
 长按手势开始时调用
 
 @param photoView 视图本身
 @param longPgr 长按手势识别器
 */
- (void)photoView:(YM_PhotoView *)photoView gestureRecognizerBegan:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath;

/**
 长按手势结束时调用
 
 @param photoView 视图本身
 @param longPgr 长按手势识别器
 */
- (void)photoView:(YM_PhotoView *)photoView gestureRecognizerEnded:(UILongPressGestureRecognizer *)longPgr indexPath:(NSIndexPath *)indexPath;



// 这次在相册选择的图片,不是所有选择的所有图片.
//- (void)photoViewCurrentSelected:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal;
@end

/** 使用选择照片之后自动布局的功能时就创建此块View. 初始化方法传入照片管理类 */
@interface YM_PhotoView : UIView

@property (weak, nonatomic) id<YM_PhotoViewDelegate> delegate;
@property (strong, nonatomic) YM_PhotoManager   * manager;
@property (strong, nonatomic) NSIndexPath       * currentIndexPath; // 自定义转场动画时用到的属性
@property (strong, nonatomic) YM_CollectionView * collectionView;

/**  是否把相机功能放在外面 默认 NO  */
@property (assign, nonatomic) BOOL outerCamera;

/**  每行个数 默认 3  */
@property (assign, nonatomic) NSInteger lineCount;

/**  每个item间距 默认 3  */
@property (assign, nonatomic) CGFloat spacing;

/**  隐藏cell上的删除按钮  */
@property (assign, nonatomic) BOOL hideDeleteButton;

/**  cell是否可以长按拖动编辑  */
@property (assign, nonatomic) BOOL editEnabled;

/**  是否显示添加的cell    默认 YES  */
@property (assign, nonatomic) BOOL showAddCell;

/**  预览大图时是否显示删除按钮  */
@property (assign, nonatomic) BOOL previewShowDeleteButton;

/**  已选的image数组  */
@property (strong, nonatomic) NSMutableArray *imageList;

- (instancetype)initWithFrame:(CGRect)frame
                  WithManager:(YM_PhotoManager *)manager;

- (instancetype)initWithFrame:(CGRect)frame
                      manager:(YM_PhotoManager *)manager;

- (instancetype)initWithManager:(YM_PhotoManager *)manager;

+ (instancetype)photoManager:(YM_PhotoManager *)manager;

- (NSIndexPath *)currentModelIndexPath:(YM_PhotoModel *)model;


#pragma mark - 相册事件
/**  跳转相册 如果需要选择相机/相册时 还是需要选择  */
- (void)goPhotoViewController;

/** 打开相片、视屏详情 */
//- (void)goPhoneDetailViewWithModel:(YM_PhotoModel *)photoModel;

/**  跳转相册 过滤掉选择 - 不管需不需要选择 直接前往相册  */
- (void)directGoPhotoViewController;

/**  跳转相机  */
- (void)goCameraViewController;

/**  删除某个模型  */
- (void)deleteModelWithIndex:(NSInteger)index;

/**  刷新view  */
- (void)refreshView;


@end

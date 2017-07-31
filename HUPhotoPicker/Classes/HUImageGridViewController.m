//
//  HUImageGridViewController.m
//  beautyAssistant
//
//  Created by jewelz on 2017/6/22.
//  Copyright © 2017年 Service+. All rights reserved.
//

#import "HUImageGridViewController.h"
#import "HUImageGridCell.h"
#import "HUImagePickerViewController.h"
#import "HUImageSelectModel.h"
#import "HUPHAuthorizationNotDeterminedView.h"
#import "Asset.h"
#import "UIView+HUConstraint.m"
#import "UIBarButtonItem+HUButton.h"
#import "HUPhotoManager.h"

@interface HUImageGridViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *uploadButton;
@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
@property (nonatomic, strong) PHImageRequestOptions *options;
@property (nonatomic, assign) CGSize targetSize;
@property (nonatomic, strong) NSMutableArray<HUImageSelectModel *> *selectModels;
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectIndexPaths;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) HUPHAuthorizationNotDeterminedView *notDeterminedView;

@end

@implementation HUImageGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem leftItemWithImage:UIImageMake(@"nav_back") target:self action:@selector(back)];
    
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusNotDetermined) {
        // 无权限
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self setupData]; 
                });
                
                return ;
            }
            [self rightBarItemClicked];
        }];
        return;
    }
       
    [self setupData];
}

- (void)setupData {
    [self setupView];
    

    if (_fetchResult == nil) {
        PHFetchOptions *options = [PHFetchOptions new];
        self.fetchResult = [PHAsset fetchAssetsWithOptions:options];
        self.title = @"所有照片";
    }
    
    CGFloat width = ((self.view.frame.size.width - 4.5) / 4) * [UIScreen mainScreen].scale;
    _targetSize = CGSizeMake(width, width);
    _cachingImageManager = [[PHCachingImageManager alloc] init];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
}

- (void)dealloc {
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

- (void)setFetchResult:(PHFetchResult<PHAsset *> *)fetchResult {
    _fetchResult = fetchResult;
    
    for (NSInteger i=0; i<fetchResult.count; i++) {
        HUImageSelectModel *model = [HUImageSelectModel new];
        model.indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [self.selectModels addObject:model];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _fetchResult[indexPath.item];
    
    HUImageGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HUImageGridCell reuseIdentifier] forIndexPath:indexPath];
    cell.representedAssetIdentifier = asset.localIdentifier;
    cell.model = self.selectModels[indexPath.item];
    [_cachingImageManager requestImageForAsset:asset targetSize:_targetSize contentMode:PHImageContentModeDefault options:_options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL isDegraded = [info[PHImageResultIsDegradedKey] boolValue];
        
        if (result && [cell.representedAssetIdentifier isEqualToString: asset.localIdentifier]) {
            cell.thumbnail.image = result;
            cell.isDegraded = isDegraded;
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _fetchResult[indexPath.item];
    if (asset.mediaType != PHAssetMediaTypeImage) {
//        [SVProgressHUD showInfoWithStatus:@"只支持选择图片"];
        return;
    }
    
    HUImageSelectModel *model = self.selectModels[indexPath.item];
    
    
    HUImagePickerViewController *pickVc = (HUImagePickerViewController *)self.navigationController;
    if (self.selectIndexPaths.count >= pickVc.maxCount && !model.isSelected) {
        NSString *title = [NSString stringWithFormat:@"你最多只能选择%zd张照片", pickVc.maxCount];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    model.isSelected = !model.isSelected;
    
    if (model.isSelected) {
        [self.selectIndexPaths addObject:indexPath];
        model.index = self.selectIndexPaths.count;
        model.asset = _fetchResult[indexPath.item];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } else {
        [self.selectIndexPaths removeObject:indexPath];
        model.asset = nil;
        NSMutableArray *indexPaths = [NSMutableArray array];
        [indexPaths addObject:indexPath];
        
        for (HUImageSelectModel *obj in self.selectModels) {
            if (obj != model && obj.index > model.index) {
                obj.index -= 1;
                [indexPaths addObject:obj.indexPath];
            }
        }
        
        [collectionView reloadItemsAtIndexPaths:indexPaths];
    }
    
    [self.uploadButton setTitle:[NSString stringWithFormat:@"上传(%zd)", self.selectIndexPaths.count] forState:UIControlStateNormal];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat wh = (self.view.frame.size.width - 4.5) / 4;
    return CGSizeMake(wh, wh);
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_fetchResult];
        if (details) {
            self.fetchResult = [details fetchResultAfterChanges];
            [self.collectionView reloadData];
        }
        
    });
}

#pragma mark - Action

- (void)rightBarItemClicked {
//    [SVProgressHUD dismiss];
    
    if (self.selectIndexPaths.count > 0) {
        [self fetchPhotos];
        return;
    }
    
    if ([self.navigationController isKindOfClass:[HUImagePickerViewController class]]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)fetchPhotos {
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:self.selectIndexPaths.count];
    
    
    for (HUImageSelectModel *model in self.selectModels) {
        if (model.isSelected) {
            [assets addObject:model.asset];
        }
    }
    
    if (assets.count == 0) {
//        [SVProgressHUD showInfoWithStatus:@"请选择照片"];
        return;
    }
    
//    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchPhotoWithAsset:assets];
    });
    
    
}

#pragma mark - Private

- (void)fetchPhotoWithAsset:(NSArray<PHAsset *> *)assets {
    
    [[HUPhotoManager sharedInstance] fetchPhotosWithAssets:assets progress:nil completed:^(NSArray<UIImage *> * _Nonnull images) {
        if (![self.navigationController isKindOfClass:[HUImagePickerViewController class]]) {
            //                        [SVProgressHUD dismiss];
            return;
        }
        
        NSLog(@"images: %@", images);
        HUImagePickerViewController *pickVc = (HUImagePickerViewController *)self.navigationController;
        if ([pickVc.delegate respondsToSelector:@selector(imagePickerViewController:didFinishPickingImageWithImages:assets:)]) {
            [pickVc.delegate imagePickerViewController:pickVc didFinishPickingImageWithImages:images assets:assets];
        }
        
    }];

}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}


#pragma mark - getter

- (void)setupView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemClicked)];
    
    [self.view addSubview:self.collectionView];
    [self.view addConstraintsWithVisualFormat:@"H:|[v0]|" views:@[self.collectionView]];
    [self.view addConstraintsWithVisualFormat:@"V:|[v0]|" views:@[self.collectionView]];
    
//    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectZero];
//    bottomView.backgroundColor = UIColorMake(65, 206, 199);
//    [self.view addSubview:bottomView];
//    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.left.right.equalTo(self.view);
//        make.height.mas_equalTo(49);
//    }];
//
//    _uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _uploadButton.backgroundColor = [UIColor whiteColor];
//    [_uploadButton setTitle:@"上传" forState:UIControlStateNormal];
//    [_uploadButton setTitleColor:UIColorMake(65, 206, 199) forState:UIControlStateNormal];
//    _uploadButton.titleLabel.font = UIFontMake(17);
//    [_uploadButton addTarget:self action:@selector(uploadButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [bottomView addSubview:_uploadButton];
//    [_uploadButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.left.right.equalTo(self.view);
//        make.height.mas_equalTo(48);
//    }];
    
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 1.5;
        layout.minimumInteritemSpacing = 1.5;
        layout.sectionInset = UIEdgeInsetsMake(1.5, 0, 1.5, 0);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = UIColorMake(238, 241, 242);
        _collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
       // _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[HUImageGridCell class] forCellWithReuseIdentifier:[HUImageGridCell reuseIdentifier]];
    }
    return _collectionView;
}

- (PHImageRequestOptions *)options {
    if (_options == nil) {
        _options = [PHImageRequestOptions new];
        _options.resizeMode = PHImageRequestOptionsResizeModeExact;
    }
    return _options;
}

- (NSMutableArray<HUImageSelectModel *> *)selectModels {
    if (_selectModels == nil) {
        _selectModels = [NSMutableArray array];
    }
    return _selectModels;
}

- (NSMutableArray<NSIndexPath *> *)selectIndexPaths {
    if (_selectIndexPaths == nil) {
        _selectIndexPaths = [NSMutableArray array];
    }
    return _selectIndexPaths;
}

- (NSMutableArray *)images {
    if (_images == nil) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (HUPHAuthorizationNotDeterminedView *)notDeterminedView {
    if (_notDeterminedView == nil) {
        _notDeterminedView = [[HUPHAuthorizationNotDeterminedView alloc] initWithFrame:self.view.bounds];
    }
    return _notDeterminedView;
}

@end

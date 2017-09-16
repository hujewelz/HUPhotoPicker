//
//  HUImageGridViewController.m
//  beautyAssistant
//
//  Created by jewelz on 2017/6/22.
//  Copyright © 2017年 Service+. All rights reserved.
//

#import "HUImageGridViewController.h"
#import "HUImageGridCell.h"
#import "HUTakePhotoCell.h"
#import "HUImagePickerViewController.h"
#import "HUImageSelectModel.h"
#import "HUPHAuthorizationNotDeterminedView.h"
#import "Asset.h"
#import "UIView+HUConstraint.m"
#import "UIBarButtonItem+HUButton.h"
#import "HUPhotoManager.h"
#import "HUToast.h"

@interface HUImageGridViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSInteger _cloumns;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *titleButton;
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

- (void)dealloc {
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}




#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _fetchResult.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        HUTakePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HUTakePhotoCell reuseIdentifier] forIndexPath:indexPath];
        return cell;
    }
    PHAsset *asset = _fetchResult[indexPath.item - 1];
    
    HUImageGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HUImageGridCell reuseIdentifier] forIndexPath:indexPath];
    cell.representedAssetIdentifier = asset.localIdentifier;
    cell.model = self.selectModels[indexPath.item-1];
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
    if (indexPath.item == 0) {
        [self takePhoto];
        return;
    }
    PHAsset *asset = _fetchResult[indexPath.item-1];
    if (asset.mediaType != PHAssetMediaTypeImage) {
        return;
    }
    
    HUImageSelectModel *model = self.selectModels[indexPath.item-1];
    
    if (!model.isSelected) {
        [[HUPhotoManager sharedInstance] checkPhotoIsAvaliableWithAsset:asset progress:^(double progress) {
            
        } completed:^(BOOL avaliable, UIImage * _Nonnull image) {
            if (avaliable) {
                HUImagePickerViewController *pickVc = (HUImagePickerViewController *)self.navigationController;
                if (self.selectIndexPaths.count >= pickVc.maxCount && !model.isSelected) {
                    NSString *title = [NSString stringWithFormat:@"你最多只能选择%zd张照片", pickVc.maxCount];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                    [alert show];
                    return;
                }
                
                model.isSelected = !model.isSelected;
                
                [self.selectIndexPaths addObject:indexPath];
                model.index = self.selectIndexPaths.count;
                model.asset = _fetchResult[indexPath.item-1];
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                
                [self resetRightBarButton];
            } else {
                [HUToast makeToast:@"iCloud同步中" inView:self.view];
            }
        }];
    } else {
        
        model.isSelected = !model.isSelected;
        
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
        [self resetRightBarButton];
    }
    
   
//    return;
//    
//    
//    HUImagePickerViewController *pickVc = (HUImagePickerViewController *)self.navigationController;
//    if (self.selectIndexPaths.count >= pickVc.maxCount && !model.isSelected) {
//        NSString *title = [NSString stringWithFormat:@"你最多只能选择%zd张照片", pickVc.maxCount];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
//    
//    model.isSelected = !model.isSelected;
//    
//    if (model.isSelected) {
//        [self.selectIndexPaths addObject:indexPath];
//        model.index = self.selectIndexPaths.count;
//        model.asset = _fetchResult[indexPath.item-1];
//        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
//    } else {
//        [self.selectIndexPaths removeObject:indexPath];
//        model.asset = nil;
//        NSMutableArray *indexPaths = [NSMutableArray array];
//        [indexPaths addObject:indexPath];
//        
//        for (HUImageSelectModel *obj in self.selectModels) {
//            if (obj != model && obj.index > model.index) {
//                obj.index -= 1;
//                [indexPaths addObject:obj.indexPath];
//            }
//        }
//        
//        [collectionView reloadItemsAtIndexPaths:indexPaths];
//    }
    
   // [self.uploadButton setTitle:[NSString stringWithFormat:@"上传(%zd)", self.selectIndexPaths.count] forState:UIControlStateNormal];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat space = 1.5 * (_cloumns - 1);
    CGFloat wh = (self.view.frame.size.width - space) / _cloumns;
    return CGSizeMake(wh, wh);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    HUImagePickerViewController *pickVc = (HUImagePickerViewController *)self.navigationController;
    if ([pickVc.delegate respondsToSelector:@selector(imagePickerViewController:didFinishPickingImageWithImages:assets:)]) {
        [pickVc.delegate imagePickerViewController:pickVc didFinishPickingImageWithImages:@[image] assets:nil];
    }

}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        
//        PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_fetchResult];
//        if (details) {
//            self.fetchResult = [details fetchResultAfterChanges];
////            [self.collectionView reloadData];
//        }
//        
//    });
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
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchPhotoWithAsset:assets];
    });
    
    
}

#pragma mark - Private

- (void)fetchPhotoWithAsset:(NSArray<PHAsset *> *)assets {
    
    [[HUPhotoManager sharedInstance] fetchPhotosWithAssets:assets progress:nil completed:^(NSArray<UIImage *> * _Nonnull images) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.navigationController isKindOfClass:[HUImagePickerViewController class]]) {
                return;
            }
            
            NSLog(@"images: %@", images);
            HUImagePickerViewController *pickVc = (HUImagePickerViewController *)self.navigationController;
            if ([pickVc.delegate respondsToSelector:@selector(imagePickerViewController:didFinishPickingImageWithImages:assets:)]) {
                [pickVc.delegate imagePickerViewController:pickVc didFinishPickingImageWithImages:images assets:assets];
            }

        });
    }];

}

- (void)takePhoto {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [[[UIAlertView alloc] initWithTitle:@"您的设备不支持相机" message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetRightBarButton {
    self.navigationItem.rightBarButtonItem.enabled = self.selectIndexPaths.count > 0;
    
    HUImagePickerViewController *pickVc = (HUImagePickerViewController *)self.navigationController;
    NSString *rightTitle = self.selectIndexPaths.count > 0 ? [NSString stringWithFormat:@"确定(%zd/%zd)", self.selectIndexPaths.count, pickVc.maxCount] : @"确定";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemClicked)];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}


#pragma mark - getter

- (void)setupView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemClicked)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.view addSubview:self.collectionView];
    [self.view addConstraintsWithVisualFormat:@"H:|[v0]|" views:@[self.collectionView]];
    [self.view addConstraintsWithVisualFormat:@"V:|[v0]|" views:@[self.collectionView]];
    
    self.navigationItem.titleView = self.titleButton;
    if (self.title) {
        [self.titleButton setTitle:self.title forState:UIControlStateNormal];
    }
    

//    [_uploadButton addTarget:self action:@selector(uploadButtonClicked) forControlEvents:UIControlEventTouchUpInside];

}

- (void)setupData {
    
    HUImagePickerViewController *pickVc = (HUImagePickerViewController *)self.navigationController;
    _cloumns = pickVc.numberOfColumns;
    [[HUPhotoManager sharedInstance] setNetworkAccessAllowed:pickVc.isNetworkAccessAllowed];
    
    [self setupView];
    
    if (_fetchResult == nil) {
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        self.fetchResult = [PHAsset fetchAssetsWithOptions:options];
        self.title = @"所有照片";
    }
    
    CGFloat width = ((self.view.frame.size.width - 4.5) / 4) * [UIScreen mainScreen].scale;
    _targetSize = CGSizeMake(width, width);
    _cachingImageManager = [[PHCachingImageManager alloc] init];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
}

#pragma mark - getter & setter


- (void)setFetchResult:(PHFetchResult<PHAsset *> *)fetchResult {
    _fetchResult = fetchResult;
    [self.selectModels removeAllObjects];
    [self.selectIndexPaths removeAllObjects];
    
    for (NSInteger i=0; i<fetchResult.count; i++) {
        HUImageSelectModel *model = [HUImageSelectModel new];
        model.indexPath = [NSIndexPath indexPathForItem:i+1 inSection:0];
        [self.selectModels addObject:model];
    }
    
    [self.collectionView reloadData];
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
        [_collectionView setAlwaysBounceVertical:YES];
        [_collectionView registerClass:[HUTakePhotoCell class] forCellWithReuseIdentifier:[HUTakePhotoCell reuseIdentifier]];
        [_collectionView registerClass:[HUImageGridCell class] forCellWithReuseIdentifier:[HUImageGridCell reuseIdentifier]];
    }
    return _collectionView;
}

- (UIButton *)titleButton {
    if (_titleButton == nil) {
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_titleButton setTitle:@"全部照片" forState:UIControlStateNormal];
        [_titleButton setTitleColor:UIColorMake(30, 30, 30) forState:UIControlStateNormal];
        _titleButton.titleLabel.font = UIFontMake(16);
    }
    return _titleButton;
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

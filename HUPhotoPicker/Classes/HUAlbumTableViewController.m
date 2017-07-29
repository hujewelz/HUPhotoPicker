//
//  BAAlbumTableViewController.m
//  beautyAssistant
//
//  Created by jewelz on 2017/6/22.
//  Copyright © 2017年 Service+. All rights reserved.
//

#import "HUAlbumTableViewController.h"
#import "HUImageGridViewController.h"
#import <Photos/Photos.h>
#import "HUAlbumCell.h"

@interface HUAlbumTableViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHFetchResult<PHAsset *> *allPhotos;
@property (nonatomic, strong) PHFetchResult<PHAssetCollection *> *smartAlbums;
@property (nonatomic, strong) PHFetchResult<PHCollection *> *userCollectons;

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;
@property (nonatomic, strong) PHImageRequestOptions *options;

@end

@implementation HUAlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusNotDetermined) {
        // 无权限
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self setupData];
                return ;
            }
            [self rightBarItemClicked];
        }];
        return;
    }
    
    if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied) {
        [self rightBarItemClicked];
        return;
    }
    
    [self setupData];
    
}

- (void)dealloc {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

- (void)setupData {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemClicked)];
    
    self.tableView.rowHeight = 80;
    [self.tableView registerNib:[HUAlbumCell nib] forCellReuseIdentifier:[HUAlbumCell reuseIdentifier]];
    _cachingImageManager = [[PHCachingImageManager alloc] init];
    
    PHFetchOptions *options = [PHFetchOptions new];
    _allPhotos = [PHAsset fetchAssetsWithOptions:options];
    _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    _userCollectons = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarItemClicked {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return _smartAlbums.count;
    }
    
    return _userCollectons.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *asset = nil;
    HUAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:[HUAlbumCell reuseIdentifier] forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.titleLabel.text = @"所有照片";
        cell.countLabel.text = [NSString stringWithFormat:@"%zd", _allPhotos.count];
        asset = [_allPhotos firstObject];
        
    } else if (indexPath.section == 1) {
        PHAssetCollection *collection = _smartAlbums[indexPath.row];
        cell.titleLabel.text = collection.localizedTitle;
        
        PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        cell.countLabel.text = [NSString stringWithFormat:@"%zd", results.count];
        asset = [results firstObject];
        
    } else if (indexPath.section == 2) {
        PHCollection *collection = _userCollectons[indexPath.row];
        cell.titleLabel.text = collection.localizedTitle;
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            cell.countLabel.text = [NSString stringWithFormat:@"%zd", results.count];
            asset = [results firstObject];
        }
    }
    
    [_cachingImageManager requestImageForAsset:asset targetSize:CGSizeMake(120, 120) contentMode:PHImageContentModeDefault options:_options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        NSLog(@"result: %@", result);
        cell.album.image = result;
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HUImageGridViewController *vc = [[HUImageGridViewController alloc] init];
    if (indexPath.section == 0) {
        vc.fetchResult = _allPhotos;
        vc.title = @"所有照片";
    } else if (indexPath.section == 1) {
        PHAssetCollection *collection = _smartAlbums[indexPath.row];
        vc.title = collection.localizedTitle;
        PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        vc.fetchResult = results;
        
    } else if (indexPath.section == 2) {
        PHCollection *collection = _userCollectons[indexPath.row];
        vc.title = collection.localizedTitle;
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
            vc.fetchResult = results;
        }
    }
    [self.navigationController pushViewController:vc animated:true];
}


- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        PHFetchResultChangeDetails *all = [changeInstance changeDetailsForFetchResult:_allPhotos];
        PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_smartAlbums];
        PHFetchResultChangeDetails *users = [changeInstance changeDetailsForFetchResult:_userCollectons];
        
        if (all) {
            _allPhotos = [all fetchResultAfterChanges];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (details) {
            _smartAlbums = [details fetchResultAfterChanges];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (users) {
            _userCollectons = [users fetchResultAfterChanges];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    });
}

- (PHImageRequestOptions *)options {
    if (_options == nil) {
        _options = [PHImageRequestOptions new];
        _options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [_options setSynchronous:false];
        [_options setNetworkAccessAllowed:false];
    }
    return _options;
}

@end

//
//  HUImagePickerViewController.m
//  beautyAssistant
//
//  Created by jewelz on 2017/6/22.
//  Copyright © 2017年 Service+. All rights reserved.
//

#import "HUImagePickerViewController.h"
#import "HUAlbumTableViewController.h"
#import "HUImageGridViewController.h"
#import "HUPHAuthorizationNotDeterminedView.h"
#import "HUPHAuthorizationNotDeterminedViewController.h"
#import "Asset.h"
#import <Photos/Photos.h>

@interface HUImagePickerViewController ()

@end

@implementation HUImagePickerViewController
@synthesize delegate = _delegate;

- (instancetype)initWithMaxCount:(NSInteger)maxCount numberOfColumns:(NSInteger)columns {
    
    UIViewController *rootVc = nil;
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied) {
        rootVc = [[HUPHAuthorizationNotDeterminedViewController alloc] init];
    } else {
        rootVc = [[HUImageGridViewController alloc] init];
    }
    self = [super initWithRootViewController:rootVc];
    if (self) {
        _maxCount = maxCount;
        _numberOfColumns = columns;
        _spacing = 1.5;
    }
    return self;
}

- (instancetype)init {
    
    return [self initWithMaxCount:10 numberOfColumns:4];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setTintColor:UIColorMake(30, 30, 30)];

    self.normalTitleTextAttribute = @{NSForegroundColorAttributeName:UIColorMake(30, 30, 30), NSFontAttributeName:[UIFont systemFontOfSize:17]};
    
    //设置正常状态
    self.barItemNormalTextAttribute =  @{NSForegroundColorAttributeName:UIColorMake(81, 88, 102), NSFontAttributeName:[UIFont systemFontOfSize:15]};

    //设置不可用状态
    self.barItemDisableTextAttribute = @{NSForegroundColorAttributeName:UIColorMake(209, 209, 209), NSFontAttributeName:[UIFont systemFontOfSize:15]};
  
    
//    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
//    if (author == PHAuthorizationStatusNotDetermined || author == PHAuthorizationStatusAuthorized) {
//        HUAlbumTableViewController *vc = [[HUAlbumTableViewController alloc] init];
//        
//        [self pushViewController:vc animated:true];
//    }
    
}

- (void)setDelegate:(id<HUImagePickerViewControllerDelegate,UINavigationControllerDelegate>)delegate {
    _delegate = delegate;
}

- (id<HUImagePickerViewControllerDelegate,UINavigationControllerDelegate>)delegate {
    return _delegate;
}

- (void)setNormalTitleTextAttribute:(NSDictionary *)normalTitleTextAttribute {
    _normalTitleTextAttribute = normalTitleTextAttribute;
    [self.navigationBar setTitleTextAttributes:_normalTitleTextAttribute];
}

- (void)setBarItemNormalTextAttribute:(NSDictionary *)barItemNormalTextAttribute {
    _barItemNormalTextAttribute = barItemNormalTextAttribute;
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:barItemNormalTextAttribute forState:UIControlStateNormal];
}

- (void)setBarItemDisableTextAttribute:(NSDictionary *)barItemDisableTextAttribute {
    _barItemDisableTextAttribute = barItemDisableTextAttribute;
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:barItemDisableTextAttribute forState:UIControlStateDisabled];
}

@end

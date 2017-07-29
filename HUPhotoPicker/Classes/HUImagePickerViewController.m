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

- (instancetype)init {
    UIViewController *rootVc = nil;
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied) {
        rootVc = [[HUPHAuthorizationNotDeterminedViewController alloc] init];
    } else {
        rootVc = [[HUImageGridViewController alloc] init];
    }
    self = [super initWithRootViewController:rootVc];
    if (self) {
        _maxCount = 10;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[UINavigationBar appearance] setTintColor:UIColorMake(30, 30, 30)];
    
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
    if (author == PHAuthorizationStatusNotDetermined || author == PHAuthorizationStatusAuthorized) {
        HUAlbumTableViewController *vc = [[HUAlbumTableViewController alloc] init];
        
        [self pushViewController:vc animated:true];
    }
    
}

- (void)setDelegate:(id<HUImagePickerViewControllerDelegate,UINavigationControllerDelegate>)delegate {
    _delegate = delegate;
}

- (id<HUImagePickerViewControllerDelegate,UINavigationControllerDelegate>)delegate {
    return _delegate;
}



@end

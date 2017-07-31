//
//  HUViewController.m
//  HUPhotoPicker
//
//  Created by huluobobo on 07/28/2017.
//  Copyright (c) 2017 huluobobo. All rights reserved.
//

#import "HUViewController.h"
#import "HUCollectionViewCell.h"
#import <HUPhotoPicker/HUPhotoPicker.h>

@interface HUViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, HUImagePickerViewControllerDelegate, UINavigationControllerDelegate> {
    NSArray *_images;
}

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation HUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
	
    _images = [NSArray array];
}

- (IBAction)pickImage:(id)sender {
    
    HUImagePickerViewController *picker = [[HUImagePickerViewController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - UICollectionViewDataSource 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    HUCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.imageView.image = _images[indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.view.frame), 200);
}

- (void)imagePickerViewController:(HUImagePickerViewController *)imagePickerViewController didFinishPickingImageWithImages:(NSArray<UIImage *> *)images assets:(NSArray<PHAsset *> *)assets {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _images = images;
    [self.collectionView reloadData];
}

@end

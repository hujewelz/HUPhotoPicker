//
//  HUImagePickerViewController.h
//  beautyAssistant
//
//  Created by jewelz on 2017/6/22.
//  Copyright © 2017年 Service+. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HUImagePickerViewController, PHAsset;
@protocol HUImagePickerViewControllerDelegate <NSObject>

@optional

- (void)imagePickerViewController:(HUImagePickerViewController *)imagePickerViewController
  didFinishPickingImageWithImages:(NSArray<UIImage *> *)images assets:(NSArray<PHAsset *> *)assets;

- (void)imagePickerViewControllerDidBeginUploadImage:(HUImagePickerViewController *)imagePickerViewController;


@end

@interface HUImagePickerViewController : UINavigationController

@property (nonatomic, weak) id <HUImagePickerViewControllerDelegate, UINavigationControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger maxCount;

@end

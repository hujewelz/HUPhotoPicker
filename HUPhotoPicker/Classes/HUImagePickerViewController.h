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

- (void)imagePickerViewController:(nonnull HUImagePickerViewController *)imagePickerViewController
  didFinishPickingImageWithImages:(nonnull NSArray<UIImage *> *)images assets:(nullable NSArray<PHAsset *> *)assets;

- (void)imagePickerViewControllerDidBeginUploadImage:(nonnull HUImagePickerViewController *)imagePickerViewController;


@end

@interface HUImagePickerViewController : UINavigationController

- (instancetype _Nonnull )initWithMaxCount:(NSInteger)maxCount numberOfColumns:(NSInteger)columns;


@property (nonatomic, weak, nullable) id <HUImagePickerViewControllerDelegate, UINavigationControllerDelegate> delegate;

/// 允许选择最大图片数
@property (nonatomic, assign) NSInteger maxCount;

/// 图片列数
@property (nonatomic, assign) NSInteger numberOfColumns;

/// 每列之间间距
@property (nonatomic, assign) CGFloat spacing;

/// 是否允许通过网络下载iCloud图片，默认为 NO
@property (nonatomic, assign, getter=isNetworkAccessAllowed) BOOL networkAccessAllowed;

/// 设置导航栏默认状态下标题文字样式
@property (nonatomic, copy, nullable) NSDictionary *normalTitleTextAttribute;

/// 设置导航栏按钮默认状态下文字样式
@property (nonatomic, copy, nullable) NSDictionary *barItemNormalTextAttribute;

/// 设置导航栏按钮不可用状态下文字样式
@property (nonatomic, copy, nullable) NSDictionary *barItemDisableTextAttribute;

@end

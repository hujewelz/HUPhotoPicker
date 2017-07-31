//
//  HUPhotoHelper.h
//  Pods
//
//  Created by jewelz on 2017/7/29.
//
//

#import <Foundation/Foundation.h>

@class PHAsset;
@interface HUPhotoHelper : NSObject


+ (nonnull instancetype)sharedInstance;

- (void)fetchPhotoWithAsset:(nonnull PHAsset *)asset
                   progress:(nullable void(^)(double progress))progress
                  completed:(nullable void(^)(BOOL success,  UIImage * _Nonnull image))completed;

- (void)fetchPhotosWithAssets:(nonnull NSArray<PHAsset *> *)assets
                   progress:(nullable void(^)(double progress))progress
                  completed:(nullable void(^)(NSArray<UIImage *> * _Nonnull images))completed;

- (void)cancelPhotoRequest;

- (BOOL)isPhotoDownloaded:(PHAsset *)asset;

@end

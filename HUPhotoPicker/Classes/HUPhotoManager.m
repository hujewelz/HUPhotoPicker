//
//  HUPhotoHelper.m
//  Pods
//
//  Created by jewelz on 2017/7/29.
//
//

#import "HUPhotoManager.h"
#import <Photos/Photos.h>

@interface HUPhotoManager()

@property (nonatomic, copy) NSMutableDictionary<NSString *, UIImage *> *imageCache;
@property (nonatomic, copy) NSMutableDictionary<NSString *, NSNumber *> * imageRequestIDs;
@property (nonatomic, strong) PHImageRequestOptions *requestOptions;

@end

@implementation HUPhotoManager

+ (instancetype)sharedInstance {
    static HUPhotoManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[HUPhotoManager alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self == [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchPhotosWithAssets:(nonnull NSArray<PHAsset *> *)assets
                     progress:(nullable void(^)(double progress))progress
                    completed:(nullable void(^)(NSArray<UIImage *> * _Nonnull images))completed {

    __block NSMutableArray *downloadeds = [NSMutableArray array];
    NSMutableArray *shouldDownlds = [NSMutableArray array];
    
    for (PHAsset *asset in assets) {
        UIImage *cachedImage = [self.imageCache objectForKey:asset.localIdentifier];
        if (cachedImage) {
            [downloadeds addObject:cachedImage];
        } else {
            [shouldDownlds addObject:asset];
        }
    }
    
    
    if (downloadeds.count >= assets.count) {
        if (progress) {
            progress(1);
        }
        if (completed) {
            completed(downloadeds);
        }
        return;
    }
    
    double count = shouldDownlds.count;
    for (PHAsset *asset in shouldDownlds) {
        [self fetchPhotoWithAsset:asset progress:^(double _progress) {
             if (progress) {
                 progress(_progress / count);
             }
            
        } completed:^(BOOL success, UIImage * _Nullable image) {
            
            [downloadeds addObject:image];
            
            if (downloadeds.count >= assets.count) {
                if (progress) {
                    progress(1);
                }
                if (completed) {
                    completed(downloadeds);
                }
            }
            
        }];
    }
    

}


- (void)fetchPhotoWithAsset:(nonnull PHAsset *)asset
                   progress:(nullable void(^)(double progress))progress
                  completed:(nullable void(^)(BOOL success, UIImage * _Nonnull  image))completed {
    
    UIImage *cachedImage = [self.imageCache objectForKey:asset.localIdentifier];
    if (cachedImage) {
        if (progress) {
            progress(1);
        }
        if (completed) {
            completed(YES, cachedImage);
        }
        return;
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    [options setNetworkAccessAllowed:YES];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [self.requestOptions setProgressHandler: ^(double _progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(_progress);
            }
        });
    }];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(asset.pixelWidth * scale, asset.pixelHeight * scale);
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
//        NSLog(@"info: %@", info);
//        NSLog(@"image: %@", result);
//
        if (result) {
            [self.imageCache setObject:result forKey:asset.localIdentifier];
        }
    
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        BOOL isInCloudKey = [info objectForKey:PHImageResultIsInCloudKey];
        // 从iCloud下载图片
        if (result && downloadFinined) {
            NSLog(@"图片下载成功");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(YES, result);
                }
            });
            
        } else if (isInCloudKey && !result) {
            UIImage *image = [self.imageCache objectForKey:asset.localIdentifier];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completed) {
                        completed(YES, image);
                    }
                });
            }
        }
        
    }];
    
    [self.imageRequestIDs setObject:@(requestID) forKey:asset.localIdentifier];
    

}

- (void)cancelPhotoRequest {
    
    for (NSNumber *obj in self.imageRequestIDs) {
        [[PHImageManager defaultManager] cancelImageRequest:obj.intValue];
    }
}

- (BOOL)isPhotoDownloaded:(PHAsset *)asset {
    return true;
}

- (void)cancelPhotoRequestWithAsset:(PHAsset *)asset {
    NSNumber *idNumber = [self.imageRequestIDs objectForKey:asset.localIdentifier];
    if (!idNumber) {
        return;
    }
    
    [[PHImageManager defaultManager] cancelImageRequest:idNumber.intValue];
}



- (void)clearCache {
    [self.imageCache removeAllObjects];
    [self.imageRequestIDs removeAllObjects];
}

#pragma mark - getter

- (NSMutableDictionary<NSString *,UIImage *> *)imageCache {
    if (_imageCache == nil) {
        _imageCache = [NSMutableDictionary dictionary];
    }
    return _imageCache;
}

- (NSMutableDictionary<NSString *,NSNumber *> *)imageRequestIDs {
    if (_imageRequestIDs == nil) {
        _imageRequestIDs = [NSMutableDictionary dictionary];
    }
    return _imageRequestIDs;
}

- (PHImageRequestOptions *)requestOptions {
    if (_requestOptions == nil) {
        _requestOptions = [PHImageRequestOptions new];
        //[options setSynchronous:YES];
        [_requestOptions setNetworkAccessAllowed:YES];
        _requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    }
    return _requestOptions;
}


@end

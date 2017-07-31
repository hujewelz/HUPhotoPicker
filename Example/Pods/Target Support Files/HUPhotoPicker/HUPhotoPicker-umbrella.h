#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HUImagePickerViewController.h"
#import "HUPhotoManager.h"
#import "HUPhotoPicker.h"

FOUNDATION_EXPORT double HUPhotoPickerVersionNumber;
FOUNDATION_EXPORT const unsigned char HUPhotoPickerVersionString[];


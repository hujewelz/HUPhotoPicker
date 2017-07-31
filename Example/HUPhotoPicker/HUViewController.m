//
//  HUViewController.m
//  HUPhotoPicker
//
//  Created by huluobobo on 07/28/2017.
//  Copyright (c) 2017 huluobobo. All rights reserved.
//

#import "HUViewController.h"
//#import <HUPhotoPicker/HUPhotoPicker-umbrella.h>
#import <HUPhotoPicker/HUPhotoPicker.h>

@interface HUViewController () <HUImagePickerViewControllerDelegate, UINavigationControllerDelegate>

@end

@implementation HUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pickImage:(id)sender {
    
    HUImagePickerViewController *picker = [[HUImagePickerViewController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerViewController:(HUImagePickerViewController *)imagePickerViewController didFinishPickingImageWithImages:(NSArray<UIImage *> *)images assets:(NSArray<PHAsset *> *)assets {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

//
//  UIImage+HUPicker.m
//  HUPhotoPicker
//
//  Created by huluobo on 2017/11/19.
//

#import "UIImage+HUPicker.h"
#import "NSBundle+HUPicker.h"

@implementation UIImage (HUPicker)

+ (UIImage *)hu_imageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    return image ? image : [UIImage imageNamed:name inBundle:[NSBundle hu_bundle] compatibleWithTraitCollection:nil];
}

@end

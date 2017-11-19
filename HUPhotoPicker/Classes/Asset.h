//
//  Asset.h
//  HUPhotoPicker
//
//  Created by jewelz on 2017/7/28.
//

#ifndef Asset_h
#define Asset_h

#import "UIImage+HUPicker.h"

#define UIFontBoldMake(size) [UIFont boldSystemFontOfSize:(size)]
#define UIFontMake(size) [UIFont systemFontOfSize:(size)]
#define UIColorMake(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]

#define UIImageMake(named) [UIImage hu_imageNamed:(named)]

#endif /* Asset_h */

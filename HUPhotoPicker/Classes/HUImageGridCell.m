//
//  HUImageGridCell.m
//  beautyAssistant
//
//  Created by jewelz on 2017/6/22.
//  Copyright © 2017年 Service+. All rights reserved.
//

#import "HUImageGridCell.h"
#import "Asset.h"
#import "UIView+HUConstraint.h"
#import <Photos/Photos.h>

@interface HUImageGridCell ()

@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIImageView *videoIcon;
@property (nonatomic, strong) UIView *disableMask;


@end
@implementation HUImageGridCell

+ (NSString *)reuseIdentifier {
    return @"HUImageGridCell";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setModel:(HUImageSelectModel *)model {
    _model = model;
    
    [_checkButton setSelected:model.isSelected];
    if (model.isSelected) {
        NSString *title = [NSString stringWithFormat:@"%zd", model.index];
        [_checkButton setTitle:title forState:UIControlStateSelected];
    }
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    _checkButton.hidden = asset.mediaType != PHAssetMediaTypeImage;
    _videoIcon.hidden = asset.mediaType != PHAssetMediaTypeVideo;
    _disableMask.hidden = _videoIcon.isHidden;
}

- (void)setIsDegraded:(BOOL)isDegraded {
    _isDegraded = isDegraded;
    self.degradedButton.hidden = !isDegraded;
}

- (void)setupView {
    [self.contentView addSubview:self.thumbnail];
    
    [self.contentView addConstraintsWithVisualFormat:@"H:|[v0]|" views:@[self.thumbnail]];
    [self.contentView addConstraintsWithVisualFormat:@"V:|[v0]|" views:@[self.thumbnail]];
    
    [self.contentView addSubview:self.checkButton];
    [self.contentView addConstraintsWithVisualFormat:@"H:[v0(==22)]-2-|" views:@[self.checkButton]];
    [self.contentView addConstraintsWithVisualFormat:@"V:|-2-[v0(==22)]" views:@[self.checkButton]];
    
    [self.contentView addSubview:self.degradedButton];
    [self.contentView addConstraintsWithVisualFormat:@"H:|[v0]|" views:@[self.degradedButton]];
    [self.contentView addConstraintsWithVisualFormat:@"V:|[v0]|" views:@[self.degradedButton]];
    
    [self.contentView addSubview:self.disableMask];
    [self.contentView addConstraintsWithVisualFormat:@"H:|[v0]|" views:@[self.disableMask]];
    [self.contentView addConstraintsWithVisualFormat:@"V:|[v0]|" views:@[self.disableMask]];
    
    [self.contentView addSubview:self.videoIcon];
    [self.contentView addConstraintsWithVisualFormat:@"H:[v0]-4-|" views:@[self.videoIcon]];
    [self.contentView addConstraintsWithVisualFormat:@"V:|-4-[v0]" views:@[self.videoIcon]];

}

- (UIImageView *)thumbnail {
    if (_thumbnail == nil) {
        _thumbnail = [UIImageView new];
        _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnail.backgroundColor = [UIColor redColor];
        _thumbnail.clipsToBounds = YES;
    }
    return _thumbnail;
}

- (UIButton *)checkButton {
    if (_checkButton == nil) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkButton setBackgroundImage:UIImageMake(@"photo_button_normal") forState:UIControlStateNormal];
        [_checkButton setBackgroundImage:UIImageMake(@"photo_button_selected") forState:UIControlStateSelected];
        [_checkButton setTitle:nil forState:UIControlStateNormal];
        _checkButton.adjustsImageWhenHighlighted = NO;
        _checkButton.userInteractionEnabled = NO;
        [_checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _checkButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _checkButton;
}

- (UIImageView *)videoIcon {
    if (_videoIcon == nil) {
        _videoIcon = [UIImageView new];
        _videoIcon.image = UIImageMake(@"icon_video");
        _videoIcon.hidden = YES;
    }
    return _videoIcon;
}

- (UIButton *)degradedButton {
    if (_degradedButton == nil) {
        _degradedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _degradedButton.adjustsImageWhenHighlighted = NO;
        _degradedButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    }
    return _degradedButton;
}

- (UIView *)disableMask {
    if (_disableMask == nil) {
        _disableMask = [UIView new];
        _disableMask.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
        _disableMask.hidden = YES;
    }
    return _disableMask;
}

@end

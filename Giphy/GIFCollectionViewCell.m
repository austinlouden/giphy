//
//  GIFCollectionViewCell.m
//  Giphy
//
//  Created by Austin Louden on 3/27/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

#import "GIFCollectionViewCell.h"

#import <PINRemoteImage/PINAnimatedImageView.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

@interface GIFCollectionViewCell()
@property (nonatomic, strong) PINAnimatedImageView *imageView;
@end

@implementation GIFCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];

        self.imageView = [[PINAnimatedImageView alloc] initWithFrame:CGRectZero];
        self.imageView.alpha = 0.0f;
        [self.contentView addSubview:self.imageView];

        // Layout the cell
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
        [self.imageView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor].active = YES;
        [self.imageView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor].active = YES;
        [self.imageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    }

    return self;
}

- (void)setGif:(GIFModel *)gif
{
    _gif = gif;

    __weak GIFCollectionViewCell *weakCell = self;
    [self.imageView pin_setImageFromURL:gif.imageURL
                             completion:^(PINRemoteImageManagerResult *result) {
                                 if (result.requestDuration > 0.25) {
                                     [UIView animateWithDuration:0.3 animations:^{
                                         weakCell.imageView.alpha = 1.0f;
                                     }];
                                 } else {
                                     weakCell.imageView.alpha = 1.0f;
                                 }
                             }];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end

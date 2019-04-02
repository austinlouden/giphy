//
//  GIFCollectionViewCell.m
//  Giphy
//
//  Created by Austin Louden on 3/27/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

#import "GIFCollectionViewCell.h"

#import <PINRemoteImage/PINAnimatedImageView.h>

@implementation GIFCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageSize = CGSizeZero;

        self.imageView = [[PINAnimatedImageView alloc] init];
        self.imageView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.imageView];

        // Layout the cell
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imageView.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor].active = YES;
        [self.imageView.leftAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leftAnchor].active = YES;
        [self.imageView.rightAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.rightAnchor].active = YES;
        [self.imageView.bottomAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor].active = YES;
    }

    return self;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    [layoutAttributes setSize:CGSizeMake(self.frame.size.width, self.imageSize.height)];
    return layoutAttributes;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end

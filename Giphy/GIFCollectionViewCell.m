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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[PINAnimatedImageView alloc] init];
        self.imageView.backgroundColor = [UIColor whiteColor];
        self.imageView.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self.contentView addSubview:self.imageView];
    }

    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end

//
//  GIFCollectionViewCell.h
//  Giphy
//
//  Created by Austin Louden on 3/27/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

@class PINAnimatedImageView;

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GIFCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) PINAnimatedImageView *imageView;
@end

NS_ASSUME_NONNULL_END

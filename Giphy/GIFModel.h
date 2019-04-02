//
//  GIFModel.h
//  Giphy
//
//  Created by Austin Louden on 4/1/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GIFModel : NSObject

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) CGSize imageSize;

- (instancetype)initWithSize:(CGSize)size url:(NSURL *)url NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

+ (void)fetchGIFsWithQuery:(NSString *)query completion:(void (^)(NSArray * _Nonnull))completion;

@end

NS_ASSUME_NONNULL_END

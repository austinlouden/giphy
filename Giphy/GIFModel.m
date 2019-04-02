//
//  GIFModel.m
//  Giphy
//
//  Created by Austin Louden on 4/1/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

#import "GIFModel.h"

#import <AFNetworking.h>

#define GIPHY_API_KEY @""

static NSInteger const kPageSize = 100;

@implementation GIFModel

- (instancetype)initWithSize:(CGSize)size url:(NSURL *)url
{
    if (self = [super init]) {
        self.imageSize = size;
        self.imageURL = url;
    }

    return self;
}

+ (void)fetchGIFsWithQuery:(NSString *)query completion:(void (^)(NSArray * _Nonnull))completion
{
    NSDictionary *parameters = @{ @"q": query, @"limit": [NSNumber numberWithInteger:kPageSize], @"api_key": GIPHY_API_KEY};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager GET:@"https://api.giphy.com/v1/gifs/search?" parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSMutableArray *data = [NSMutableArray array];
        for (NSDictionary *entry in responseObject[@"data"]) {
            CGFloat width = [entry[@"images"][@"fixed_width"][@"width"] floatValue];
            CGFloat height = [entry[@"images"][@"fixed_width"][@"height"] floatValue];
            NSURL *url = [NSURL URLWithString:entry[@"images"][@"fixed_width"][@"url"]];

            // prevents nil objects from being created.
            if (url != nil && width > 0 && height > 0) {
                [data addObject:[[GIFModel alloc] initWithSize:CGSizeMake(width, height) url:url]];
            }
        }
        
        completion(data);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end

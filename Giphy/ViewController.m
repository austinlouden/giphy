//
//  ViewController.m
//  Giphy
//
//  Created by Austin Louden on 3/27/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

#import "ViewController.h"

#import "GIFCollectionViewCell.h"

#import <AFNetworking.h>
#import <PINRemoteImage/PINAnimatedImageView.h>
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

#define GIPHY_API_KEY @""

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *images;
@end

@implementation ViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.images = [[NSMutableArray alloc] initWithArray:@[]];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];

    // Create the collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    [self.collectionView registerClass:[GIFCollectionViewCell class] forCellWithReuseIdentifier:@"GIFCell"];
    [self.collectionView setBackgroundColor:[UIColor greenColor]];
    
    [self.view addSubview:self.collectionView];
    
    [self fetchImages];
}

- (void)fetchImages
{
    NSDictionary *parameters = @{ @"q": @"ryan gosling", @"limit": @5, @"api_key": GIPHY_API_KEY};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"https://api.giphy.com/v1/gifs/search?" parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"%@", task.currentRequest.URL);
        self.images = responseObject[@"data"];
        NSLog(@"%@", self.images[0]);
        [self.collectionView reloadData];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - UICollectionView Datasource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GIFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GIFCell" forIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString:self.images[indexPath.row][@"images"][@"fixed_width"][@"url"]];
    [cell.imageView pin_setImageFromURL:url];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
}


@end

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

static CGFloat const kSearchBarHeight = 100.0;

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITextField *textField;
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
    self.view.backgroundColor = [UIColor blackColor];
    
    // Create the search bar
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    self.textField.placeholder = @"Search";
    self.textField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.textField.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:self.textField];

    // Create the collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
    layout.sectionInsetReference = UICollectionViewFlowLayoutSectionInsetFromLayoutMargins;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    self.collectionView.contentInset = UIEdgeInsetsZero;

    [self.collectionView registerClass:[GIFCollectionViewCell class] forCellWithReuseIdentifier:@"GIFCell"];
    [self.view addSubview:self.collectionView];

    // Setup search bar constraints
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textField.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.textField.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.textField.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.textField.heightAnchor constraintEqualToConstant:kSearchBarHeight].active = YES;
    
    // Setup collection view constraints
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.textField.bottomAnchor].active = YES;
    [self.collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    
    // Fetch the images
    [self fetchImages:@"ryan gosling"];
}

- (void)fetchImages:(NSString *)query
{
    NSDictionary *parameters = @{ @"q": query, @"limit": @100, @"api_key": GIPHY_API_KEY};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    __weak ViewController *weakSelf = self;
    [manager GET:@"https://api.giphy.com/v1/gifs/search?" parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        weakSelf.images = responseObject[@"data"];
        [weakSelf.collectionView.collectionViewLayout invalidateLayout];
        [weakSelf.collectionView reloadData];
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
    
    CGFloat width = [self.images[indexPath.row][@"images"][@"fixed_width"][@"width"] floatValue];
    CGFloat height = [self.images[indexPath.row][@"images"][@"fixed_width"][@"height"] floatValue];
    CGFloat aspectRatio = width / height;

    CGFloat fwidth = collectionView.frame.size.width - 20;
    cell.imageSize = CGSizeMake(fwidth, fwidth  / aspectRatio);

    [cell.imageView pin_setImageFromURL:url];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = collectionView.safeAreaLayoutGuide.layoutFrame.size.width - 40;
    return CGSizeMake(width, 100);
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self fetchImages:textField.text];
    [textField resignFirstResponder];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    return NO;
}

@end

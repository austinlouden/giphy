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
static CGFloat const kSearchBarPadding = 16.0;

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
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(kSearchBarPadding,
                                                                   self.view.safeAreaInsets.top + kSearchBarPadding,
                                                                   CGRectGetWidth(self.view.frame) - kSearchBarPadding,
                                                                   kSearchBarHeight)];
    self.textField.delegate = self;
    self.textField.placeholder = @"Search";
    self.textField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.textField.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:self.textField];

    // Create the collection view
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.estimatedItemSize = CGSizeMake(1, 1);
    
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    layout.sectionInset = UIEdgeInsetsZero;
    
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - kSearchBarHeight);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[GIFCollectionViewCell class] forCellWithReuseIdentifier:@"GIFCell"];
    [self.view addSubview:self.collectionView];
    
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
    [cell.imageView pin_setImageFromURL:url];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [self.images[indexPath.row][@"images"][@"fixed_width"][@"width"] floatValue];
    CGFloat height = [self.images[indexPath.row][@"images"][@"fixed_width"][@"height"] floatValue];
    CGFloat aspectRatio = width / height;

    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetWidth(collectionView.frame) / aspectRatio);
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

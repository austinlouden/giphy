//
//  ViewController.m
//  Giphy
//
//  Created by Austin Louden on 3/27/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

#import "ViewController.h"

#import "GIFCollectionViewCell.h"
#import "GIFModel.h"

#import <Photos/Photos.h>

static CGFloat const kSearchBarHeight = 48.0;
static CGFloat const kSearchBarLeftRightPadding = 28.0;
static CGFloat const kSearchBarTopPadding = 48.0;

static CGFloat const kCollectionViewLeftRightPadding = 16.0;

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSMutableArray<GIFModel *> *images;
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
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create the search bar
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    self.textField.placeholder = @"Search for a great GIF...";
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.returnKeyType = UIReturnKeySearch;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.textField];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    [self.collectionView registerClass:[GIFCollectionViewCell class] forCellWithReuseIdentifier:@"GIFCell"];
    [self.view addSubview:self.collectionView];

    [self setupConstraints];
    [self fetchImages:@"ryan gosling"];
}

- (void)setupConstraints
{
    // Setup search bar constraints
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textField.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:kSearchBarTopPadding].active = YES;
    [self.textField.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:kSearchBarLeftRightPadding].active = YES;
    [self.textField.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:kSearchBarLeftRightPadding].active = YES;
    [self.textField.heightAnchor constraintEqualToConstant:kSearchBarHeight].active = YES;
    
    // Setup collection view constraints
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.textField.bottomAnchor].active = YES;
    [self.collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:kCollectionViewLeftRightPadding].active = YES;
    [self.collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant: -kCollectionViewLeftRightPadding].active = YES;
}

- (void)fetchImages:(NSString *)query
{
    __weak ViewController *weakSelf = self;
    [GIFModel fetchGIFsWithQuery:query completion:^(NSArray *images) {
        [weakSelf.images removeAllObjects];
        [weakSelf.images addObjectsFromArray:images];
        [weakSelf.collectionView reloadData];
        
        if (self.images.count > 0) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
    }];
}

- (void)shareImageAtIndex:(NSInteger)index
{
    NSURL *url = self.images[index].imageURL;
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[data] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - UICollectionView Datasource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GIFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GIFCell" forIndexPath:indexPath];
    cell.gif = self.images[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GIFModel *model = [self.images objectAtIndex:indexPath.item];
    CGFloat width = 0.0;

    // Use two columns if the device is in landscape
    if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation)) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
        width = CGRectGetWidth(collectionView.frame) / 2.0  - layout.minimumInteritemSpacing;
    } else {
        width = CGRectGetWidth(collectionView.frame);
    }

    // Set the height of the item based on the image's aspect ratio
    CGFloat height = width / (model.imageSize.width / model.imageSize.height);
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self shareImageAtIndex:indexPath.item];
    } else {
        // to implement later. If the user has already denied access,
        // we can't continue to prompt. Help them go to settings to accept.
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self shareImageAtIndex:indexPath.item];
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self fetchImages:textField.text];
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    // Search when the text field changes. Debounce 1.5 seconds to prevent several searches.
    __weak typeof(self) weakSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(fetchImages:) object:nil];
    [weakSelf performSelector:@selector(fetchImages:) withObject:textField.text afterDelay:1.5];
}

#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Invalidate the layout when we switch device orientation.
    // This will ensure that sizeForItemAtIndexPath: is called again.
    [self.collectionView.collectionViewLayout invalidateLayout];
}

@end

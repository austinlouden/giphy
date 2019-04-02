# Giphy

### Setup

1. Clone or download the repository.
2. Run `pod install` inside the directory.
3. Define your Giphy API key at the top of `GIFModel.m`.
```
#define GIPHY_API_KEY @"{YOUR KEY HERE}"
```

### Features

- **GIFs are interactive.** Tapping a GIF will bring up a UIActivityViewController, where it can be saved, shared, etc.

- **Shows a single page of 100 results**. This is specified by `kPageSize` in `GIFModel.m`. Haven't implemented paging yet. 

- **The collection view layout is based on the size of the screen and its orientation.** Images scale to width of the screen with the correct aspect ratio. The app shows a single GIF per row in portrait, and switches to two columns in landscape. The key layout code is in `sizeForItemAtIndexPath`. I've implemented `viewWillTransitionToSize` to handle rotation events.

```
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
```


- **Scrolling through collection view/GIFs should be smooth.** I can't say this is always 60fps (that'd require a bit more work getting as much stuff off the main thread as possible), but things are pretty smooth. I've used PINRemoteImage to handle GIFs, which is what's used at Pinterest. PINRemoteImage decodes images off the main thread so that animation performance isn't affected. It also caches images for quick requse later. I've kept the cache sizes at their defaults, but these could be tweaked to improve performance.

- **GIFs appear as they load, and offscreen GIFs are unloaded.** When `cellForItemAtIndexPath` sets the `gif` property on the cell, we either download the image or retrieve it from the cache in `setGif:` in `GIFCollectionViewCell.m`. Images are set to nil in `prepareForReuse`, which unloads the images as cells are recycled.
```
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}
```

- **Search results are updated when the user taps search button.** I've also implemented automatic searching as the user types, which is debounced to every 1.5 seconds.
```
- (void)textFieldDidChange:(UITextField *)textField
{
    // Search when the text field changes. Debounce 1.5 seconds to prevent several searches.
    __weak typeof(self) weakSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(fetchImages:) object:nil];
    [weakSelf performSelector:@selector(fetchImages:) withObject:textField.text afterDelay:1.5];
}
```

- **The app layout supports any iOS device, including iPad, in landscape or portrait.** I've implemented a couple of  NSLayoutConstaints programmatically in `ViewController.m`.
```
[self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
[self.collectionView.topAnchor constraintEqualToAnchor:self.textField.bottomAnchor].active = YES;[self.collectionView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:kCollectionViewLeftRightPadding].active = YES;
[self.collectionView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant: -kCollectionViewLeftRightPadding].active = YES;    
```


## Screenshots

### Collection View Layout in portrait and landscape
![portrait](/Screenshots/iphone_xr_portrait.png)
![landscape](/Screenshots/iphone_xr_landscape.png)

### iPad Support
![portrait ipad](/Screenshots/ipad_air_portrait.png)
![landscape ipad](/Screenshots/ipad_air_landscape.png)

### Searching
![search](/Screenshots/search.png)

### Sharing a photo and saving to the camera roll
![activity](/Screenshots/activity.png)
![camera roll](/Screenshots/camera_roll.png)

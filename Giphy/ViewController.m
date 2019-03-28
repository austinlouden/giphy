//
//  ViewController.m
//  Giphy
//
//  Created by Austin Louden on 3/27/19.
//  Copyright © 2019 Austin Louden. All rights reserved.
//

#import "ViewController.h"

#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import <PINRemoteImage/PINAnimatedImageView.h>

@interface ViewController ()
@property (nonatomic, strong) PINAnimatedImageView *animatedImageView;
@end

@implementation ViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nil bundle:nil]) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    self.animatedImageView = [[PINAnimatedImageView alloc] init];
    self.animatedImageView.backgroundColor = [UIColor whiteColor];
    self.animatedImageView.frame = CGRectMake(0, 0, 100, 100);
    [self.view addSubview:self.animatedImageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.animatedImageView pin_setImageFromURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif"]];
}


@end

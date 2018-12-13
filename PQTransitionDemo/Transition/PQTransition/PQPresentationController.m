//
//  PQSentationController.m
//  Radiant_BLE
//
//  Created by 盘国权 on 2017/3/20.
//  Copyright © 2017年 xsn. All rights reserved.
//

#import "PQPresentationController.h"

@interface PQPresentationController ()
@property (nonatomic,strong) UIView * overlay;
@end

@implementation PQPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController{
    self =  [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    self.presentFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.8, [UIScreen mainScreen].bounds.size.height * 0.8);
    return self;
}

- (void)containerViewWillLayoutSubviews{
    self.presentedView.frame = self.presentFrame;
    [self.containerView insertSubview:self.overlay atIndex:0];
}

- (UIView *)overlay{
    if (!_overlay) {
        _overlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [_overlay addGestureRecognizer:tap];
    }
    return _overlay;
}

- (void)close{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

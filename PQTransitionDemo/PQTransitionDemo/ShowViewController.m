//
//  ShowViewController.m
//  PQTransitionDemo
//
//  Created by 盘国权 on 2018/5/25.
//  Copyright © 2018年 pgq. All rights reserved.
//

#import "ShowViewController.h"

@interface ShowViewController ()

@end

@implementation ShowViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.transition;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)closeBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:self.dismissBlock];
}

- (PQTransition *)transition{
    if(!_transition){
        _transition = [PQTransition pqTransitionWithType:(PQTransitionAnimationTypePopverSpring)];
    }
    return _transition;
}
@end

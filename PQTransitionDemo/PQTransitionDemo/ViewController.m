//
//  ViewController.m
//  PQTransitionDemo
//
//  Created by 盘国权 on 2018/5/25.
//  Copyright © 2018年 pgq. All rights reserved.
//

#import "ViewController.h"
#import "ShowViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static int showType = 0;
- (IBAction)showPopverMenuClick:(UIButton *)sender {
    ShowViewController * show = [[ShowViewController alloc] init];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat showW = 300;
    CGFloat showH = 280;
    show.transition.presentFrame = CGRectMake((screenW - showW) * 0.5, (screenH - showH) * 0.5, showW, showH);
    show.transition.type = showType;
    showType ++;
    
    [show.transition listenWillDismiss:^{
        NSLog(@"will dismiss");
    }];
    
    [show.transition listenDidDismiss:^{
        NSLog(@"did dismiss");
    }];
    [self presentViewController:show animated:true completion:nil];
}

@end

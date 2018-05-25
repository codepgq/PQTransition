//
//  ShowViewController.h
//  PQTransitionDemo
//
//  Created by 盘国权 on 2018/5/25.
//  Copyright © 2018年 pgq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQTransition.h"

@interface ShowViewController : UIViewController
@property (nonatomic,strong) PQTransition *transition;

@property (nonatomic,copy) void (^dismissBlock)(void);
@end

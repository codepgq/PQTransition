//
//  PQTransition.m
//  Radiant_BLE
//
//  Created by 盘国权 on 2017/3/20.
//  Copyright © 2017年 xsn. All rights reserved.
//

#import "PQTransition.h"
#import "PQPresentationController.h"

#define TRANSITION_H [UIScreen mainScreen].bounds.size.height
#define TRANSITION_W [UIScreen mainScreen].bounds.size.width

@interface UIView (cut)
- (UIImage *)cutWithRect:(CGSize)size cutFrame:(CGRect)cutFrame;
@end

@implementation UIView (cut)
/*
 0 0 187.5 667
 
 */

- (UIImage *)cutWithRect:(CGSize)size cutFrame:(CGRect)cutFrame{
    
    UIGraphicsBeginImageContextWithOptions(size, false, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.layer renderInContext:context];
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    UIGraphicsBeginImageContextWithOptions(cutFrame.size, false, [UIScreen mainScreen].scale);
    
    [image drawAtPoint:CGPointMake(-cutFrame.origin.x, -cutFrame.origin.y)];
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image2;
    
}

@end

@interface PQTransition()<CAAnimationDelegate>
@property (nonatomic,copy) void(^willDismissBlock)(void);
@property (nonatomic,copy) void(^didDismissBlock)(void);
@end

@implementation PQTransition

/**
 快速创建一个动画
 
 @param type 动画类型
 @return 动画
 */
+ (instancetype)pqTransitionWithType:(PQTransitionAnimationType)type{
    return [self pqTransitionWithType:type presentFrame:[UIScreen mainScreen].bounds];
}

/**
 快速创建一个动画
 
 @param type 动画类型
 @param frame 要展示的view大小
 @return 动画
 */
+ (instancetype)pqTransitionWithType:(PQTransitionAnimationType)type presentFrame:(CGRect)frame{
    return [self pqTransitionWithType:type presentFrame:[UIScreen mainScreen].bounds duration:0.5];
}

/**
 快速创建一个动画
 
 @param type 动画类型
 @param frame 要展示的view大小
 @param duration 动画时长
 @return 动画
 */
+ (instancetype)pqTransitionWithType:(PQTransitionAnimationType)type presentFrame:(CGRect)frame duration:(CGFloat)duration{
    return [self pqTransitionWithType:type presentFrame:[UIScreen mainScreen].bounds duration:0.5 overlayAlpha:0.3];
}

/**
 快速创建一个动画
 
 @param type 动画类型
 @param frame 要展示的view大小
 @param duration 动画时长
 @param overlayAlpha 遮罩透明度 0 完全透明 1 完全不透明
 @return 动画
 */
+ (instancetype)pqTransitionWithType:(PQTransitionAnimationType)type presentFrame:(CGRect)frame duration:(CGFloat)duration overlayAlpha:(CGFloat)overlayAlpha{
    PQTransition * transition = [[PQTransition alloc] init];
    transition.type = type;
    transition.presentFrame = frame;
    transition.duration = duration;
    transition.overlayAlpha = overlayAlpha;
    return transition;
}

/**
 监听消失
 
 @param completion block
 */
- (void)listenWillDismiss:(void(^)(void))completion{
    self.willDismissBlock = completion;
}

/**
 监听消失
 
 @param completion block
 */
- (void)listenDidDismiss:(void(^)(void))completion{
    self.didDismissBlock = completion;
}

- (void)didDidmiss{
    if (self.didDismissBlock) {
        self.didDismissBlock();
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.duration = 0.55;
        self.presentFrame = CGRectMake(0, 0, 200, 180);
        self.overlayAlpha = 0.3;
        self.type = PQTransitionAnimationTypePopverSpring;
        self.overlayColor = [UIColor colorWithWhite:0 alpha:_overlayAlpha];
        self.touchOverlayDismiss = true;
    }
    return self;
}

#pragma mark - 动画状态已经显示大小
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.isPresent = YES;
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.isPresent = NO;
    if (self.willDismissBlock) {
        self.willDismissBlock();
    }
    return  self;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0){
    PQPresentationController * controller = [[PQPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    controller.presentFrame = self.presentFrame;
    [controller setValue:@(self.touchOverlayDismiss) forKeyPath:@"overlay.userInteractionEnabled"];
    UIColor *color = [self.overlayColor colorWithAlphaComponent:self.overlayAlpha];
    [controller setValue:color forKeyPath:@"overlay.backgroundColor"];
    return controller;
}


#pragma mark - 动画处理相关
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return self.duration;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    
    
    switch (_type) {
        case PQTransitionAnimationTypePopverSpring:
            [self animationTypePopverSpring:transitionContext];
            break;
            
        case PQTransitionAnimationTypeTopPush:
        case PQTransitionAnimationTypeLeftPush:
        case PQTransitionAnimationTypeRightPush:
        case PQTransitionAnimationTypeBottomPush:
            [self animationTypePush:transitionContext];
            break;
            
        case PQTransitionAnimationTypeFromFrame:
            [self animationTypeFromFrame:transitionContext];
            break;
            
        case PQTransitionAnimationTypeFromFrame2:
            [self animationTypeFromFrame2:transitionContext];
            break;
            
        case PQTransitionAnimationTypeCircleOverlay:
            [self animationTypeCircleOverLay:transitionContext];
            break;
            
        case PQTransitionAnimationTypeCutHorizontal:
        case PQTransitionAnimationTypeCutVertical:
            [self animationTypeCut:transitionContext];
            break;
        case PQTransitionAnimationTypeTransfromH:
            [self animationTransfromH:transitionContext];
            break;
        default:
            NSAssert(NO, @"请选择提供的模式，OK？");
            break;
    }
    
}

#pragma mark - 动画处理方法

- (void)animationTransfromH:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    if (_isPresent) {
        UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        [[transitionContext containerView] addSubview:toView];
        toView.layer.anchorPoint = CGPointMake(0.5, 0);
        toView.transform = CGAffineTransformMakeScale(1, 0);
        
        [UIView animateWithDuration:self.duration animations:^{
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else{
        UIView * fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        [UIView animateWithDuration:self.duration animations:^{
            fromView.transform = CGAffineTransformMakeScale(1, 0.0001);
            [transitionContext containerView].subviews.firstObject.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            [self didDidmiss];
        }];
    }
}

- (void)animationTypeCut:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIView *view1 = nil;
    UIView *view2 = nil;
    
    CGAffineTransform transfrom1 = CGAffineTransformIdentity;
    CGAffineTransform transfrom2 = CGAffineTransformIdentity;
    
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    
    if (_isPresent) {
        [[transitionContext containerView] addSubview:toView];
    }
    
    
    UIView * cutView = [transitionContext containerView];
    
    if (_type == PQTransitionAnimationTypeCutVertical) {
        view1 = [[UIImageView alloc] initWithImage:[cutView cutWithRect:CGSizeMake(TRANSITION_W, TRANSITION_H) cutFrame:CGRectMake(0, 0, TRANSITION_W, TRANSITION_H * 0.5)]];
        view2 = [[UIImageView alloc] initWithImage:[cutView cutWithRect:CGSizeMake(TRANSITION_W, TRANSITION_H) cutFrame:CGRectMake(0, TRANSITION_H * 0.5, TRANSITION_W, TRANSITION_H * 0.5)]];
        CGRect frame = view2.frame;
        frame.origin.y = TRANSITION_H * 0.5;
        view2.frame = frame;
    }else{
        view1 = [[UIImageView alloc] initWithImage:[cutView cutWithRect:CGSizeMake(TRANSITION_W, TRANSITION_H) cutFrame:CGRectMake(0, 0, TRANSITION_W * 0.5, TRANSITION_H)]];
        view2 = [[UIImageView alloc] initWithImage:[cutView cutWithRect:CGSizeMake(TRANSITION_W, TRANSITION_H) cutFrame:CGRectMake(TRANSITION_W * 0.5, 0, TRANSITION_W * 0.5, TRANSITION_H)]];
        CGRect frame = view2.frame;
        frame.origin.x = TRANSITION_W * 0.5;
        view2.frame = frame;
    }
    
//    [cutView insertSubview:view1 atIndex:1];
//    [cutView insertSubview:view2 atIndex:1];

    [cutView addSubview:view1];
    [cutView addSubview:view2];
    
    
    if (self.isPresent) {
//        [toView removeFromSuperview];
        if (_type == PQTransitionAnimationTypeCutVertical) {
            transfrom1 =  CGAffineTransformMakeTranslation(0, -TRANSITION_H);
            transfrom2 =  CGAffineTransformMakeTranslation(0, TRANSITION_H * 1.5);
        }else{
            transfrom1 =  CGAffineTransformMakeTranslation(-TRANSITION_W, 0);
            transfrom2 =  CGAffineTransformMakeTranslation(TRANSITION_W, 0);
        }
        
        view1.transform = transfrom1;
        view2.transform = transfrom2;
    }
    
    if (_isPresent) {
        [transitionContext containerView].subviews.firstObject.alpha = 0;
        toView.alpha = 0;
        
    }else{
        fromView.alpha = 0;
        [transitionContext containerView].subviews.firstObject.alpha = 0;
        toView.alpha = 0;
    }
    
    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if (self.isPresent) {
            view1.transform = CGAffineTransformIdentity;
            view2.transform = CGAffineTransformIdentity;
        }else{
            if (self->_type == PQTransitionAnimationTypeCutVertical) {
                view1.transform =  CGAffineTransformMakeTranslation(0, -TRANSITION_H);
                view2.transform =  CGAffineTransformMakeTranslation(0, TRANSITION_H);
            }else{
                view1.transform =  CGAffineTransformMakeTranslation(-TRANSITION_W, 0);
                view2.transform =  CGAffineTransformMakeTranslation(TRANSITION_W, 0);
            }
            [transitionContext containerView].subviews.firstObject.alpha = 0;
        }
        
        
        
    } completion:^(BOOL finished) {
//        if (_isPresent) {
//           [cutView addSubview:toView];
//        }

    }];
    
    
    [UIView animateWithDuration:0.001  delay:self.duration  options:UIViewAnimationOptionCurveLinear animations:^{
//        [cutView addSubview:toView];
        view1.alpha = 0.001;
        view2.alpha = 0.001;
        if (self->_isPresent) {
            
            [transitionContext containerView].subviews.firstObject.alpha = 1;
            toView.alpha = 1;
        }
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [self didDidmiss];
        if (!self->_isPresent) {
            [view2 removeFromSuperview];
            [view1 removeFromSuperview];
        }
    }];
    
    
    
}

- (void)animationTypeCircleOverLay:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    
    UIView * animationView = nil;
    
    if (_isPresent) {
        UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];;
        
        UIView * containerView = [transitionContext containerView];
        [containerView addSubview:toView];
        
        animationView = toView;
    }else{
        
        UIView * fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        
        UIView * sc = [fromView snapshotViewAfterScreenUpdates:NO];
        sc.center = [transitionContext containerView].center;
        [fromView removeFromSuperview];
        
        UIView * containerView = [transitionContext containerView];
        [containerView addSubview:fromView];
        
        animationView = fromView;
    }
    
    CAShapeLayer * shapeLayer = [[CAShapeLayer alloc] init];
    animationView.layer.mask = shapeLayer;
    
    UIBezierPath * path1 = [UIBezierPath bezierPathWithOvalInRect:self.animationBeginFrame];
    
    UIBezierPath * path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.animationBeginFrame.origin.x, self.animationBeginFrame.origin.y) radius:[UIScreen mainScreen].bounds.size.height * 1.2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    shapeLayer.path = path2.CGPath;
    
    CABasicAnimation * animation = [self addAnimationFrom:(id)path1.CGPath to:(id)path2.CGPath transitionContext:transitionContext];
    if (!_isPresent) {
        animation = [self addAnimationFrom:(id)path2.CGPath to:(id)path1.CGPath transitionContext:transitionContext];
        
        [UIView animateWithDuration:self.duration animations:^{
            animationView.alpha = 0.001;
            [transitionContext containerView].subviews.firstObject.alpha = 0.001;
        } completion:^(BOOL finished) {
            [animationView removeFromSuperview];
            [self didDidmiss];
        }];
    }
    [shapeLayer addAnimation:animation forKey:@"presentAnimation"];
    
    
}

- (CABasicAnimation *)addAnimationFrom:(id)fromValue to:(id)toValue transitionContext:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = self.duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    
    [animation setValue:transitionContext forKey:@"transitionContext"];
    
    return animation;
}

- (void)animationTypeFromFrame2:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    if (self.isPresent) {
        //弹出
        
        UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        
        [[transitionContext containerView] addSubview:toView];
        toView.frame = self.animationBeginFrame;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect frame = toView.frame;
            frame.origin.x = self.presentFrame.origin.x;
            frame.origin.y = self.presentFrame.origin.y;
            toView.frame = frame;
        } completion:^(BOOL finished) {
            
            
        }];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:[self transitionDuration:transitionContext] usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            toView.frame = self.presentFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else{
        //回收
        
        UIView * fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        
        UIView * sc = [fromView snapshotViewAfterScreenUpdates:NO];
        sc.center = [transitionContext containerView].center;
        [fromView removeFromSuperview];
        
        [[transitionContext containerView] addSubview:sc];
        
        //让dismiss 动画快点结束
        [UIView animateWithDuration:[self transitionDuration:transitionContext] * 0.8 animations:^{
            CGRect frame = self.presentFrame;
            frame.size.width = self.animationBeginFrame.size.width;
            frame.size.height = self.animationBeginFrame.size.height;
            sc.frame = frame;
            sc.layer.cornerRadius = fromView.layer.cornerRadius;
            sc.clipsToBounds = fromView.clipsToBounds;
            
        } completion:^(BOOL finished) {
        }];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] * 0.8 delay:[self transitionDuration:transitionContext] * 0.8 options:UIViewAnimationOptionCurveLinear animations:^{
            sc.frame = self.animationBeginFrame;
            sc.alpha = 0.002;
            [transitionContext containerView].subviews.firstObject.alpha = 0.001;
        } completion:^(BOOL finished) {
            [sc removeFromSuperview];
            [transitionContext completeTransition:YES];
            [self didDidmiss];
        }];
    }
    
}

- (void)animationTypeFromFrame:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    if (self.isPresent) {
        //弹出
        
        UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        
        [[transitionContext containerView] addSubview:toView];
        toView.frame = self.animationBeginFrame;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            toView.frame = self.presentFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else{
        //回收
        
        UIView * fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        
        UIView * sc = [fromView snapshotViewAfterScreenUpdates:NO];
        sc.center = [transitionContext containerView].center;
        [fromView removeFromSuperview];
        
        [[transitionContext containerView] addSubview:sc];
        
        //让dismiss 动画快点结束
        [UIView animateWithDuration:[self transitionDuration:transitionContext] * 0.8 animations:^{
            sc.frame = self.animationBeginFrame;
            sc.alpha = 0.002;
            [transitionContext containerView].subviews.firstObject.alpha = 0.001;
        } completion:^(BOOL finished) {
            [sc removeFromSuperview];
            [transitionContext completeTransition:YES];
            [self didDidmiss];
        }];
    }
}

- (void)animationTypePush:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    
    CGAffineTransform transfrom =  CGAffineTransformMakeTranslation(0,-TRANSITION_H);
    
    if (_type == PQTransitionAnimationTypeBottomPush) {
        transfrom = CGAffineTransformMakeTranslation(0, TRANSITION_H);
    }else if (_type == PQTransitionAnimationTypeLeftPush) {
        transfrom = CGAffineTransformMakeTranslation(-TRANSITION_W, 0);
    }else if (_type == PQTransitionAnimationTypeRightPush) {
        transfrom = CGAffineTransformMakeTranslation(TRANSITION_W, 0);
    }
    
    if (self.isPresent) {
        //弹出
        UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        
        [[transitionContext containerView] addSubview:toView];
        
        toView.transform = transfrom;
        //        [transitionContext containerView].subviews.firstObject.alpha = 1;
        //        [transitionContext containerView].subviews.firstObject.alpha = 0;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else{
        //回收
        UIView * fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        
        UIView * sc = [fromView snapshotViewAfterScreenUpdates:NO];
        sc.center = fromView.center;
        [fromView removeFromSuperview];
        
        [[transitionContext containerView] addSubview:sc];
        //让dismiss 动画快点结束
        [UIView animateWithDuration:[self transitionDuration:transitionContext] * 0.8 animations:^{
            sc.transform = transfrom;
            sc.alpha = 0.0001;
            [transitionContext containerView].subviews.firstObject.alpha = 0;
        } completion:^(BOOL finished) {
            [sc removeFromSuperview];
            [transitionContext completeTransition:YES];
            [self didDidmiss];
        }];
    }
}

- (void)animationTypePopverSpring:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    if (self.isPresent) {
        //弹出
        
        UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        
        [[transitionContext containerView] addSubview:toView];
        toView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else{
        //回收
        
        UIView * fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
        
        UIView * sc = [fromView snapshotViewAfterScreenUpdates:NO];
        sc.center = fromView.center;
        [fromView removeFromSuperview];
        
        [[transitionContext containerView] addSubview:sc];
        
        //让dismiss 动画快点结束
        [UIView animateWithDuration:[self transitionDuration:transitionContext] * 0.8 animations:^{
            sc.transform = CGAffineTransformMakeScale(0.001, 0.001);
            sc.alpha = 0.0001;
            [transitionContext containerView].subviews.firstObject.alpha = 0;
        } completion:^(BOOL finished) {
            [sc removeFromSuperview];
            [transitionContext completeTransition:YES];
            [self didDidmiss];
        }];
    }
}



#pragma mark - CAAnimation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;{
    
    if (_isPresent) {
        id <UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
        [transitionContext completeTransition:YES];
        [transitionContext viewControllerForKey:UITransitionContextToViewKey].view.layer.mask = nil;
    }else{
        id <UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"transitionContext"];
        [transitionContext completeTransition:YES];
        [transitionContext viewControllerForKey:UITransitionContextFromViewKey].view.layer.mask = nil;
        [self didDidmiss];
    }
    
}

@end

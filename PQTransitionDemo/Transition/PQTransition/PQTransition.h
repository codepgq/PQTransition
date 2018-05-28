//
//  PQTransition.h
//  Radiant_BLE
//
//  Created by 盘国权 on 2017/3/20.
//  Copyright © 2017年 xsn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PQTransitionAnimationType) {
    ///从中间弹出来
    PQTransitionAnimationTypePopverSpring = 0,
    ///上 → 下
    PQTransitionAnimationTypeTopPush,
    ///下 → 上
    PQTransitionAnimationTypeBottomPush,
    ///左 → 右
    PQTransitionAnimationTypeLeftPush,
    ///右 → 左
    PQTransitionAnimationTypeRightPush,
    ///从某个位置开始动画
    PQTransitionAnimationTypeFromFrame,
    ///从某个位置开始 移动到指定的位置，再放大
    PQTransitionAnimationTypeFromFrame2,
    ///从当前位置开始圆形扩展
    PQTransitionAnimationTypeCircleOverlay,
    ///水平方向合并
    PQTransitionAnimationTypeCutHorizontal,
    ///垂直方向合并
    PQTransitionAnimationTypeCutVertical,
    ///高度重0 - 100% 100% - 0
    PQTransitionAnimationTypeTransfromH,
};

@interface PQTransition : NSObject<UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
///动画类型
@property (nonatomic, assign) PQTransitionAnimationType type;
///当前的状态
@property (nonatomic,assign) BOOL isPresent;
///要显示的view的大小位置
@property (nonatomic,assign) CGRect presentFrame;
///动画开始之前的大小位置 配合 'PQTransitionAnimationTypeFromFrame' 'PQTransitionAnimationTypeFromFrame2' 'PQTransitionAnimationTypeCircleOverlay' 使用
@property (nonatomic,assign) CGRect animationBeginFrame;
///动画时长 结束动画占总时长的8%
@property (nonatomic,assign) NSTimeInterval duration;
///遮罩透明贴 0 完全透明 1 黑色
@property (nonatomic,assign) CGFloat overlayAlpha;


/**
快速创建一个动画

@param type 动画类型
@return 动画
*/
+ (instancetype)pqTransitionWithType:(PQTransitionAnimationType)type;

/**
 快速创建一个动画
 
 @param type 动画类型
 @param frame 要展示的view大小
 @return 动画
 */
+ (instancetype)pqTransitionWithType:(PQTransitionAnimationType)type presentFrame:(CGRect)frame;

/**
 快速创建一个动画
 
 @param type 动画类型
 @param frame 要展示的view大小
 @param duration 动画时长
 @return 动画
 */
+ (instancetype)pqTransitionWithType:(PQTransitionAnimationType)type presentFrame:(CGRect)frame duration:(CGFloat)duration;

/**
 快速创建一个动画

 @param type 动画类型
 @param frame 要展示的view大小
 @param duration 动画时长
 @param overlayAlpha 遮罩透明度 0 完全透明 1 完全不透明
 @return 动画
 */
+ (instancetype)pqTransitionWithType:(PQTransitionAnimationType)type presentFrame:(CGRect)frame duration:(CGFloat)duration overlayAlpha:(CGFloat)overlayAlpha;


/**
 监听消失

 @param completion block
 */
- (void)listenWillDismiss:(void(^)(void))completion;

/**
 监听消失
 
 @param completion block
 */
- (void)listenDidDismiss:(void(^)(void))completion;

@end

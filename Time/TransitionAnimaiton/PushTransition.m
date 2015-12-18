//
//  PushTransition.m
//  JC_NavTransitionAnimation
//
//  Created by haobitou on 15/8/12.
//  Copyright (c) 2015年 haobitou. All rights reserved.
//

#import "PushTransition.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@implementation PushTransition

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0f;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    
    [[transitionContext containerView] addSubview:toVc.view];
    
    CGFloat startAngle =0;
    CGFloat endAngle = 360;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(fromVc.view.frame.size.width/2,fromVc.view.frame.size.height/2) radius:fromVc.view.frame.size.height * 0.2 startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];
    CAShapeLayer * circleBG = [CAShapeLayer layer];
    circleBG.path        = circlePath.CGPath;
    circleBG.lineCap     = kCALineCapRound;
    circleBG.fillColor   = [UIColor whiteColor].CGColor;
    //circleBG.lineWidth   = [_lineWidth floatValue];
    circleBG.strokeColor = [UIColor lightGrayColor].CGColor;
    circleBG.zPosition   = -1;
    toVc.view.layer.mask = circleBG;

    
    toVc.view.alpha = 0.0;
    
    
    // 1
    CGPoint center = CGPointMake(CGRectGetMidX(toVc.view.bounds), CGRectGetMidY(toVc.view.bounds));
    float finalRadius = sqrtf((center.x * center.x) + (center.y * center.y));
    UIBezierPath *circletoPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(fromVc.view.frame.size.width/2,fromVc.view.frame.size.height/2) radius:fromVc.view.frame.size.height startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];
    CGPathRef toPath = circletoPath.CGPath;
    
    // 2
    CGPathRef fromPath = circleBG.path;
    CGFloat fromLineWidth = circleBG.lineWidth;
    
    // 3
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    circleBG.lineWidth = 2 * finalRadius;
    circleBG.path = toPath;
    [CATransaction commit];
    
    // 4
    CABasicAnimation *lineWidthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineWidthAnimation.fromValue = @(fromLineWidth);
    lineWidthAnimation.toValue = @(2 * finalRadius);
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id)fromPath;
    pathAnimation.toValue = (__bridge id)toPath;
    
    // 5
    CAAnimationGroup *groupAnimation = [CAAnimationGroup new];
    groupAnimation.duration = [self transitionDuration:transitionContext];
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    groupAnimation.animations = @[pathAnimation,lineWidthAnimation];
    groupAnimation.delegate = self;
    [circleBG addAnimation:groupAnimation forKey:@"strokeWidth"];
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{

                         toVc.view.alpha = 1.0;

                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
                         fromVc.view.alpha = 1.0;
                         toVc.view.layer.mask = nil;
                     }];
}


@end

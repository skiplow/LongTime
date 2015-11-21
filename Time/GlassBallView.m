//
//  GlassBallView.m
//  Time
//
//  Created by 余坚 on 15/11/20.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "GlassBallView.h"

@interface GlassBallView()



@end

@implementation GlassBallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self startTimer];
    }
    return self;
}

-(void) stopTimer
{
    if (_theTimer) {
        [_theTimer invalidate];
        _theTimer = Nil;
    }
}

-(void) startTimer
{
    _theTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(animatePoint) userInfo:nil repeats:YES];
}

-(void) animatePoint
{
    CGSize fallSize = _PointImageView.frame.size;
    CGFloat width = (CGFloat)(arc4random() % (int)fallSize.width);
    CGFloat height = (CGFloat)(arc4random() % (int)fallSize.height);
    UIImageView * tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width, height, 5, 7)];
    tmpImageView.image = [UIImage imageNamed:@"point1"];
    [self.PointImageView addSubview:tmpImageView];
    [UIView animateWithDuration:1.2 animations:^{
        tmpImageView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [tmpImageView removeFromSuperview];
    }];
    
}
@end

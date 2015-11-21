//
//  GlassBallView.h
//  Time
//
//  Created by 余坚 on 15/11/20.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlassBallView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *PointImageView;
@property (strong, nonatomic) IBOutlet UIImageView *BackGroundImage;
@property (strong, nonatomic) NSTimer * theTimer;
-(void) startTimer;
-(void) stopTimer;
@end

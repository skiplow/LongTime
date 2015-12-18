//
//  TipMaskView.h
//  TieZi
//
//  Created by 何松泽 on 15/9/21.
//  Copyright © 2015年 HSZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"

@class TipMaskView;


@protocol TipMaskViewDelegate <NSObject>

@optional

-(void)tipMaskViewPressedButton:(TipMaskView *)tipMaskView;
-(void)tipMaskViewPressedBackground:(TipMaskView *)tipMaskView;

@end

@interface TipMaskView : UIView
{
    UIView *customMaskView;
}

-(id)initWithFrame:(CGRect)frame
           message:(NSString *)message
     andButtonRect:(CGRect)rect
         textColor:(UIColor *)textColor
       bubbleColor:(UIColor *)bubbleColor
          isCustom:(BOOL)isCustom
             image:(UIImage *)image;


@property(assign,nonatomic)CGRect rect;

@property(strong,nonatomic)id<TipMaskViewDelegate>delegate;

@property(strong,nonatomic)CMPopTipView *popTipView;

@property(strong,nonatomic)NSString *message;
@property(strong,nonatomic)UIColor  *textColor;
@property(strong,nonatomic)UIColor  *bubbleColor;
@property(strong,nonatomic)UIButton *highLightButton;
@property(strong,nonatomic)UIImage *highLightImage;

@end

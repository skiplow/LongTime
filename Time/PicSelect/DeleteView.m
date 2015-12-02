//
//  DeleteView.m
//  Time
//
//  Created by 余坚 on 15/12/2.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "DeleteView.h"

@implementation DeleteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initLayOut];
    }
    return self;
}

-(void) initLayOut
{
    self.backgroundColor = [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:0.5];
    
    _backGroundButton = [[UIButton alloc] initWithFrame:self.frame];
    _backGroundButton.backgroundColor = [UIColor clearColor];
    [_backGroundButton addTarget:self action:@selector(backGroundButtonAction) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_backGroundButton];
    
    _delButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 - 50 - 40, self.frame.size.height / 2 - 40, 80, 80)];
//    _delButton.backgroundColor = [UIColor redColor];
//    _delButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:12];
//    [_delButton setTitle:@"删除" forState:UIControlStateNormal];
//    [_delButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_delButton setBackgroundImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
    [_delButton addTarget:self action:@selector(deletButtonAction) forControlEvents:UIControlEventTouchDown];
    _delButton.layer.cornerRadius = _delButton.frame.size.width / 2;
    _delButton.layer.masksToBounds = YES;
    [self addSubview:_delButton];
    
    _notFaceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 2 + 50, self.frame.size.height / 2 - 40, 80, 80)];
//    _notFaceButton.backgroundColor = [UIColor redColor];
//    _notFaceButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:12];
//    [_notFaceButton setTitle:@"非人脸" forState:UIControlStateNormal];
//    [_notFaceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_notFaceButton setBackgroundImage:[UIImage imageNamed:@"notFace_icon.png"] forState:UIControlStateNormal];
    [_notFaceButton addTarget:self action:@selector(notFaceButtonAction) forControlEvents:UIControlEventTouchDown];
    _notFaceButton.layer.cornerRadius = _notFaceButton.frame.size.width / 2;
    _notFaceButton.layer.masksToBounds = YES;
    [self addSubview:_notFaceButton];
}

-(void) deletButtonAction
{
    if ([_delegate respondsToSelector:@selector(deleteButtonPressed)])
    {
        [_delegate deleteButtonPressed];
    }
}

-(void) notFaceButtonAction
{
    if ([_delegate respondsToSelector:@selector(notFaceButtonPressed)])
    {
        [_delegate notFaceButtonPressed];
    }
}

-(void) backGroundButtonAction
{
    if ([_delegate respondsToSelector:@selector(dismissView)])
    {
        [_delegate dismissView];
    }
}
@end

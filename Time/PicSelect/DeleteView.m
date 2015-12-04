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
    self.backgroundColor = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:0.9];
    
    _delButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _delButton.center = CGPointMake(self.frame.size.width / 4, self.frame.size.height / 2);
//    _delButton.backgroundColor = [UIColor redColor];
//    _delButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:12];
//    [_delButton setTitle:@"删除" forState:UIControlStateNormal];
//    [_delButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_delButton setBackgroundImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
    [_delButton addTarget:self action:@selector(deletButtonAction) forControlEvents:UIControlEventTouchDown];
    _delButton.layer.cornerRadius = _delButton.frame.size.width / 2;
    _delButton.layer.masksToBounds = YES;
    _delButton.hidden = TRUE; // 初始模式为功能模式 隐藏按钮
    [self addSubview:_delButton];
    
    _notFaceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _notFaceButton.center = CGPointMake(self.frame.size.width *3 / 4, self.frame.size.height / 2);
//    _notFaceButton.backgroundColor = [UIColor redColor];
//    _notFaceButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:12];
//    [_notFaceButton setTitle:@"非人脸" forState:UIControlStateNormal];
//    [_notFaceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_notFaceButton setBackgroundImage:[UIImage imageNamed:@"notFace_icon.png"] forState:UIControlStateNormal];
    [_notFaceButton addTarget:self action:@selector(notFaceButtonAction) forControlEvents:UIControlEventTouchDown];
    _notFaceButton.layer.cornerRadius = _notFaceButton.frame.size.width / 2;
    _notFaceButton.layer.masksToBounds = YES;
    _notFaceButton.hidden = TRUE; // 初始模式为功能模式 隐藏按钮
    [self addSubview:_notFaceButton];
    
    _videoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    _videoButton.center = CGPointMake(self.frame.size.width  / 4, self.frame.size.height / 2);
    _videoButton.backgroundColor = [UIColor clearColor];
    _videoButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:14];
    [_videoButton setTitle:@"合成视频" forState:UIControlStateNormal];
    [_videoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_videoButton addTarget:self action:@selector(videoButtonAction) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_videoButton];
    
    _puzzleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    _puzzleButton.center = CGPointMake(self.frame.size.width * 3/ 4, self.frame.size.height / 2);
    _puzzleButton.backgroundColor = [UIColor clearColor];
    _puzzleButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:14];
    [_puzzleButton setTitle:@"合成拼图" forState:UIControlStateNormal];
    [_puzzleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_puzzleButton addTarget:self action:@selector(puzzleButtonAction) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_puzzleButton];
}



/**
 *  @author yj, 15-12-04 10:12:46
 *
 *  设置为删除模式
 */
-(void) setDeleteMode
{
    _puzzleButton.hidden = TRUE;
    _videoButton.hidden = TRUE;
    
    _delButton.hidden = FALSE;
    _notFaceButton.hidden = FALSE;
}

/**
 *  @author yj, 15-12-04 10:12:24
 *
 *  设置为功能模式
 */
-(void) setFunctionMode
{
    _puzzleButton.hidden = FALSE;
    _videoButton.hidden = FALSE;
    
    _delButton.hidden = TRUE;
    _notFaceButton.hidden = TRUE;
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


-(void) videoButtonAction
{
    if ([_delegate respondsToSelector:@selector(videoButtonPressed)])
    {
        [_delegate videoButtonPressed];
    }
}
-(void) puzzleButtonAction
{
    if ([_delegate respondsToSelector:@selector(puzzleButtonPressed)])
    {
        [_delegate puzzleButtonPressed];
    }
}
@end

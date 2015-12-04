//
//  DeleteView.h
//  Time
//
//  Created by 余坚 on 15/12/2.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeleteViewDelegate;

@interface DeleteView : UIView
@property (strong, nonatomic) UIButton * delButton;
@property (strong, nonatomic) UIButton * notFaceButton;
@property (strong, nonatomic) UIButton * videoButton;
@property (strong, nonatomic) UIButton * puzzleButton;

@property (nonatomic, weak) id<DeleteViewDelegate> delegate;

-(void) setDeleteMode;
-(void) setFunctionMode;
@end


@protocol DeleteViewDelegate <NSObject>
@optional
-(void) deleteButtonPressed;
-(void) notFaceButtonPressed;
-(void) videoButtonPressed;
-(void) puzzleButtonPressed;
@end
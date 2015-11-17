//
//  PuzzleImageEditView.h
//  Time
//
//  Created by 余坚 on 15/11/11.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PuzzleImageEditViewDelegate;
@interface PuzzleImageEditView : UIScrollView<UIScrollViewDelegate>
@property (nonatomic, retain) UIScrollView  *contentView;
@property (nonatomic, retain) UIBezierPath *realCellArea;
@property (nonatomic, retain) UIImageView   *imageview;
@property (nonatomic, assign) id<PuzzleImageEditViewDelegate> tapDelegate;
- (void)setImageViewData:(UIImage *)imageData;
@end


@protocol PuzzleImageEditViewDelegate <NSObject>

- (void)tapWithEditView:(PuzzleImageEditView *)sender;

@end
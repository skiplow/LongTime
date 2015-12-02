//
//  PicCollectionViewCell.h
//  Time
//
//  Created by 余坚 on 15/11/16.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * cellNibName_PicCollectionViewCell = @"PicCollectionViewCell";
@interface PicCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *picImageView;
@property (strong, nonatomic) IBOutlet UIButton *delButton;
@property (strong, nonatomic) IBOutlet UIImageView *choseImageView;

@end

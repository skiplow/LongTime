//
//  ResourceCollectionViewCell.h
//  Time
//
//  Created by 余坚 on 15/12/3.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString * cellNibName_ResourceCollectionViewCell = @"ResourceCollectionViewCell";
@interface ResourceCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *showImageView;
@property (strong, nonatomic) IBOutlet UIImageView *playImageView;
@property (strong, nonatomic) NSURL * resourceUrl;
@end

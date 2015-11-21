//
//  GIFImageView.h
//  GIFImage
//
//  Created by yu jian on 15-6-24.
//  Copyright (c) 2015年  All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFImageView : UIImageView

@property (nonatomic, copy) NSString *runLoopMode;
- (void)stopAnimating;
- (void)startAnimating;

@end

//
//  FacePicker.h
//  Time
//
//  Created by 余坚 on 15/11/13.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#include<AssetsLibrary/AssetsLibrary.h> 

typedef void(^SuccessBlock)(BOOL success);
typedef void(^pickImagBlock)(UIImage * image);
typedef void(^progressBlock)(CGFloat progress);

@interface FacePicker : NSObject

+ (void)pickFaceFromPhotoAlbum:(NSString *)photoAlbumName
                       NewDate:(NSDate *) newDate
                    outPutArry:(NSMutableArray *) outPutArry
                    outPutImageArry:(NSMutableArray *) imageArry
                 animateTransitions:(BOOL)animate
                 withPicPicked:(pickImagBlock)callPickImageBlock
                  withProgress:(progressBlock)callBackProgress
                  withCallbackBlock:(SuccessBlock)callbackBlock;

@end

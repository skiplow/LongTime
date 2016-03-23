//
//  FacePicker.m
//  Time
//
//  Created by 余坚 on 15/11/13.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "FacePicker.h"

NSInteger groupCount ;
@implementation FacePicker


/**
 *  @author yj, 15-11-13 10:11:05
 *
 *  从某个相册中选择带人脸的图片
 *
 *  @param photoAlbumName
 *  @param animate
 *  @param callbackBlock
 */
+ (void)pickFaceFromPhotoAlbum:(NSString *)photoAlbumName
                       NewDate:(NSDate *) newDate
                    outPutArry:(NSMutableArray *) outPutArry
               outPutImageArry:(NSMutableArray *) imageArry
            animateTransitions:(BOOL)animate
                 withPicPicked:(pickImagBlock)callPickImageBlock
                  withProgress:(progressBlock)callBackProgress
             withCallbackBlock:(SuccessBlock)callbackBlock
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        
        @autoreleasepool {
            ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
                NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
                if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                    NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
                }else{
                    NSLog(@"相册访问失败.");
                }
                if (callbackBlock) {
                    callbackBlock(NO);
                }
            };
            
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if(callBackProgress)
                    {
                        callBackProgress((CGFloat)index / (CGFloat)groupCount);
                    }
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        
                        
                        NSDate* time = [result valueForProperty:ALAssetPropertyDate];
                        
                        NSComparisonResult Timeresult = [time compare:newDate];
                        
                        //图片宽度必须是16的倍数要不不能生产视频
                        int imagewidth = (int)result.defaultRepresentation.dimensions.width;
                        if (time != Nil && (Timeresult == NSOrderedDescending || newDate == nil) && imagewidth % 16 == 0) {
                            
                            NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                            UIImage *uiImageFull =[UIImage imageWithCGImage:result.aspectRatioThumbnail];
                            if ([self IsPicHaveFace:uiImageFull]) {
                               
       
                                [outPutArry addObject:urlstr];
                                if (callPickImageBlock) {
                                    callPickImageBlock(uiImageFull);
                                }
                                
                                //[imageArry addObject:uiImage];

                            }
                            
                        }
                        
                    }
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    
                }
                
                if (group!=nil) {
                    NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                    NSLog(@"gg:%@",g);
                    
                    groupCount = [group numberOfAssets];
                    NSString *g1=[g substringFromIndex:16] ;
                    NSArray *arr=[[NSArray alloc] init];
                    arr=[g1 componentsSeparatedByString:@","];
                    NSString *g2=[[arr objectAtIndex:0] substringFromIndex:5];
                    if ([g2 isEqualToString:photoAlbumName] || [g2 isEqualToString:@"Camera Roll"]) {
                        g2=@"相机胶卷";
                        [group enumerateAssetsUsingBlock:groupEnumerAtion];
                        
                        if (callbackBlock) {
                            callbackBlock(YES);
                        }
                        
                        NSLog(@"successed");
                    }
                    
                    
                }
                
            };
            
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
            [library enumerateGroupsWithTypes:ALAssetsGroupAll
                                   usingBlock:libraryGroupsEnumeration
                                 failureBlock:failureblock];
        }
        
    });
}


/**
 *  @author yj, 15-11-13 10:11:33
 *
 *  判断图片是否带有人脸
 *
 *  @param facePicture
 *
 *  @return
 */
+(BOOL)IsPicHaveFace:(UIImage *)facePicture

{
    CIImage* image = [CIImage imageWithCGImage:facePicture.CGImage];
    
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform,
                                           0, -facePicture.size.height);
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:image];
    
    if (features.count > 0) {
        return TRUE;
    }
    return FALSE;
}


@end

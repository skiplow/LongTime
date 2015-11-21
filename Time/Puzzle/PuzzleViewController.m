//
//  PuzzleViewController.m
//  Time
//
//  Created by 余坚 on 15/11/17.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "PuzzleViewController.h"
#import "PuzzleImageEditView.h"
#include<AssetsLibrary/AssetsLibrary.h>

#define ROW_COUNT   2

@interface PuzzleViewController ()
@property (nonatomic, strong) UIScrollView      *contentView;
@end

@implementation PuzzleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    

    
    self.contentView =  [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_contentView];
    
    _contentView.contentSize = CGSizeMake(SCREEN_WIDTH, (_imagesFrame.count / 2)*200);
    
    [self setViewByImageFrame];
    
    UIButton * puzzleButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [puzzleButton setFrame:CGRectMake(SCREEN_WIDTH / 6,100, 50,50)];
    [puzzleButton setTitle:@"拼图"forState:UIControlStateNormal];
    [puzzleButton setBackgroundColor:[UIColor blackColor]];
    [puzzleButton addTarget:self action:@selector(puzzleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:puzzleButton];
}

/**
 *  @author yj, 15-11-17 15:11:29
 *
 *  拼图按钮被按下
 *
 *  @param sender
 */
- (void)puzzleButtonPressed:(id)sender
{
    UIImage * puzzleImage = [self captureScrollView:self.contentView];
    [self saveImageToPhotos:puzzleImage];
}

/**
 *  @author yj, 15-11-17 16:11:17
 *
 *  存储图片到相册
 *
 *  @param savedImage 
 */
- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
/**
 *  @author yj, 15-11-17 15:11:31
 *
 *  设置平布布局
 */
- (void) setViewByImageFrame
{
    for (int index = 0; index < _imagesFrame.count; index++) {
        CGRect rect = CGRectZero;
        UIBezierPath *path = nil;
        
        rect = CGRectMake((index % ROW_COUNT)*(SCREEN_WIDTH / 2), (index / ROW_COUNT)*200, SCREEN_WIDTH / 2, 200);
        //NSLog(@"%lf   %lf    %lf    %lf",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
        path = [UIBezierPath bezierPathWithRect:rect];
        PuzzleImageEditView *imageView = [[PuzzleImageEditView alloc] initWithFrame:rect];
        [imageView setClipsToBounds:YES];
        [imageView setBackgroundColor:[UIColor redColor]];
        imageView.tag = index;
        imageView.realCellArea = path;
        imageView.tapDelegate = (id)self;
        [imageView setImageViewData:_imagesFrame[index]];
        //imageView.image = _imagesFrame[index];
        [_contentView addSubview:imageView];
    }
}

/**
 *  @author yj, 15-11-17 16:11:57
 *
 *  捕捉图像
 *
 *  @param scrollView
 *
 *  @return 
 */
- (UIImage *)captureScrollView:(UIScrollView *)scrollView{
    UIImage* image = nil;

    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, 1.0);

    
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    
    UIGraphicsEndImageContext();
    
    if (image != nil) {
        return image;
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

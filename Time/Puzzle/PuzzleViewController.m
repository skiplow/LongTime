//
//  PuzzleViewController.m
//  Time
//
//  Created by 余坚 on 15/11/17.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "PuzzleViewController.h"
#import "PuzzleImageEditView.h"
#import "ImageShowViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "MBProgressHUD+NJ.h"
#import "TipMaskView.h"
#include<AssetsLibrary/AssetsLibrary.h>

#define ROW_COUNT   2

@interface PuzzleViewController ()
@property (nonatomic, strong) UIScrollView      *contentView;
@end

@implementation PuzzleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([TimeUtils isDayTime]) {
        [self.view setBackgroundColor:[UIColor LTDayYellowBackGround]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor LTNightPurpleBackGround]];
    }
    self.title = @"拼图";

    
    self.contentView =  [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_contentView];
    
    _contentView.contentSize = CGSizeMake(SCREEN_WIDTH, ((_imagesFrame.count / 2) + 1) *200);
    
    [self setViewByImageFrame];
    

    
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [self.navigationController.navigationBar setBackgroundImage:[UIColor createImageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES; //从导航栏下开始计算高度
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.image = [UIImage imageNamed:@"fanhui"];
    temporaryBarButtonItem.target = self;
    temporaryBarButtonItem.action = @selector(back_main);
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 24)];
    [button setTitle:@"确认拼接" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:14]];
    [button addTarget:self action:@selector(puzzleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
}

-(void) back_main
{
    [self.navigationController popViewControllerAnimated:YES];
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
     [MBProgressHUD showMessage:@"正在合成拼图..."];
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
//    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library saveImage:savedImage toAlbum:@"LongTime" completion:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            NSLog(@"存储成功");
            // 移除HUD
            [MBProgressHUD hideHUD];
            // 提醒成功
            [MBProgressHUD showSuccess:@"合成成功"];
            
            ImageShowViewController * vc = [[ImageShowViewController alloc] init];
            vc.imageShow = savedImage;
            [self.navigationController pushViewController:vc animated:NO];
        }
    } failure:^(NSError *error) {
        NSLog(@"存储失败");
        // 移除HUD
        [MBProgressHUD hideHUD];
        // 提醒失败
        [MBProgressHUD showError:@"合成失败"];
        
    }];
}

// 指定回调方法

//- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
//{
//    NSString *msg = nil ;
//    if(error != NULL){
//        msg = @"保存图片失败" ;
//    }else{
//        msg = @"保存图片成功" ;
//    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
//                                                    message:msg
//                                                   delegate:self
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil];
//    [alert show];
//}
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
        path = [UIBezierPath bezierPathWithRect:rect];
        PuzzleImageEditView *imageView = [[PuzzleImageEditView alloc] initWithFrame:rect];
        [imageView setClipsToBounds:YES];
        [imageView setBackgroundColor:[UIColor redColor]];
        imageView.tag = index;
        imageView.realCellArea = path;
        imageView.tapDelegate = (id)self;
        [imageView setImageViewData:_imagesFrame[index]];
        [_contentView addSubview:imageView];
        if(index == 0)
        {
            /* 增加气泡提示 */
            //高亮蒙版
            CGRect rectNav = self.navigationController.navigationBar.frame;
            CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
            CGRect tmpRect = CGRectMake((index % ROW_COUNT)*(SCREEN_WIDTH / 2), (index / ROW_COUNT)*200 + rectNav.size.height + rectStatus.size.height, SCREEN_WIDTH / 2, 200);
            TipMaskView *tipMaskView = [[TipMaskView alloc]initWithFrame:tmpRect message:@"双击后可拖动图片" andButtonRect:tmpRect textColor:nil bubbleColor:nil isCustom:TRUE image:_imagesFrame[index]];
            tipMaskView.popTipView.backgroundColor = [UIColor clearColor];
            tipMaskView.popTipView.textColor = [UIColor whiteColor];
            tipMaskView.popTipView.borderColor = [UIColor clearColor];
            tipMaskView.alpha = 1.0f;
            [self.view addSubview:tipMaskView];
        }
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

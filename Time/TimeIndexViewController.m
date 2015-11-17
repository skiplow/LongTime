//
//  TimeIndexViewController.m
//  Time
//
//  Created by 余坚 on 15/11/11.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "TimeIndexViewController.h"
#import "FacePicker.h"
#import "CCProgressView.h"
#import "PicSelectViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#include<AssetsLibrary/AssetsLibrary.h> 

@interface TimeIndexViewController ()
{
    int count;
    NSDate * newDate;
}
//@property (strong, nonatomic) ALAssetsLibrary *MyAssetsLibrary;
@property (strong, nonatomic) NSMutableArray * imagesurl;
@property (strong, nonatomic) NSMutableArray * imageFrames;
@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) UIButton * showButton;
@property (strong, nonatomic)CCProgressView * circleChart;
@property (strong, nonatomic)UILabel * titleLabel;

@end

@implementation TimeIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"Time";
    count = 0;
    
    
    _showButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_showButton setFrame:CGRectMake(50, 50, 100, 30)];
    [_showButton setTitle:@"Get Images" forState:UIControlStateNormal];
    [_showButton addTarget:self action:@selector(logImages) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_showButton];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100)];
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:_imageView];
    
    
    _imageFrames = [[NSMutableArray alloc] init];
    
    _circleChart = [[CCProgressView alloc] initWithFrame:CGRectMake(30, 100, 70,70)];
    _circleChart.backgroundColor = [UIColor clearColor];
    _circleChart.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [self.view addSubview:_circleChart];
    [_circleChart setProgress:0.0 animated:YES];
    
    _titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60.0, 30.0)];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    //[_titleLabel setBackgroundColor:[UIColor redColor]];
    _titleLabel.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    //_titleLabel.text = @"11";
    [self.view addSubview:_titleLabel];
    
    [self takepic];

    
}

-(void) takepic
{
    NSArray * tmpArry = [[NSUserDefaults standardUserDefaults] arrayForKey:personal_image];
    _imagesurl = [NSMutableArray arrayWithArray:tmpArry];
    NSLog(@"count = %lu",(unsigned long)_imagesurl.count);
    if (_imagesurl.count != 0) {
        
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        NSURL *url=[NSURL URLWithString:_imagesurl[_imagesurl.count - 1]];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
            UIImage *image=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            _imageView.image=image;
            
            //NSDictionary *metadata = asset.defaultRepresentation.metadata;
            newDate = [asset valueForProperty:ALAssetPropertyDate];
            NSLog(@"time = %@",newDate);
            [self doPickImage:newDate];
            
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }];

    }
    else
    {
        _imagesurl = nil;
        _imagesurl = [[NSMutableArray alloc] init];
        [self doPickImage:nil];

    }
}


-(void) doPickImage:(NSDate*) nweDate
{
    [FacePicker pickFaceFromPhotoAlbum:@"Camera Roll" NewDate:newDate outPutArry:_imagesurl
                       outPutImageArry:_imageFrames  animateTransitions:NO withPicPicked:^(UIImage *image) {
        int x =  arc4random() % (int)SCREEN_WIDTH;
        int y = 0;
        CGPoint position = CGPointMake(x, y);
        [self doAnimationWithPic:image Time:1.0f Point:position];
        image = nil;
        
    }withProgress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_circleChart setProgress:progress animated:YES];
            CGFloat tmpProgress = progress*100;
            _titleLabel.text=[NSString stringWithFormat:@"%.0f%%",tmpProgress];
        });
        
    }  withCallbackBlock:^(BOOL success) {
        if (success == YES) {
            //本地化存储
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:_imagesurl forKey:personal_image];
            [userDefaults synchronize];
            NSLog(@"end %lu",(unsigned long)_imageFrames.count);
            
        }
        /* 页面跳转 */
        dispatch_async(dispatch_get_main_queue(), ^{
        PicSelectViewController * vc = [[PicSelectViewController alloc] init];
        vc.imagesurl = _imagesurl;
        [self.navigationController pushViewController:vc animated:YES];
             });
        
    }];
}

-(void) savePictoImageFrames
{
    for (int i = 0; i < _imagesurl.count; i++) {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        NSURL *url=[NSURL URLWithString:_imagesurl[i]];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
            UIImage *image= [[UIImage alloc] initWithCGImage:asset.defaultRepresentation.fullScreenImage];
            if (image != nil) {
                [_imageFrames addObject:image];
            }

            
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }];

    }
}

- (void)logImages
{
    
    PicSelectViewController * vc = [[PicSelectViewController alloc] init];
    vc.imagesurl = _imagesurl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)getImage:(NSString *)urlStr
{
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    NSURL *url=[NSURL URLWithString:urlStr];
    [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
        UIImage *image=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        _imageView.image=image;
        
    }failureBlock:^(NSError *error) {
        NSLog(@"error=%@",error);
    }];
}

- (void) doAnimationWithPic:(UIImage *) pic Time:(NSTimeInterval)time Point:(CGPoint)point
{
    dispatch_async(dispatch_get_main_queue(), ^{

        UIImageView * picView = [[UIImageView alloc] initWithFrame:CGRectMake(point.x, point.y, 70, 70)];
        [picView setContentMode:UIViewContentModeScaleAspectFill];
        picView.layer.cornerRadius = picView.frame.size.width / 2;
        picView.layer.masksToBounds = YES;
        picView.image = pic;
        [self.view addSubview:picView];
        
        [UIView animateWithDuration:time animations:^{
            picView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
            picView.alpha = 0.2;
        } completion:^(BOOL finished) {
            [picView removeFromSuperview];
            
        }];
    });

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

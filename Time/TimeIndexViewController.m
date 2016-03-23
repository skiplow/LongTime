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
#import "GIFImageView.h"
#import "GIFImage.h"
#import "Time_NacAnimation.h"
#import "GlassBallView.h"
#import "LeftMenuTVC.h"
#import <MediaPlayer/MediaPlayer.h>

#include<AssetsLibrary/AssetsLibrary.h> 

@interface TimeIndexViewController ()<UINavigationControllerDelegate>
{
    int count;
    NSDate * newDate;
    BOOL gifShow;
}
//@property (strong, nonatomic) ALAssetsLibrary *MyAssetsLibrary;
@property (strong, nonatomic) NSMutableArray * imagesurl;
@property (strong, nonatomic) NSMutableArray * imageFrames;
@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) UIButton * showButton;
@property (strong, nonatomic) CCProgressView * circleChart;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) GIFImageView * imageGifView;
@property (strong, nonatomic) UIButton * startButton;
@property (strong, nonatomic) UIButton * moreButton;
@property (strong, nonatomic) GlassBallView * glassBallView;
@property (strong, nonatomic) UILabel * timeLabel;

@property (strong, nonatomic) PushTransition * pushAnimation;
@property (strong, nonatomic) PopTransition  * popAnimation;
@property (strong, nonatomic) InteractionTransitionAnimation * popInteraction;
@property (strong, nonatomic) InteractiveTrasitionAnimation * popInteractive;
@end

@implementation TimeIndexViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.title = @"Time";
    count = 0;
    gifShow = FALSE;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    /* 主页布局 */
    [self showCruntTime];
    
    _glassBallView = [[[NSBundle mainBundle] loadNibNamed:@"GlassBall" owner:self options:nil] lastObject];
    [_glassBallView setFrame:CGRectMake(SCREEN_WIDTH / 2 - (177 / 2), SCREEN_HEIGHT / 2 - 190, 177, 190)];
    if ([TimeUtils isDayTime]) {
        [_glassBallView.BackGroundImage setImage:[UIImage imageNamed:@"BLQ"]];
    }
    else
    {
        [_glassBallView.BackGroundImage setImage:[UIImage imageNamed:@"BLQNight"]];

    }
    [_glassBallView startTimer];
    [self.view addSubview:_glassBallView];
    
    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 35, SCREEN_HEIGHT - 150, 70, 70)];
    if ([TimeUtils isDayTime]) {
        _startButton.backgroundColor = [UIColor LTDayRedBackGround];
    }
    else
    {
       _startButton.backgroundColor = [UIColor LTNightRedBackGround];
    }
    
    _startButton.layer.cornerRadius = _startButton.frame.size.width / 2;
    _startButton.layer.masksToBounds = YES;
    [_startButton setTitle:@"开始" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor LTDayYellowBackGround] forState:UIControlStateNormal];
    _startButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Wide" size:16];
    [_startButton addTarget:self action:@selector(startPicHandle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];


    
    
    /* 侧边栏按钮 */
//    _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 20, 20)];
//    if (isDayTime) {
//        [_moreButton setImage:[UIImage imageNamed:@"moreDay"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [_moreButton setImage:[UIImage imageNamed:@"moreNight"] forState:UIControlStateNormal];
//    }
//    [self.view addSubview:_moreButton];
    
    
    if ([TimeUtils isDayTime]) {
        [self.view setBackgroundColor:[UIColor LTDayYellowBackGround]];
    }
    else{
        [self.view setBackgroundColor:[UIColor LTNightPurpleBackGround]];
    }
    
    //[self startPicHandle];
}

-(void) showCruntTime
{
    NSDate *now = [NSDate date];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];

    int year = (int)[dateComponent year];
    int month = (int)[dateComponent month];
    int day = (int)[dateComponent day];

    NSString * timeString = [NSString stringWithFormat:@"%d 年 %d 月 %d 日",year,month,day];
    
//    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - (200 / 2), 20, 200, 30)];
//    _timeLabel.text = timeString;
//    if (isDayTime) {
//        _timeLabel.textColor = [UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f];
//    }
//    else
//    {
//        _timeLabel.textColor = [UIColor colorWithRed:142/255.0f green:44/255.0f blue:72/255.0f alpha:1.0f];
//    }
//    
//    [_timeLabel setTextAlignment:NSTextAlignmentCenter];
//     [_timeLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:16]];
//    [self.view addSubview:_timeLabel];

    self.title = timeString;
    //[self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    //[self.titleLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:16]];
    if ([TimeUtils isDayTime]) {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Wide" size:16],NSForegroundColorAttributeName:[UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f]}];
    }
    else
    {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"MarkerFelt-Wide" size:16],NSForegroundColorAttributeName:[UIColor colorWithRed:142/255.0f green:44/255.0f blue:72/255.0f alpha:1.0f]}];
    }
    
}

/**
 *  @author yj, 15-11-19 17:11:53
 *
 *  开始图片处理
 */
-(void) startPicHandle
{
//    [_glassBallView stopTimer];
//    [_glassBallView removeFromSuperview];
//    [_startButton removeFromSuperview];
//    [_timeLabel removeFromSuperview];
//    self.view.backgroundColor = [UIColor whiteColor];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_imageView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_imageView];
    
    
    _imageFrames = [[NSMutableArray alloc] init];
    
    _circleChart = [[CCProgressView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
    _circleChart.backgroundColor = [UIColor clearColor];
    //_circleChart.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [self.view addSubview:_circleChart];
    [_circleChart setProgress:0.0 animated:YES];
    
    _titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60.0, 30.0)];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    _titleLabel.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    [self.view addSubview:_titleLabel];
    
    [self takepic];
}


/**
 *  @author yj, 15-11-19 16:11:44
 *
 *  从本地相册读取图片
 */
-(void) takepic
{
    NSArray * tmpArry = [[NSUserDefaults standardUserDefaults] arrayForKey:personal_image];
    _imagesurl = [NSMutableArray arrayWithArray:tmpArry];
    NSLog(@"count = %lu",(unsigned long)_imagesurl.count);
    if (_imagesurl.count != 0) {
        NSString * tmpDateString = [[NSUserDefaults standardUserDefaults] stringForKey:last_date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        newDate = [dateFormatter dateFromString:tmpDateString];
        [self doPickImage:newDate];
        
//        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
//        NSURL *url=[NSURL URLWithString:_imagesurl[_imagesurl.count - 1]];
//        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
//            //UIImage *image=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
//            //_imageView.image=image;
//            newDate = [asset valueForProperty:ALAssetPropertyDate];
//            NSLog(@"time = %@",newDate);
//            [self doPickImage:newDate];
//            
//        }failureBlock:^(NSError *error) {
//            NSLog(@"error=%@",error);
//        }];

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
    [FacePicker pickFaceFromPhotoAlbum:@"相机胶卷" NewDate:newDate outPutArry:_imagesurl
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
            if (tmpProgress > 50.0 && tmpProgress < 60.0 && gifShow == FALSE) {
                _imageGifView = [[GIFImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 100 , SCREEN_HEIGHT - 200, 200, 150)];
                [self.view addSubview:_imageGifView];
                _imageGifView.image = [GIFImage imageNamed:@"whalespinclear.gif"];
                gifShow = TRUE;
            }
        });
        
    }  withCallbackBlock:^(BOOL success) {
        if (success == YES) {
            //本地化存储
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setValue:_imagesurl forKey:personal_image];
            NSLog(@"end %lu",(unsigned long)_imageFrames.count);
            
            
            NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *strDate = [dateFormatter stringFromDate:now];
            [userDefaults setValue:strDate forKey:last_date];
            [userDefaults synchronize];
            
        }
        /* 页面跳转 */
        dispatch_async(dispatch_get_main_queue(), ^{
            PicSelectViewController * vc = [[PicSelectViewController alloc] init];
            vc.imagesurl = _imagesurl;
            [self.popInteraction writeToViewcontroller:vc];
            [self.navigationController pushViewController:vc animated:YES];
        });
        
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
    
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
    
    UIImage *image = [UIImage imageNamed:@"bg_clear"];
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
    
    self.navigationController.delegate = self;
    gifShow = FALSE;
}

-(void)viewWillDisappear:(BOOL)animated
{
    _imageGifView.image = nil;
    [_imageGifView removeFromSuperview];
    _imageGifView = nil;
    gifShow = FALSE;
    [_circleChart removeFromSuperview];
    _circleChart = nil;
    [_titleLabel removeFromSuperview];
    _titleLabel = nil;
    [_imageView removeFromSuperview];
    _imageView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overriding methods
- (void)configureLeftMenuButton:(UIButton *)button
{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){40,40};
    button.frame = frame;
    
    [button setImage:[UIImage imageNamed:@"moreDay"] forState:UIControlStateNormal];
}

- (BOOL)deepnessForLeftMenu
{
    return YES;
}



#pragma mark - **************** Navgation delegate
/** 返回转场动画实例*/
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        return self.pushAnimation;
    }else if (operation == UINavigationControllerOperationPop){
        return self.popAnimation;
    }
    return nil;
}
/** 返回交互手势实例
-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                        interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    //    return self.popInteraction.isActing ? self.popInteraction : nil;
    return self.popInteractive.isActing ? self.popInteractive : nil;
}*/

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"willShowViewController - %@",self.popInteraction.isActing ?@"YES":@"NO");
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"didShowViewController - %@",self.popInteraction.isActing ?@"YES":@"NO");
}

-(PushTransition *)pushAnimation
{
    if (!_pushAnimation) {
        _pushAnimation = [[PushTransition alloc] init];
    }
    return _pushAnimation;
}
//-(PopTransition *)popAnimation
//{
//    if (!_popAnimation) {
//        _popAnimation = [[PopTransition alloc] init];
//    }
//    return _popAnimation;
//}
-(InteractionTransitionAnimation *)popInteraction
{
    if (!_popInteraction) {
        _popInteraction = [[InteractionTransitionAnimation alloc] init];
    }
    return _popInteraction;
}
-(InteractiveTrasitionAnimation *)popInteractive
{
    if (!_popInteractive) {
        _popInteractive = [[InteractiveTrasitionAnimation alloc] init];
    }
    return _popInteractive;
}



@end

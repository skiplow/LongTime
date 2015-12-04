//
//  ImageShowViewController.m
//  Time
//
//  Created by 余坚 on 15/12/3.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "ImageShowViewController.h"
#import "VIPhotoView.h"

@interface ImageShowViewController ()

@end

@implementation ImageShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片浏览";
    self.view.backgroundColor = [UIColor whiteColor];
    if (_imageShow) {
        VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:self.view.frame andImage:_imageShow];
        photoView.autoresizingMask = (1 << 6) -1;
        
        [self.view addSubview:photoView];
    }

}
-(void) viewWillAppear:(BOOL)animated
{

    [self.navigationController.navigationBar setBackgroundImage:[UIColor createImageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO; //从导航栏下开始计算高度
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.image = [UIImage imageNamed:@"fanhui"];
    temporaryBarButtonItem.target = self;
    temporaryBarButtonItem.action = @selector(back_main);
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;

}

-(void) back_main
{
    [self.navigationController popViewControllerAnimated:YES];
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

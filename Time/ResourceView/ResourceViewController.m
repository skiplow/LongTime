//
//  ResourceViewController.m
//  Time
//
//  Created by 余坚 on 15/11/23.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "ResourceViewController.h"
#import "ResourceCollectionViewCell.h"
#import "ImageShowViewController.h"
#import "MBProgressHUD+NJ.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>

@interface ResourceViewController ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (strong, nonatomic) NSMutableArray * images;
@property (strong, nonatomic) NSMutableArray * videoes;
@property (strong, nonatomic) NSMutableArray * imageFrames;
@property (strong, nonatomic) NSMutableArray * imageFramesType;
@property (strong, nonatomic) NSMutableArray * imageFramesUrl;
@property (strong, nonatomic) UICollectionView *myCollectionview;
@end

@implementation ResourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithRed:255/255.0f green:252/255.0f blue:231/255.0f alpha:1.0f]];
    
    _imageFrames = [[NSMutableArray alloc] init];
    _imageFramesType = [[NSMutableArray alloc] init];
    _imageFramesUrl = [[NSMutableArray alloc] init];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    if (SCREEN_WIDTH > 320) {
        [layout setItemSize:CGSizeMake(100, 100)];//设置cell的尺寸
    }
    else
    {
        [layout setItemSize:CGSizeMake(90, 90)];//设置cell的尺寸
    }

    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);//设置其边界
    _myCollectionview = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
    _myCollectionview.backgroundColor = [UIColor whiteColor];
    _myCollectionview.delegate = (id)self;
    _myCollectionview.dataSource = (id)self;
    [_myCollectionview registerClass:[ResourceCollectionViewCell class] forCellWithReuseIdentifier:cellNibName_ResourceCollectionViewCell];
    [_myCollectionview registerNib:[UINib nibWithNibName:cellNibName_ResourceCollectionViewCell bundle:Nil] forCellWithReuseIdentifier:cellNibName_ResourceCollectionViewCell];
    
    [self.view  addSubview:_myCollectionview];
    
    [self getLibraryResource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImage *image = [UIImage imageNamed:@"bg_clear"];
    [self.navigationController.navigationBar setBackgroundImage:image
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:image];
    
    

}

/**
 *  @author yj, 15-11-16 17:11:00
 *
 *  播放video
 *
 *  @param fileURL
 */
- (void)viewMovieAtUrl:(NSURL *)fileURL
{
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [playerController.view setFrame:self.view.bounds];
    [self presentMoviePlayerViewControllerAnimated:playerController];
    [playerController.moviePlayer prepareToPlay];
    [playerController.moviePlayer play];
    [self.view addSubview:playerController.view];
}

/**
 *  @author yj, 15-11-16 17:11:21
 *
 *  url需要转换为uiimage
 */
-(void) savePictoImageFrames
{
    for (int i = 0; i < _images.count; i++) {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        NSURL *url=[NSURL URLWithString:_images[i]];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
            UIImage *image= [[UIImage alloc] initWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            if (image != nil) {
                [_imageFrames addObject:image];
                [_imageFramesType addObject:@"image"];
                [_imageFramesUrl addObject:url];
                
                if (_myCollectionview) {
                    [_myCollectionview reloadData];
                }
                
            }
            
        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }];
        
    }
    for (int i = 0; i < _videoes.count; i++) {
        UIImage *image = [self thumbnailImageForVideo:_videoes[i] atTime:0];
        if (image != nil) {
            [_imageFrames addObject:image];
            [_imageFramesType addObject:@"video"];
            [_imageFramesUrl addObject:_videoes[i]];
            if (_myCollectionview) {
                [_myCollectionview reloadData];
            }
            
        }
    }
    // 移除HUD
    [MBProgressHUD hideHUD];
}



/**
 *  @author yj, 15-12-03 18:12:37
 *
 *  获取视频第一针图片
 *
 *  @param videoURL <#videoURL description#>
 *  @param time     <#time description#>
 *
 *  @return <#return value description#>
 */
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

/**
 *  @author yj, 15-12-03 11:12:39
 *
 *  获取相册内图片和视频
 */
-(void) getLibraryResource
{
    self.images = [[NSMutableArray alloc] init];
    self.videoes = [[NSMutableArray alloc] init];
    [MBProgressHUD showMessage:@"正在加载数据..."];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        @autoreleasepool {
            ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror){
                NSLog(@"相册访问失败 =%@", [myerror localizedDescription]);
                if ([myerror.localizedDescription rangeOfString:@"Global denied access"].location!=NSNotFound) {
                    NSLog(@"无法访问相册.请在'设置->定位服务'设置为打开状态.");
                }else{
                    NSLog(@"相册访问失败.");
                }
            };
            
            ALAssetsGroupEnumerationResultsBlock groupEnumerAtion = ^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result!=NULL) {
                    
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        
                        NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                        [self.images addObject:urlstr];
                    }
                    else if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
                    {
                        NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//图片的url
                        [self.videoes addObject:result.defaultRepresentation.url];
                    }
                }
            };
            
            ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration = ^(ALAssetsGroup* group, BOOL* stop){
                
                if (group == nil)
                {
                    
                }
                
                if (group!=nil) {
                    NSString *g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
                    NSLog(@"gg:%@",g);//gg:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:71
                    
                    NSString *g1=[g substringFromIndex:16 ] ;
                    NSArray *arr=[[NSArray alloc] init];
                    arr=[g1 componentsSeparatedByString:@","];
                    NSString *g2=[[arr objectAtIndex:0] substringFromIndex:5];
                    if ([g2 isEqualToString:@"LongTime"]) {
                        [group enumerateAssetsUsingBlock:groupEnumerAtion];
                        /* 显示缩略图 */
                        [self savePictoImageFrames];
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


#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imageFrames.count;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellNibName_ResourceCollectionViewCell forIndexPath:indexPath];
    cell.showImageView.image = _imageFrames[indexPath.row];
    cell.resourceUrl = _imageFramesUrl[indexPath.row];
    if([_imageFramesType[indexPath.row] isEqualToString:@"image"])
    {
        cell.playImageView.hidden = TRUE;
    }
    else if ([_imageFramesType[indexPath.row] isEqualToString:@"video"])
    {
        cell.playImageView.hidden = FALSE;
    }
    
    
    return cell;
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
     ResourceCollectionViewCell * cell = (ResourceCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if([_imageFramesType[indexPath.row] isEqualToString:@"image"])
    {       
        ImageShowViewController * vc = [[ImageShowViewController alloc] init];
        vc.imageShow = cell.showImageView.image;
        [self.navigationController pushViewController:vc animated:NO];
    }
    else if ([_imageFramesType[indexPath.row] isEqualToString:@"video"])
    {
        [self viewMovieAtUrl:cell.resourceUrl];
    }
    
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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

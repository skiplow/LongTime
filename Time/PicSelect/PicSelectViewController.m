//
//  PicSelectViewController.m
//  Time
//
//  Created by 余坚 on 15/11/13.
//  Copyright (c) 2015年 yj. All rights reserved.
//

#import "PicSelectViewController.h"
#import "PicCollectionViewCell.h"
#import "PuzzleViewController.h"
#import "CEMovieMaker.h"
#import "EGOCache.h"
#include<AssetsLibrary/AssetsLibrary.h> 
#import <MediaPlayer/MediaPlayer.h>

@interface PicSelectViewController ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

@property (strong, nonatomic) NSMutableArray * imageFrames;
@property (strong, nonatomic) UICollectionView *myPicCollectionview;
@property (nonatomic, strong) CEMovieMaker *movieMaker;
@end


@implementation PicSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"照片选择";
    
    NSArray * tmpArry = [[NSUserDefaults standardUserDefaults] arrayForKey:personal_image];
    _imagesurl = [NSMutableArray arrayWithArray:tmpArry];
    _imageFrames = [[NSMutableArray alloc] init];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    [layout setItemSize:CGSizeMake(100, 100)];//设置cell的尺寸
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);//设置其边界
    _myPicCollectionview = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
    _myPicCollectionview.backgroundColor = [UIColor whiteColor];
    _myPicCollectionview.delegate = (id)self;
    _myPicCollectionview.dataSource = (id)self;
    [_myPicCollectionview registerClass:[PicCollectionViewCell class] forCellWithReuseIdentifier:cellNibName_PicCollectionViewCell];
    [_myPicCollectionview registerNib:[UINib nibWithNibName:cellNibName_PicCollectionViewCell bundle:Nil] forCellWithReuseIdentifier:cellNibName_PicCollectionViewCell];

    [self.view  addSubview:_myPicCollectionview];
    
    [self savePictoImageFrames];
    
    
    UIButton * videoButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [videoButton setFrame:CGRectMake(SCREEN_WIDTH / 6,100, 50,50)];
    [videoButton setTitle:@"合成"forState:UIControlStateNormal];
    [videoButton setBackgroundColor:[UIColor blackColor]];
    [videoButton addTarget:self action:@selector(process:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoButton];
    
    UIButton * puzzleButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [puzzleButton setFrame:CGRectMake(SCREEN_WIDTH / 6 + 60,100, 50,50)];
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
    PuzzleViewController * vc = [[PuzzleViewController alloc] init];
    vc.imagesFrame = _imageFrames;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  @author yj, 15-11-16 17:11:22
 *
 *  image to viedo
 *
 *  @param sender
 */
- (void)process:(id)sender
{
    UIImage * frame = _imageFrames[0];
    
    NSDictionary *settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:frame.size.width andHeight:frame.size.height];
    self.movieMaker = [[CEMovieMaker alloc] initWithSettings:settings];

    
    [self.movieMaker createMovieFromImages:[_imageFrames copy] withCompletion:^(NSURL *fileURL){
        [self viewMovieAtUrl:fileURL];
        
        UISaveVideoAtPathToSavedPhotosAlbum([fileURL path], self, nil, nil);
    }];
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
    for (int i = 0; i < _imagesurl.count; i++) {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        NSURL *url=[NSURL URLWithString:_imagesurl[i]];
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset)  {
            UIImage *image= [[UIImage alloc] initWithCGImage:asset.aspectRatioThumbnail];
            if (image != nil) {
            [_imageFrames addObject:image];
                
                
                /* 缓存到本地
                [[EGOCache globalCache] setImage:image forKey:[NSString stringWithFormat:@"EGOImageLoader-%d",i] withTimeoutInterval:24*60*60];*/
                if (_myPicCollectionview) {
                    [_myPicCollectionview reloadData];
                }

            }

        }failureBlock:^(NSError *error) {
            NSLog(@"error=%@",error);
        }];
        
    }
}

/**
 *  @author yj, 15-11-17 14:11:47
 *
 *  删除button点击事件
 *
 *  @param sender
 */
-(void) deletButton:(id)sender
{
    UIButton * tmpButton = sender;
    NSInteger index = tmpButton.tag;
    NSLog(@" index = %ld",(long)index);
    [_imageFrames removeObjectAtIndex:index];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_myPicCollectionview deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [_myPicCollectionview reloadSections:indexSet];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    PicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellNibName_PicCollectionViewCell forIndexPath:indexPath];


    cell.picImageView.image = _imageFrames[indexPath.row];
    cell.picImageView.backgroundColor = [UIColor blackColor];
    [cell.delButton addTarget:self action:@selector(deletButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.delButton.tag = indexPath.row;
    cell.delButton.hidden = TRUE;
    
    return cell;
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PicCollectionViewCell * cell = (PicCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.delButton.hidden) {
        cell.delButton.hidden = FALSE;
        cell.picImageView.alpha = 0.5;
    }
    else
    {
        cell.delButton.hidden = TRUE;
        cell.picImageView.alpha = 1.0;

    }

}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end

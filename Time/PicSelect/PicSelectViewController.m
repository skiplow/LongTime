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
#import "DeleteView.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#include<AssetsLibrary/AssetsLibrary.h> 
#import <MediaPlayer/MediaPlayer.h>

@interface PicSelectViewController ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,DeleteViewDelegate>
{
    NSInteger deleteIndex;
    NSInteger choseType;  // 0为单选状态  1为多选状态
}

@property (strong, nonatomic) NSMutableArray * imageFrames;
@property (strong, nonatomic) NSMutableArray * imageChose;
@property (strong, nonatomic) UICollectionView *myPicCollectionview;
@property (nonatomic, strong) CEMovieMaker *movieMaker;
@property (nonatomic, strong) DeleteView *deleteView;
@property (nonatomic, strong) UIButton * videoButton;
@property (nonatomic, strong) UIButton * puzzleButton;
@property (nonatomic, strong) UIButton * choseDelButton;
@property (nonatomic, strong) UIButton * choseNotFaceeButton;
@end


@implementation PicSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"照片选择";
    deleteIndex = 0;
    NSArray * tmpArry = [[NSUserDefaults standardUserDefaults] arrayForKey:personal_image];
    _imagesurl = [NSMutableArray arrayWithArray:tmpArry];
    _imageFrames = [[NSMutableArray alloc] init];
    _imageChose = [[NSMutableArray alloc] init];
    choseType = 0;
    
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
    
    
    _videoButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_videoButton setFrame:CGRectMake(SCREEN_WIDTH / 2 - 50 - 80,SCREEN_HEIGHT - 100, 80,80)];
    [_videoButton setTitle:@"合成"forState:UIControlStateNormal];
    [_videoButton setBackgroundColor:[UIColor colorWithRed:255/255.0f green:252/255.0f blue:231/255.0f alpha:1.0f]];
    _videoButton.layer.cornerRadius = _videoButton.frame.size.width / 2;
    _videoButton.layer.masksToBounds = YES;
    [_videoButton addTarget:self action:@selector(process:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_videoButton];
    
    _puzzleButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_puzzleButton setFrame:CGRectMake(SCREEN_WIDTH / 2 + 50,SCREEN_HEIGHT - 100, 80,80)];
    [_puzzleButton setTitle:@"拼图"forState:UIControlStateNormal];
    [_puzzleButton setBackgroundColor:[UIColor colorWithRed:255/255.0f green:252/255.0f blue:231/255.0f alpha:1.0f]];
    _puzzleButton.layer.cornerRadius = _puzzleButton.frame.size.width / 2;
    _puzzleButton.layer.masksToBounds = YES;
    [_puzzleButton addTarget:self action:@selector(puzzleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_puzzleButton];


}



-(void) viewWillAppear:(BOOL)animated
{
    
//    UIImage *image = [UIImage imageNamed:@"bg_clear"];
//    [self.navigationController.navigationBar setBackgroundImage:image
//                                                  forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:image];
//    [self.navigationController.navigationBar setBackgroundImage:[UIColor createImageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.image = [UIImage imageNamed:@"fanhui"];
    temporaryBarButtonItem.target = self;
    temporaryBarButtonItem.action = @selector(back_main);
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 24)];
    [button setTitle:@"选择" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:14]];
    [button addTarget:self action:@selector(multipleChoice) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
}

-(void) back_main
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  @author yj, 15-12-02 15:12:17
 *
 *  选择按钮按下
 */
-(void) multipleChoice
{
    _videoButton.hidden = TRUE;
    _puzzleButton.hidden = TRUE;
    choseType = 1;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 24)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:14]];
    [button addTarget:self action:@selector(cancleMultipleChoice) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    
    /* 布局删除按钮 及 非人脸按钮 */
    _choseDelButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_choseDelButton setFrame:CGRectMake(SCREEN_WIDTH / 2 - 50 - 70,SCREEN_HEIGHT - 100, 70,70)];
    [_choseDelButton setBackgroundImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
    [_choseDelButton addTarget:self action:@selector(choseDelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_choseDelButton];
    
    _choseNotFaceeButton =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_choseNotFaceeButton setFrame:CGRectMake(SCREEN_WIDTH / 2 + 50,SCREEN_HEIGHT - 100, 70,70)];
    [_choseNotFaceeButton setBackgroundImage:[UIImage imageNamed:@"notFace_icon.png"] forState:UIControlStateNormal];
    [_choseNotFaceeButton addTarget:self action:@selector(choseNotFaceeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_choseNotFaceeButton];
}

/**
 *  @author yj, 15-12-02 15:12:19
 *
 *  多选情况下按下删除键
 */
-(void) choseDelButtonPressed
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (NSString * tmpString in _imageChose) {
        NSInteger index = [tmpString integerValue];
        UIImage * frame = _imageFrames[index];
        [tmpArray addObject:frame];
    }
    [_imageFrames removeObjectsInArray:tmpArray];

    [_myPicCollectionview reloadData];
    
    [_imageChose removeAllObjects];
    
    [self cancleMultipleChoice];
}

/**
 *  @author yj, 15-12-02 15:12:39
 *
 *  多选情况下按下非人脸键
 */
-(void) choseNotFaceeButtonPressed
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (NSString * tmpString in _imageChose) {
        NSInteger index = [tmpString integerValue];
        UIImage * frame = _imageFrames[index];
        [tmpArray addObject:frame];
    }
    [_imageFrames removeObjectsInArray:tmpArray];
    
    [tmpArray removeAllObjects];
    for (NSString * tmpString in _imageChose) {
        NSInteger index = [tmpString integerValue];
        NSString * frame = _imagesurl[index];
        [tmpArray addObject:frame];
    }
    [_imagesurl removeObjectsInArray:tmpArray];
    
    [_myPicCollectionview reloadData];
    
    //本地化存储
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:_imagesurl forKey:personal_image];
    [userDefaults synchronize];
    
    [_imageChose removeAllObjects];
    [self cancleMultipleChoice];
}

/**
 *  @author yj, 15-12-02 15:12:46
 *
 *  取消按钮按下
 */
-(void) cancleMultipleChoice
{
    _videoButton.hidden = FALSE;
    _puzzleButton.hidden = FALSE;
    choseType = 0;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 24)];
    [button setTitle:@"选择" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:14]];
    [button addTarget:self action:@selector(multipleChoice) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    /* 清空数组 */
    [_imageChose removeAllObjects];
    /* 重新加载 则所有选择view全部hide */
    [_myPicCollectionview reloadData];
    
    [_choseDelButton removeFromSuperview];
    [_choseNotFaceeButton removeFromSuperview];
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
    [self.navigationController pushViewController:vc animated:NO];
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
        
        //UISaveVideoAtPathToSavedPhotosAlbum([fileURL path], self, nil, nil);
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library saveVideo:fileURL toAlbum:@"LongTime" completion:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                NSLog(@"存储视频成功");
                
            }
        } failure:^(NSError *error) {
            NSLog(@"存储ship失败");
            
        }];

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
    deleteIndex = tmpButton.tag;
    
    if (choseType == 0) {
        _deleteView = [[DeleteView alloc] initWithFrame:self.view.frame];
        _deleteView.delegate = self;
        [self.view addSubview:_deleteView];
    }
    else
    {
        if (choseType == 1) {
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:0];
            PicCollectionViewCell * cell = (PicCollectionViewCell *)[_myPicCollectionview cellForItemAtIndexPath:indexPath];
            if (cell.choseImageView.hidden) {
                cell.choseImageView.hidden = FALSE;
                [_imageChose addObject:[NSString stringWithFormat:@"%ld",(long)deleteIndex]];
            }
            else
            {
                cell.choseImageView.hidden = TRUE;
                [_imageChose removeObject:[NSString stringWithFormat:@"%ld",(long)deleteIndex]];
                
            }
        }
    }

    
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
    //cell.delButton.hidden = TRUE;
    cell.choseImageView.hidden = TRUE;
    
    return cell;
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    PicCollectionViewCell * cell = (PicCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    if (cell.delButton.hidden) {
//        cell.delButton.hidden = FALSE;
//        cell.picImageView.alpha = 0.5;
//    }
//    else
//    {
//        cell.delButton.hidden = TRUE;
//        cell.picImageView.alpha = 1.0;
//
//    }


}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark --DeleteViewDelegate
-(void) deleteButtonPressed
{
    [_imageFrames removeObjectAtIndex:deleteIndex];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:0];
    [_myPicCollectionview deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [_myPicCollectionview reloadSections:indexSet];

    [_deleteView removeFromSuperview];
}

-(void) notFaceButtonPressed
{
    [_imageFrames removeObjectAtIndex:deleteIndex];
    [_imagesurl removeObjectAtIndex:deleteIndex];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:0];
    [_myPicCollectionview deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [_myPicCollectionview reloadSections:indexSet];
    
    //本地化存储
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:_imagesurl forKey:personal_image];
    [userDefaults synchronize];
    
    [_deleteView removeFromSuperview];
}

-(void) dismissView
{
    [_deleteView removeFromSuperview];
}

@end

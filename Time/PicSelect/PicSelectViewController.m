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
#import "ResourceInfo.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#include<AssetsLibrary/AssetsLibrary.h> 
#import <MediaPlayer/MediaPlayer.h>

@interface PicSelectViewController ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,DeleteViewDelegate,UIActionSheetDelegate>
{
    NSInteger deleteIndex;
    NSInteger choseType;  // 0为单选状态  1为多选状态
}

@property (strong, nonatomic) NSMutableArray * imageFrames;
@property (strong, nonatomic) NSMutableArray * imageChose;
@property (strong, nonatomic) NSMutableArray * resourceInfoArray;
@property (strong, nonatomic) UICollectionView *myPicCollectionview;
@property (nonatomic, strong) CEMovieMaker *movieMaker;
@property (nonatomic, strong) DeleteView *deleteView;
@property (nonatomic, strong) UIButton * videoButton;
@property (nonatomic, strong) UIButton * puzzleButton;
@property (nonatomic, strong) UIButton * choseDelButton;
@property (nonatomic, strong) UIButton * choseNotFaceeButton;
@property (nonatomic, strong) UIButton * backGroundButton;
@property (nonatomic, strong) UIButton * timeChoseButton;
@property (nonatomic, strong) UIView * choseView;
@property (nonatomic, strong) UILabel * timeNameLabel;
@end


@implementation PicSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //self.title = @"照片选择";
    deleteIndex = 0;
    NSArray * tmpArry = [[NSUserDefaults standardUserDefaults] arrayForKey:personal_image];
    _imagesurl = [NSMutableArray arrayWithArray:tmpArry];
    _imageFrames = [[NSMutableArray alloc] init];
    _imageChose = [[NSMutableArray alloc] init];
    _resourceInfoArray = [[NSMutableArray alloc] init];

    choseType = 0;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    [layout setItemSize:CGSizeMake(100, 100)];//设置cell的尺寸
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);//设置其边界
    _myPicCollectionview = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT - 44) collectionViewLayout:layout];
    _myPicCollectionview.backgroundColor = [UIColor whiteColor];
    _myPicCollectionview.delegate = (id)self;
    _myPicCollectionview.dataSource = (id)self;
    [_myPicCollectionview registerClass:[PicCollectionViewCell class] forCellWithReuseIdentifier:cellNibName_PicCollectionViewCell];
    [_myPicCollectionview registerNib:[UINib nibWithNibName:cellNibName_PicCollectionViewCell bundle:Nil] forCellWithReuseIdentifier:cellNibName_PicCollectionViewCell];

    [self.view  addSubview:_myPicCollectionview];
    
    [self savePictoImageFrames];
    
    _deleteView = [[DeleteView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44)];
    _deleteView.delegate = self;
    [self.view addSubview:_deleteView];

}

-(void) viewWillDisappear:(BOOL)animated
{
    [self changeImageUrlByResourceInfoArry];
    //本地化存储
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:_imagesurl forKey:personal_image];
    [userDefaults synchronize];
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
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 24)];
    [button setTitle:@"选择" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:14]];
    [button addTarget:self action:@selector(multipleChoice) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;

    UIView * chosetTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    _timeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    _timeNameLabel.text = @"全部";
    [_timeNameLabel setTextColor:[UIColor colorWithRed:234/255.0f green:71/255.0f blue:79/255.0f alpha:1.0f]];
    [_timeNameLabel setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:16]];
    _timeNameLabel.textAlignment = NSTextAlignmentCenter;
    [chosetTitleView addSubview:_timeNameLabel];
    
    _timeChoseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    [_timeChoseButton addTarget:self action:@selector(timeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [chosetTitleView addSubview:_timeChoseButton];
    
    UIImageView * tmpxiaLaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 10, 20, 20)];
    tmpxiaLaImageView.image = [UIImage imageNamed:@"xiala"];
    [chosetTitleView addSubview:tmpxiaLaImageView];
    
    self.navigationItem.titleView = chosetTitleView;
}

-(void) back_main
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  @author yj, 15-12-04 15:12:43
 *
 *  时间选择按钮被按下
 */
-(void) timeButtonPressed
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"近一个月",@"近两个月",@"近三个月",@"近半年",@"全部",nil];
    [actionSheet showInView:self.view];
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
    
    [_deleteView setDeleteMode];
    
}

/**
 *  @author yj, 15-12-02 15:12:19
 *
 *  多选情况下按下删除键
 */
-(void) choseDelButtonPressedMultiple
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
-(void) choseNotFaceeButtonPressedMultiple
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (NSString * tmpString in _imageChose) {
        NSInteger index = [tmpString integerValue];
        UIImage * frame = _imageFrames[index];
        ResourceInfo * f = [self findResourceInfoByImage:frame];
        [_resourceInfoArray removeObject:f];
        [tmpArray addObject:frame];
    }
    [_imageFrames removeObjectsInArray:tmpArray];
//    
//    [tmpArray removeAllObjects];
//    for (NSString * tmpString in _imageChose) {
//        NSInteger index = [tmpString integerValue];
//        NSString * frame = _imagesurl[index];
//        [tmpArray addObject:frame];
//    }
//    [_imagesurl removeObjectsInArray:tmpArray];
//    
//    //本地化存储
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setValue:_imagesurl forKey:personal_image];
//    [userDefaults synchronize];
    
    [_myPicCollectionview reloadData];
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
    
    [_deleteView setFunctionMode];
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
            NSDate* time = [asset valueForProperty:ALAssetPropertyDate];
            if (image != nil) {
                [_imageFrames addObject:image];
                ResourceInfo * tmpResourceInfo = [[ResourceInfo alloc] init];
                tmpResourceInfo.image = image;
                tmpResourceInfo.time = time;
                tmpResourceInfo.url = url;
                [_resourceInfoArray addObject:tmpResourceInfo];
                
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
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:0];
    PicCollectionViewCell * cell = (PicCollectionViewCell *)[_myPicCollectionview cellForItemAtIndexPath:indexPath];
    
    if (choseType == 0) {
        _backGroundButton = [[UIButton alloc] initWithFrame:_myPicCollectionview.frame];
        _backGroundButton.backgroundColor = [UIColor colorWithRed:0.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:0.8];
        [_backGroundButton addTarget:self action:@selector(backGroundPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backGroundButton];
        UIImage * tmpImage = cell.picImageView.image;
        
        UIImageView * tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        tmpImageView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
        tmpImageView.image = tmpImage;
        tmpImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_backGroundButton addSubview:tmpImageView];
        
        
        [_deleteView setDeleteMode];
    }
    else if(choseType == 1)
    {

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

-(void) backGroundPressed:(id)sender
{
    [_deleteView setFunctionMode];
    [sender removeFromSuperview];
}

/**
 *  @author yj, 15-12-04 17:12:28
 *
 *  通过ResourceInfoArry重新填充_imagesurl数组
 */
-(void) changeImageUrlByResourceInfoArry
{
    [_imagesurl removeAllObjects];
    for (ResourceInfo * f in _resourceInfoArray) {
        [_imagesurl addObject:[NSString stringWithFormat:@"%@",f.url]];
    }
}

/**
 *  @author yj, 15-12-04 17:12:06
 *
 *  通过image查找ResourceInfo
 *
 *  @param image
 *
 *  @return
 */
-(ResourceInfo *) findResourceInfoByImage:(UIImage *)image
{
    ResourceInfo * returnInfo = nil;
    for (ResourceInfo * f in _resourceInfoArray) {
        if ([f.image isEqual:image]) {
            returnInfo = f;
            break;
        }
    }
    return returnInfo;
}

/**
 *  @author yj, 15-12-04 17:12:41
 *
 *  取出入参时间点后的所有图片信息
 *
 *  @param time 时间点
 */
-(void) imageInfoAfterDate:(NSDate *)time
{
    //清空数组
    [_imageFrames removeAllObjects];
    if (time == nil)   //nil时为全部图片
    {
        for (ResourceInfo * f in _resourceInfoArray) {
            [_imageFrames addObject:f.image];
        }
    }
    else
    {
        for (ResourceInfo * f in _resourceInfoArray) {
            NSComparisonResult Timeresult = [f.time compare:time];
            if (Timeresult == NSOrderedDescending) //如果比入参时间大
            {
                [_imageFrames addObject:f.image];
            }
        }
    }
    [_myPicCollectionview reloadData];
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



}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark --DeleteViewDelegate
-(void) deleteButtonPressed
{
    if (choseType == 0) {
        [_imageFrames removeObjectAtIndex:deleteIndex];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:0];
        [_myPicCollectionview deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [_myPicCollectionview reloadSections:indexSet];
        [_backGroundButton removeFromSuperview];
    }
    else if(choseType == 1)
    {
        [self choseDelButtonPressedMultiple];
    }


    [_deleteView setFunctionMode];
}

-(void) notFaceButtonPressed
{
    if (choseType == 0) {
        UIImage * tmpImage = _imageFrames[deleteIndex];
        ResourceInfo * f = [self findResourceInfoByImage:tmpImage];
        [_resourceInfoArray removeObject:f];
        [_imageFrames removeObjectAtIndex:deleteIndex];
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deleteIndex inSection:0];
        [_myPicCollectionview deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [_myPicCollectionview reloadSections:indexSet];
        [_backGroundButton removeFromSuperview];
        
//        [_imagesurl removeObjectAtIndex:deleteIndex];
//        //本地化存储
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        [userDefaults setValue:_imagesurl forKey:personal_image];
//        [userDefaults synchronize];
    }
    else if (choseType == 1)
    {
        [self choseNotFaceeButtonPressedMultiple];
    }

    
    [_deleteView setFunctionMode];
}

-(void) videoButtonPressed
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
-(void) puzzleButtonPressed
{
    PuzzleViewController * vc = [[PuzzleViewController alloc] init];
    vc.imagesFrame = _imageFrames;
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex) {
        case 0:  //近一个月
        {
            NSDate *now = [NSDate date];
            NSLog(@"now = %@",now);
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeInterval time = 30 * 24 * 60 * 60;//一个月的秒数
            NSDate * lastDate = [now dateByAddingTimeInterval:-time];
            NSLog(@"lastDate = %@",lastDate);
            [self imageInfoAfterDate:lastDate];
            _timeNameLabel.text =[actionSheet buttonTitleAtIndex:buttonIndex];
        }
            break;
            
        case 1:  //近两个月
        {
            NSDate *now = [NSDate date];
            NSLog(@"now = %@",now);
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeInterval time = 30 * 2 * 24 * 60 * 60;//两个月的秒数
            NSDate * lastDate = [now dateByAddingTimeInterval:-time];
            NSLog(@"lastDate = %@",lastDate);
            [self imageInfoAfterDate:lastDate];
            _timeNameLabel.text =[actionSheet buttonTitleAtIndex:buttonIndex];
        }
            break;
        case 2:  //近三个月
        {
            NSDate *now = [NSDate date];
            NSLog(@"now = %@",now);
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeInterval time = 30 * 3 * 24 * 60 * 60;//三个月的秒数
            NSDate * lastDate = [now dateByAddingTimeInterval:-time];
            NSLog(@"lastDate = %@",lastDate);
            [self imageInfoAfterDate:lastDate];
            _timeNameLabel.text =[actionSheet buttonTitleAtIndex:buttonIndex];
        }
            break;
        case 3:  //近半年
        {
            NSDate *now = [NSDate date];
            NSLog(@"now = %@",now);
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSTimeInterval time = 30 * 6 * 24 * 60 * 60;//半年的秒数
            NSDate * lastDate = [now dateByAddingTimeInterval:-time];
            NSLog(@"lastDate = %@",lastDate);
            [self imageInfoAfterDate:lastDate];
            _timeNameLabel.text =[actionSheet buttonTitleAtIndex:buttonIndex];
        }
            break;
        case 4:  //全部
        {
            [self imageInfoAfterDate:nil];
            _timeNameLabel.text =[actionSheet buttonTitleAtIndex:buttonIndex];
        }
            break;
            
        default:
            break;
    }
}

@end

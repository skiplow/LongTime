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
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "CEMovieMaker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>





@interface ResourceViewController ()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
{
        NSMutableArray * audioMixParams;
}
@property (strong, nonatomic) NSMutableArray * images;
@property (strong, nonatomic) NSMutableArray * videoes;
@property (strong, nonatomic) NSMutableArray * imageFrames;
@property (strong, nonatomic) NSMutableArray * imageFramesType;
@property (strong, nonatomic) NSMutableArray * imageFramesUrl;
@property (strong, nonatomic) UICollectionView *myCollectionview;

@property (nonatomic, strong) NSURL * mixURL;
@property (nonatomic, strong) NSURL * theEndVideoURL;
@end

@implementation ResourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([TimeUtils isDayTime]) {
        [self.view setBackgroundColor:[UIColor LTDayYellowBackGround]];
    }
    else
    {
        [self.view setBackgroundColor:[UIColor LTNightPurpleBackGround]];
    }
    
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
                        NSString *urlstr=[NSString stringWithFormat:@"%@",result.defaultRepresentation.url];//视频的url
                        [self.videoes addObject:result.defaultRepresentation.url];
                        //[self addmusic:result.defaultRepresentation.url];
                        [self mergeAudio:result.defaultRepresentation.url];
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

-(void)mergeAudio:(NSURL *)videoPath
{
    AVURLAsset* videoAsset;
    AVURLAsset* audioAsset;
    //AVURLAsset* audioAssetBackGround;
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
//    //声音采集
//    audioAssetBackGround =[[AVURLAsset alloc] initWithURL:videoPath options:nil];
//    CMTimeRange audio_timeRangeBackGround =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);//声音长度截取范围==视频长度
//    AVMutableCompositionTrack * c_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    [c_compositionAudioTrack insertTimeRange:audio_timeRangeBackGround ofTrack:[[audioAssetBackGround tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    NSURL *video_url = videoPath;
    videoAsset = [[AVURLAsset alloc]initWithURL:video_url options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"warm-interlude" ofType:@"mp3"]] options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    

    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"dub.mov"]];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]){
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    }
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         dispatch_async(dispatch_get_main_queue(), ^{
             // Do export finish stuff
             NSURL*url = [NSURL fileURLWithPath:outputFilePath];
             [self viewMovieAtUrl:url];
         });
     }];
}
//抽取原视频的音频与需要的音乐混合
-(void)addmusic:(NSURL *) videoUrl
{
    AVMutableComposition *composition =[AVMutableComposition composition];
    audioMixParams =[[NSMutableArray alloc] initWithObjects:nil];
    
    //录制的视频
    NSURL *video_inputFileUrl = videoUrl;
    AVURLAsset *songAsset =[AVURLAsset URLAssetWithURL:video_inputFileUrl options:nil];
    CMTime startTime =CMTimeMakeWithSeconds(0,songAsset.duration.timescale);
    CMTime trackDuration =songAsset.duration;
    
    //获取视频中的音频素材
    [self setUpAndAddAudioAtPath:video_inputFileUrl toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(14*44100,44100)];
    
    //本地要插入的音乐
    NSString *bundleDirectory =[[NSBundle mainBundle] bundlePath];
    NSString *path = [bundleDirectory stringByAppendingPathComponent:@"warm-interlude.mp3"];
    NSURL *assetURL2 =[NSURL fileURLWithPath:path];
    //获取设置完的本地音乐素材
    [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition start:startTime dura:trackDuration offset:CMTimeMake(0,44100)];
    
    //创建一个可变的音频混合
    AVMutableAudioMix *audioMix =[AVMutableAudioMix audioMix];
    audioMix.inputParameters =[NSArray arrayWithArray:audioMixParams];//从数组里取出处理后的音频轨道参数
    
    //创建一个输出
    AVAssetExportSession *exporter =[[AVAssetExportSession alloc]
                                     initWithAsset:composition
                                     presetName:AVAssetExportPresetAppleM4A];
    exporter.audioMix = audioMix;
    exporter.outputFileType=@"com.apple.m4a-audio";
    NSString* fileName =[NSString stringWithFormat:@"%@.mov",@"overMix"];
    //输出路径
    NSString *exportFile =[NSString stringWithFormat:@"%@/%@",[self getLibarayPath], fileName];
    
    if([[NSFileManager defaultManager]fileExistsAtPath:exportFile]) {
        [[NSFileManager defaultManager]removeItemAtPath:exportFile error:nil];
    }
    NSLog(@"是否在主线程1%d",[NSThread isMainThread]);
    NSLog(@"输出路径===%@",exportFile);
    
    NSURL *exportURL =[NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    self.mixURL =exportURL;

    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus =(int)exporter.status;
        switch (exportStatus){
            caseAVAssetExportSessionStatusFailed:{
                NSError *exportError =exporter.error;
                NSLog(@"错误，信息: %@", exportError);
                break;
            }
            caseAVAssetExportSessionStatusCompleted:{
                NSLog(@"是否在主线程2%d",[NSThread isMainThread]);
                NSLog(@"成功");
                //最终混合
                [self theVideoWithMixMusic:videoUrl];
                break;
            }
        }
    }];
    
}

//最终音频和视频混合
-(void)theVideoWithMixMusic:(NSURL *)videoUrl
{
    NSError *error =nil;
    NSFileManager *fileMgr =[NSFileManager defaultManager];
    NSString *documentsDirectory =[NSHomeDirectory()
                                   stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath =[documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
    if ([fileMgr removeItemAtPath:videoOutputPath error:&error]!=YES) {
        NSLog(@"无法删除文件，错误信息：%@",[error localizedDescription]);
    }
    
    //声音来源路径（最终混合的音频）
    NSURL   *audio_inputFileUrl =self.mixURL;
    
    //视频来源路径
    NSURL   *video_inputFileUrl = videoUrl;
    
    //最终合成输出路径
    NSString *outputFilePath =[documentsDirectory stringByAppendingPathComponent:@"final_video.mp4"];
    NSURL   *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    if([[NSFileManager defaultManager]fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager]removeItemAtPath:outputFilePath error:nil];
    
    CMTime nextClipStartTime =kCMTimeZero;
    
    //创建可变的音频视频组合
    AVMutableComposition* mixComposition =[AVMutableComposition composition];
    
    
    //视频采集
    AVURLAsset* videoAsset =[[AVURLAsset alloc] initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack * a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]atTime:nextClipStartTime error:nil];
    
    //声音采集
    AVURLAsset* audioAsset =[[AVURLAsset alloc] initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);//声音长度截取范围==视频长度
    AVMutableCompositionTrack * b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]atTime:nextClipStartTime error:nil];
    
    //创建一个输出
    AVAssetExportSession* _assetExport =[[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType =AVFileTypeQuickTimeMovie;
    _assetExport.outputURL =outputFileUrl;
    _assetExport.shouldOptimizeForNetworkUse=YES;
    self.theEndVideoURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         //播放
         NSURL*url = [NSURL fileURLWithPath:outputFilePath];
         //         MPMoviePlayerViewController *theMovie =[[MPMoviePlayerViewController alloc] initWithContentURL:url];
         //         //[self presentMoviePlayerViewController Animated:theMovie];
         //         theMovie.moviePlayer.movieSourceType=MPMovieSourceTypeFile;
         //         [theMovie.moviePlayer play];
         [self viewMovieAtUrl:url];
     }
     ];
    NSLog(@"完成！输出路径==%@",outputFilePath);
}

//通过文件路径建立和添加音频素材
- (void)setUpAndAddAudioAtPath:(NSURL*)assetURL toComposition:(AVMutableComposition*)composition start:(CMTime)start dura:(CMTime)dura offset:(CMTime)offset{
    
    AVURLAsset *songAsset =[AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVMutableCompositionTrack *track =[composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *sourceAudioTrack =[[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    NSError *error =nil;
    BOOL ok =NO;
    
    CMTime startTime = start;
    CMTime trackDuration = dura;
    CMTimeRange tRange =CMTimeRangeMake(startTime,trackDuration);
    
    //设置音量
    //AVMutableAudioMixInputParameters（输入参数可变的音频混合）
    //audioMixInputParametersWithTrack（音频混音输入参数与轨道）
    AVMutableAudioMixInputParameters *trackMix =[AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [trackMix setVolume:0.8f atTime:startTime];
    
    //素材加入数组
    [audioMixParams addObject:trackMix];
    
    //Insert audio into track  //offsetCMTimeMake(0, 44100)
    ok = [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:kCMTimeInvalid error:&error];
}

#pragma mark - 保存路径
-(NSString*)getLibarayPath
{
    NSFileManager *fileManager =[NSFileManager defaultManager];
    
    NSArray* paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString* path = [paths objectAtIndex:0];
    
    NSString *movDirectory = [path stringByAppendingPathComponent:@"tmpMovMix"];
    
    [fileManager createDirectoryAtPath:movDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    return movDirectory;
    
}

@end

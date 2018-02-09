//
//  LLPhotoGridViewController.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoGridViewController.h"

#import "LLPhotoBottomView.h"
#import "LLPhotoGridCell.h"
#import "LLPhotoPickerService.h"
#import "LLPhotoPickerConfig.h"
#import "UICollectionView+Picker.h"
//#import "UIImage+LL.h"
#import "LLPhotoPreviewViewController.h"
#import "LLUtil.h"
#define kPhotoPickerGridIdentifier  NSStringFromClass([LLPhotoGridCell class])

@interface LLPhotoGridViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
LLPhotoBottomViewDelegate,
LLPhotoGridCellDelegate,
LLPhotoPreviewViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LLPhotoBottomView *bottomView;
@property (nonatomic, assign) CGSize gridSize;
@property (nonatomic, assign) CGRect previousPreheatRect;

@end

@implementation LLPhotoGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeUI];
    [self resetCachedAssets];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeUI
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    if ([LLPhotoPickerConfig shared].isMutableSelect) {
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.equalTo([LLPhotoBottomView height]);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.bottom.equalTo(self.bottomView.mas_top);
        }];
    } else {
        self.bottomView.hidden = YES;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    
    [self registerCell];
}

- (void)registerCell
{
    [self.collectionView registerClass:[LLPhotoGridCell class] forCellWithReuseIdentifier:kPhotoPickerGridIdentifier];
}

- (void)resetData {
    [[LLPhotoPickerService shared] removeAllAsset];
    [[LLPhotoPickerService shared] removeAllCachedObjects];
}

- (void)cancelAction:(id)sender {
    [self resetData];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize)gridSize {
    CGFloat width = SCREEN_W - [LLPhotoPickerConfig shared].minimumInteritemSpacing * 2;
    CGFloat cellWidth = (width - ([LLPhotoPickerConfig shared].colum - 1) * [LLPhotoPickerConfig shared].minimumInteritemSpacing) / [LLPhotoPickerConfig shared].colum;
    CGSize size = CGSizeMake(cellWidth, cellWidth);
    return size;
}

- (void)handleVideoAsset:(PHAsset *)asset complete:(void (^)(NSDictionary *info))resultHandler
{
    WEAKSELF(weakSelf);
    PHAsset *videoAsset = asset;
    [[LLPhotoPickerService shared] requestVideoForAsset:videoAsset completion:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        weakSelf.outputVideoFilePath = [LLPhotoPickerConfig shared].outputVideoFilePath;
        weakSelf.outputVideoCoverPath = [LLPhotoPickerConfig shared].outputVideoCoverPath;
        NSAssert(weakSelf.outputVideoFilePath != nil, @"outputVideoFilePath 不能为空");
        NSAssert(weakSelf.outputVideoCoverPath != nil, @"outputVideoCoverPath 不能为空");
        [[NSFileManager defaultManager] ll_createDirectoryAtPath:weakSelf.outputVideoFilePath];
        [[NSFileManager defaultManager] ll_createDirectoryAtPath:weakSelf.outputVideoCoverPath];
        
        AVURLAsset *avurlasset = (AVURLAsset*) asset;
        NSString *videoPath = avurlasset.URL.path;
        
        CGFloat size = [LLUtil getFileSize:videoPath] / (1024 * 1024); //单位M
        NSLog(@"########------文件大小：%f",size);
        if (size > 500) {//>500M
//            [LLProgressHUD dismiss];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [LLProgressHUD showInfoWithStatus:@"视频过大超出限制，请重新选择"];
            });
            return;
        }
        
//        dispatch_async_main_safe(^{
//            [LLProgressHUD showWithStatus:@"视频转码中，请耐心等待..."];
//        });
        
        CFTimeInterval exportStLL = CACurrentMediaTime();
        NSURL *videoFileUrl = [NSURL fileURLWithPath:weakSelf.outputVideoFilePath];
        
        [weakSelf exportAsset:avurlasset toFilePathURL:videoFileUrl complete:^(NSError *error, AVAssetExportSession *session) {
            void(^completeBlock)() = ^(){
                NSString *videoURLPath = weakSelf.outputVideoFilePath;
                NSNumber *videoDuration = @(videoAsset.duration);
                CGFloat size = [LLUtil getFileSize:weakSelf.outputVideoFilePath];
                NSNumber *videoSize = @(size);
                NSString *videoCoverPath = weakSelf.outputVideoCoverPath;
                NSString *videoCoverThumailPath = [NSString stringWithFormat:@"%@%@",weakSelf.outputVideoCoverPath,[LLUtil thumbSuffix]];
                
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    UIImage *originImage = [[LLPhotoPickerService shared] synRequestOriginImageForAsset:videoAsset networkAccessAllowed:NO];
                    UIImage *thumImage = [[LLPhotoPickerService shared] synRequestLowQualityImageForAsset:videoAsset targetSize:weakSelf.gridSize];
                    NSData* data = UIImageJPEGRepresentation(originImage,1);
                    [data writeToFile:videoCoverPath atomically:YES];
                    NSValue *coverImageSize = [NSValue valueWithCGSize:originImage.size];
                    CGFloat coverImageFileSize = data.length;
                    
                    NSData* thumData = UIImageJPEGRepresentation(thumImage,1);
                    [thumData writeToFile:videoCoverThumailPath atomically:YES];
                    NSDictionary *dic = @{
                                          kVideoPath:CheckString(videoURLPath),
                                          kVideoCoverPath:CheckString(videoCoverPath),
                                          kVideoCoverThumailPath:CheckString(videoCoverThumailPath),
                                          kVideoSize:videoSize,
                                          kVideoDuration:videoDuration,
                                          kVideoCoverImageSize :coverImageSize,
                                          kVideoCoverImageFileSize : @(coverImageFileSize)
                                          };
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (resultHandler) {
                            resultHandler(dic);
                        }
                    });
                });
            };
            
            if (error) {
                NSLog(@"转码失败：%@",[error localizedDescription]);
                //                dispatch_async_main_safe(^{
                //                    [LLProgressHUD showWithStatus:@"转码失败,直接上传中..."];
                //                });
                NSError *removeError = nil;
                [[NSFileManager defaultManager] removeItemAtURL:videoFileUrl error:&removeError];
                
                CFTimeInterval copyStLL = CACurrentMediaTime();
                NSError *tmpError = nil;
                BOOL moveSuccess = [[NSFileManager defaultManager] copyItemAtURL:avurlasset.URL
                                                                           toURL:videoFileUrl
                                                                           error:&tmpError];
                
//                dispatch_async_main_safe(^{
//                    [LLProgressHUD dismiss];
//                });
                if (moveSuccess && !tmpError) {
                    CFTimeInterval copyTime = CACurrentMediaTime() - copyStLL;
                    NSLog(@"########------拷贝耗时----%f",copyTime);
                    completeBlock();
                    return;
                }
            }
            CFTimeInterval export = CACurrentMediaTime() - exportStLL;
            NSLog(@"########------转码耗时----%f",export);
            completeBlock();
        }];
    }];
}

- (void)exportAsset:(AVURLAsset *)asset toFilePathURL:(NSURL *)path complete:(void (^)(NSError *error,AVAssetExportSession *session))completionBlock {
    //转换视频
    //    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //    session.outputFileType = AVFileTypeMPEG4;
    //    session.outputURL = path;
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality])
    {
        //============================================153.1 ipad air1
        //========presetName================时间=======转码后大小=====
        //AVAssetExportPresetHighestQuality 11s         153.
        //AVAssetExportPresetMediumQuality  35s         11.5
        //AVAssetExportPreset1280x720       11.46       153.
        //AVAssetExportPreset960x540        59.96       77.
        
        //============================================246.784073 mini2
        //========presetName================时间=======转码后大小=====
        //AVAssetExportPresetHighestQuality 8s         246.6
        //AVAssetExportPresetMediumQuality  35s         11.1
        //AVAssetExportPreset1280x720       11.46       153.
        //AVAssetExportPreset960x540        59.96       77.
        AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        session.outputFileType = AVFileTypeMPEG4;
        session.outputURL = path;
        [session exportAsynchronouslyWithCompletionHandler:^{
            switch (session.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    completionBlock(nil,session);
//                    dispatch_async_main_safe(^{
//                        [LLProgressHUD dismiss];
//                    });
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    break;
                case AVAssetExportSessionStatusFailed:
//                    dispatch_async_main_safe(^{
//                        [LLProgressHUD dismiss];
//                    });
                    NSLog(@"%@",session.error);
                    completionBlock(session.error,nil);
                    NSAssert([[NSThread mainThread] isMainThread], @"Not Main Thread");
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    break;
            }
        }];
    }
}
//MARK: cache manage
- (void)resetCachedAssets {
    [[LLPhotoPickerService shared].cacheManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to stLL caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView ll_indexPathForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView ll_indexPathForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStLLCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        CGSize size = CGSizeMake(self.gridSize.width * kScreenScale, self.gridSize.height * kScreenScale);
        [[LLPhotoPickerService shared].cacheManager startCachingImagesForAssets:assetsToStLLCaching
                                                                      targetSize:size
                                                                     contentMode:PHImageContentModeAspectFill
                                                                         options:nil];
        [[LLPhotoPickerService shared].cacheManager stopCachingImagesForAssets:assetsToStopCaching
                                                                     targetSize:size
                                                                    contentMode:PHImageContentModeAspectFill
                                                                        options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}


- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}

//MARK: LLPhotoPreviewViewControllerDelegate
- (void)photoPreviewDidSendPhotos:(NSArray<PHAsset *> *)photos origin:(BOOL)isOrigin
{
    if([self.delegate respondsToSelector:@selector(photoPickerDidSendPhotos:origin:)]) {
        [self.delegate photoPickerDidSendPhotos:[[LLPhotoPickerService shared].selectedAssets copy] origin:isOrigin];
        [self resetData];
        //        [self cancelAction:nil];
    }
}

//MARK: LLPhotoBottomViewDelegate
//发送
- (void)photoPickerDidSend:(BOOL)isOrigin
{
    if ([LLPhotoPickerService shared].selectedCount < [LLPhotoPickerConfig shared].minSelectedCount) {
        NSLog(@"alert");
        NSString *message = [NSString stringWithFormat:@"最少选择%tu张图片",[LLPhotoPickerConfig shared].minSelectedCount];
//        [self showText:message];
        return;
    }
    
    if ([LLPhotoPickerConfig shared].resourceType == ELLAssetResourceTypeVideo) {
        PHAsset *assert = [LLPhotoPickerService shared].selectedAssets.firstObject;
        WEAKSELF(weakSelf)
        [self handleVideoAsset:assert complete:^(NSDictionary *info) {
            if([weakSelf.delegate respondsToSelector:@selector(photoPickerDidSendVideo:)]) {
                [weakSelf.delegate photoPickerDidSendVideo:info];
                [weakSelf resetData];
            }
        }];
    } else {
        if([self.delegate respondsToSelector:@selector(photoPickerDidSendPhotos:origin:)]) {
            [self.delegate photoPickerDidSendPhotos:[[LLPhotoPickerService shared].selectedAssets copy] origin:isOrigin];
            [self resetData];
        }
    }
}

//MARK: LLPhotoGridCellDelegate
- (void)didSeletedMoreThanMax
{
    NSString *subMessage = [LLPhotoPickerConfig shared].resourceType == ELLAssetResourceTypeVideo ? @"个视频" : @"张图片";
    NSString *message = [NSString stringWithFormat:@"最多只能选择%tu%@",[LLPhotoPickerConfig shared].maxSelectedCount,subMessage];
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    //    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    //    [alert addAction:action];
    //    [self presentViewController:alert animated:YES completion:nil];
//    [self showText:message];
}

//MARK: UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLPhotoGridCell *cell = (LLPhotoGridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotoPickerGridIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    PHAsset *asset = nil;
    if (indexPath.row < self.fetchResult.count) {
        asset = [self.fetchResult objectAtIndex:indexPath.row];
        cell.asset = asset;
        cell.representedAssetIdentifier = asset.localIdentifier;
        [[LLPhotoPickerService shared] requestLowQualityImageForAsset:asset size:self.gridSize exactSize:YES completion:^(UIImage *aImage, NSDictionary *aInfo, BOOL isDegraded) {
            NSLog(@"=====%@",aInfo);
            if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                cell.photoImageView.image = aImage;
            }
        }];
        if ([LLPhotoPickerConfig shared].isMutableSelect) {
            [cell hideSeletedBtn:NO];
            [cell updateSelected:[[LLPhotoPickerService shared] containSelectedAsset:asset]];
        } else {
            [cell hideSeletedBtn:YES];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if ([LLPhotoPickerConfig shared].resourceType == ELLAssetResourceTypeVideo) {
        PHAsset *asset = nil;
        if (indexPath.row < self.fetchResult.count) {
            asset = [self.fetchResult objectAtIndex:indexPath.row];
            [[LLPhotoPickerService shared] addAsset:asset];
            WEAKSELF(weakSelf)
            [self handleVideoAsset:asset complete:^(NSDictionary *info) {
                if([weakSelf.delegate respondsToSelector:@selector(photoPickerDidSendVideo:)]) {
                    [weakSelf.delegate photoPickerDidSendVideo:info];
                    [weakSelf resetData];
                }
            }];
        }
        return;
    }
    
    //多选 或者在学生中 需要跳转到 预览
    if ([LLPhotoPickerConfig shared].isMutableSelect) {
        LLPhotoPreviewViewController *vc = [[LLPhotoPreviewViewController alloc] init];
        vc.fetchResult = self.fetchResult;
        vc.currentIndex = indexPath.row;
        vc.delegate = self;
        WEAKSELF(weakSelf);
        vc.previewGoBack = ^(){
            [weakSelf.collectionView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
    [[LLPhotoPickerService shared] addAsset:asset];
    if([self.delegate respondsToSelector:@selector(photoPickerDidSendPhotos:origin:)]) {
        [self.delegate photoPickerDidSendPhotos:[[LLPhotoPickerService shared].selectedAssets copy] origin:NO];
        if ([LLPhotoPickerConfig shared].showType == ELLPickerShowTypeAvator) {
            [self resetData];
            return;
        } else {
            //            [self cancelAction:nil];
            [self resetData];
        }
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

//MARK: lazy
- (UICollectionView *)collectionView
{
    if(!_collectionView){
        UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
        flowlayout.itemSize = self.gridSize;
        flowlayout.minimumInteritemSpacing = [LLPhotoPickerConfig shared].minimumInteritemSpacing;
        flowlayout.sectionInset = UIEdgeInsetsMake([LLPhotoPickerConfig shared].minimumInteritemSpacing, [LLPhotoPickerConfig shared].minimumInteritemSpacing, [LLPhotoPickerConfig shared].minimumInteritemSpacing, [LLPhotoPickerConfig shared].minimumInteritemSpacing);
        flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowlayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (LLPhotoBottomView *)bottomView
{
    if(!_bottomView){
        _bottomView = [[LLPhotoBottomView alloc] init];
        [_bottomView originHidden:YES];
        _bottomView.delegate = self;
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end

//
//  LLPhotoPickerViewController.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoPickerViewController.h"
#import "LLPhotoGroupViewController.h"
#import <Photos/Photos.h>
#import "LLPhotoGroupModel.h"
#import "LLPhotoPickerConfig.h"
#import "LLPhotoGridViewController.h"
@interface LLPhotoPickerViewController ()<LLPhotoGridViewControllerDelegate>

@property (nonatomic, assign) ELLAssetResourceType resourceType;

@end

@implementation LLPhotoPickerViewController

- (instancetype)initWithResourceType:(ELLAssetResourceType)type
{
    [[LLPhotoPickerConfig shared] reset];
    LLPhotoGroupViewController *vc = [[LLPhotoGroupViewController alloc] init];
    vc.gridDelegate = self;
    vc.resourceType = type;
    self = [super initWithRootViewController:vc];
    
    self.resourceType = type;
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:[LLPhotoPickerConfig shared].fetchOptions];
    if(assetsFetchResults.count > 0) {
        LLPhotoGroupModel *model = [[LLPhotoGroupModel alloc] init];
        model.groupFetchResult = assetsFetchResults;
        model.albumName = type == ELLAssetResourceTypeVideo ? @"全部视频":@"全部照片";
        LLPhotoGridViewController *gridVC = [[LLPhotoGridViewController alloc] init];
        gridVC.fetchResult = model.groupFetchResult;
        gridVC.title = model.albumName;
        gridVC.delegate = self;
        [self pushViewController:gridVC animated:NO];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithResourceType:ELLAssetResourceTypeAll];
}

- (LLPhotoGroupModel *)filterFetchResult:(PHAssetCollection *)collection {
    PHFetchResult<PHAsset *>*result = [PHAsset fetchAssetsInAssetCollection:collection options:[LLPhotoPickerConfig shared].fetchOptions];
    if (result.count > 0) {
        LLPhotoGroupModel *model = [[LLPhotoGroupModel alloc] init];
        model.groupFetchResult = result;
        model.albumName = collection.localizedTitle;
        return model;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)setMaximumNumberOfSelection:(NSInteger)maximumNumberOfSelection
{
    [LLPhotoPickerConfig shared].maxSelectedCount = maximumNumberOfSelection;
}

- (void)setMinimumNumberOfSelection:(NSInteger)minimumNumberOfSelection
{
    [LLPhotoPickerConfig shared].minSelectedCount = minimumNumberOfSelection;
}

- (void)setShowType:(ELLPickerShowType)showType
{
    _showType = showType;
    [LLPhotoPickerConfig shared].showType = showType;
}

- (void)setResourceType:(ELLAssetResourceType)resourceType
{
    _resourceType = resourceType;
    [LLPhotoPickerConfig shared].resourceType = resourceType;
}

- (void)setOutputVideoFilePath:(NSString *)outputVideoFilePath
{
    _outputVideoFilePath = outputVideoFilePath;
    [LLPhotoPickerConfig shared].outputVideoFilePath = outputVideoFilePath;
}

- (void)setOutputVideoCoverPath:(NSString *)outputVideoCoverPath
{
    _outputVideoCoverPath = outputVideoCoverPath;
    [LLPhotoPickerConfig shared].outputVideoCoverPath = outputVideoCoverPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: LLPhotoGridViewControllerDelegate
- (void)photoPickerDidSendPhotos:(NSArray<PHAsset *> *)photos origin:(BOOL)isOrigin
{
    if ([self.pickerDelegate respondsToSelector:@selector(photoPicker:didSelectedPhotos:origin:)]) {
        [self.pickerDelegate photoPicker:self didSelectedPhotos:photos origin:isOrigin];
    }
}

- (void)photoPickerDidSendVideo:(NSDictionary *)videoInfo
{
    if ([self.pickerDelegate respondsToSelector:@selector(photoPicker:didSelectedVideo:)]) {
        [self.pickerDelegate photoPicker:self didSelectedVideo:videoInfo];
    }
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end

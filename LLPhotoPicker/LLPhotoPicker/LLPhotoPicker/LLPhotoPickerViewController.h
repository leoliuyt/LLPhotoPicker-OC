//
//  LLPhotoPickerViewController.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "LLPhotoPickerConfig.h"
#import "LLPhotoPickerService.h"

@class LLPhotoPickerViewController;
@protocol LLPhotoPickerViewControllerDelegate <NSObject>

//选中图片
@optional
- (void)photoPicker:(LLPhotoPickerViewController *)pickerVC didSelectedPhotos:(NSArray<PHAsset *> *)photos origin:(BOOL)isOrigin;

//选中视频
- (void)photoPicker:(LLPhotoPickerViewController *)pickerVC didSelectedVideo:(NSDictionary *)videoInfo;

@end

@interface LLPhotoPickerViewController : UINavigationController

@property (nonatomic, assign) NSInteger minimumNumberOfSelection;//最小选择数量
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;//最多选择数量
@property (nonatomic, assign) ELLPickerShowType showType;//UI样式

@property (nonatomic, copy) NSString *outputVideoFilePath;//视频路径
@property (nonatomic, copy) NSString *outputVideoCoverPath;//视频封面路径

@property (nonatomic, weak) id<LLPhotoPickerViewControllerDelegate> pickerDelegate;

- (instancetype)initWithResourceType:(ELLAssetResourceType)type;

@end

//
//  LLPhotoPickerConfig.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Photos/Photos.h>

#define kVideoPath @"kVideoPath"
#define kVideoCoverPath @"kVideoCoverPath"
#define kVideoCoverImageSize @"kVideoCoverImageSize"
#define kVideoCoverImageFileSize @"kVideoCoverImageFileSize"
#define kVideoCoverThumailPath @"kVideoCoverThumailPath"
#define kVideoSize @"kVideoSize"
#define kVideoDuration @"kVideoDuration"

typedef NS_ENUM(NSUInteger, ELLAssetResourceType) {
    ELLAssetResourceTypeAll,
    //    ELLAssetResourceTypeImage,
    ELLAssetResourceTypeVideo,
};

typedef NS_ENUM(NSUInteger, ELLPickerShowType) {
    ELLPickerShowTypeDefault,
    ELLPickerShowTypeAvator,//选头像
};

@interface LLPhotoPickerConfig : NSObject

@property (nonatomic, assign) NSInteger colum;
@property (nonatomic, assign) NSInteger minSelectedCount;   //最少选择图片数
@property (nonatomic, assign) NSInteger maxSelectedCount;   //最多选择图片数
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) ELLAssetResourceType resourceType;
@property (nonatomic, assign) ELLPickerShowType showType;
@property (nonatomic, assign) BOOL isMutableSelect; //多选
@property (nonatomic, assign) BOOL isOriginal;

@property (nonatomic, copy) NSString *outputVideoFilePath;//视频路径
@property (nonatomic, copy) NSString *outputVideoCoverPath;//视频封面路径

@property (nonatomic, strong, readonly) PHFetchOptions *fetchOptions;

+ (instancetype)shared;

- (void)reset;

@end

//
//  LLPhotoPickerService.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Photos/Photos.h>

@interface LLPhotoPickerService : NSObject

@property (nonatomic, assign) NSInteger selectedCount;      //已经选中图片数
@property (nonatomic, strong) PHCachingImageManager *cacheManager;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedAssets;

- (void)removeAllCachedObjects;
- (void)removeAllAsset;
- (void)addAsset:(PHAsset *)asset;
- (void)removeAsset:(PHAsset *)asset;

- (BOOL)containSelectedAsset:(PHAsset *)asset;

+ (instancetype)shared;

//权限判断 是否授权
+ (void)requestAuthorization:(void (^)())authorSuccessHandler;

//有可能会返回nil 如果是从icloud中的图片，会返回nil
- (UIImage *)synRequestOriginImageForAsset:(PHAsset *)asset networkAccessAllowed:(BOOL)allowed;

/**
 *  异步请求 Asset 的原图
 *  @param asset 请求资源
 *  @param completion 完成请求后调用的 block，参数中包含了请求的原图以及图片信息，这个 block 会被多次调用，其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直接获取到高清图
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestOriginImageForAsset:(PHAsset *)asset completion:(void(^)(UIImage *aImage))completion;

/**
 *  Asset 的缩略图
 *  @param asset 请求资源
 *  @param size 指定返回的缩略图的大小
 *  @return Asset 的缩略图
 */
- (UIImage *)synRequestLowQualityImageForAsset:(PHAsset *)asset targetSize:(CGSize)size;

/**
 异步请求 Asset 的缩略图

 @param asset 请求资源
 @param size 定返回的缩略图的大小
 @param isExactSize 是否确切的返回指定缩率图大小
 @param completion  完成请求后调用的 block，参数中包含了请求的缩略图以及图片信息，这个 block 会被多次调用，
 *                  其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直接获取到高清图
 @return 返回请求图片的请求 id
 */
- (NSInteger)requestLowQualityImageForAsset:(PHAsset *)asset size:(CGSize)size exactSize:(BOOL)isExactSize completion:(void (^)(UIImage *aImage, NSDictionary *aInfo, BOOL isDegraded))completion;

/*
 获取图片data
 */
- (NSInteger)requestImageDataForAsset:(PHAsset *)asset completion:(void(^)(NSData * imageData, UIImageOrientation orientation, NSDictionary * info))resultHandler;

/*
 获取原图大小
 */
- (void)getOriginImageBytesFromAsset:(PHAsset *)asset completion:(void (^)(NSString *totalBytes))completion;

/**
 *  异步请求 Asset 的视频，不会产生网络请求
 *  @param asset 请求资源
 *  @param resultHandler 完成请求后调用的 block
 *  @return 返回请求视频的请求 id
 */
- (NSInteger)requestVideoForAsset:(PHAsset *)asset completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))resultHandler;

/**
 *  异步请求 Asset 的视频，不会产生网络请求
 *  @param asset 请求资源
 *  @param exportPreset 导出资源的预设名
 *  @param resultHandler 完成请求后调用的 block
 *  @return 返回请求视频的请求 id
 */
- (NSInteger)requestVideoForAsset:(PHAsset *)asset exportPreset:(NSString *)exportPreset completion:(void (^)(AVAssetExportSession *exportSession, NSDictionary *info))resultHandler;

@end


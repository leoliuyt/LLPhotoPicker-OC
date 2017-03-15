//
//  LLPhotoPickerService.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoPickerService.h"

#import "AppDelegate.h"
#import "LLUtil.h"

@interface LLPhotoPickerService()

@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation LLPhotoPickerService

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    static LLPhotoPickerService* shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    [self configure];
    return self;
}

- (void)configure {
    self.cacheManager = [[PHCachingImageManager alloc] init];
    self.cacheManager.allowsCachingHighQualityImages = NO;
    self.selectedAssets = [NSMutableArray array];
    self.imageCache = [[NSCache alloc] init];
}

- (void)removeAllCachedObjects {
    [self.imageCache removeAllObjects];
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self.cacheManager stopCachingImagesForAllAssets];
    }
}

- (void)addAsset:(PHAsset *)asset {
    [self.selectedAssets addObject:asset];
    self.selectedCount = self.selectedAssets.count;
}

- (void)removeAsset:(PHAsset *)asset {
    [self.selectedAssets removeObject:asset];
    self.selectedCount = self.selectedAssets.count;
}

- (void)removeAllAsset {
    [self.selectedAssets removeAllObjects];
    self.selectedCount = 0;
}

- (BOOL)containSelectedAsset:(PHAsset *)asset{
    return [self.selectedAssets containsObject:asset];
}

+ (void)requestAuthorization:(void (^)())handler
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL authorized = status == PHAuthorizationStatusAuthorized;
            if (handler) {
                if(!authorized) {
                    [LLPhotoPickerService showNoPermissionMessage];
                    return;
                }
                handler();
            }
        });
    }];
}

+ (void)showNoPermissionMessage{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"去设置打开相册的权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //打开权限
        [LLUtil openSystemSetting];
    }];
    [alert addAction:action];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (NSString *)identifierWithAssset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    return [NSString stringWithFormat:@"%@%@",asset.localIdentifier, NSStringFromCGSize(targetSize)];
}

//MARK: 获取图片、视频
- (UIImage *)originImageForAsset:(PHAsset *)asset targetSize:(CGSize)size {
    __block UIImage *resultImage;
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    //synchronous 设为 YES 时，deliveryMode 属性就会被忽略，并被当作HighQualityFormat 来处理
    //同步方法不要将networkAccessAllowed 设置YES
    phImageRequestOptions.synchronous = YES;
    phImageRequestOptions.networkAccessAllowed = NO;
    phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    [self.cacheManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:phImageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultImage = result;
    }];
    return resultImage;
}

- (UIImage *)originImageForAsset:(PHAsset *)asset {
    return [self originImageForAsset:asset targetSize:PHImageManagerMaximumSize];
}

- (NSInteger)requestOriginImageForAsset:(PHAsset *)asset completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion
{
    return [self requestOriginImageForAsset:asset completion:completion withProgressHandler:nil];
}

- (NSInteger)requestOriginImageForAsset:(PHAsset *)asset completion:(void (^)(UIImage *, NSDictionary * ,BOOL isDegraded))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    NSString *ID = [self identifierWithAssset:asset targetSize:PHImageManagerMaximumSize];
    if ([self.imageCache objectForKey:ID]) {
        completion([self.imageCache objectForKey:ID], nil , NO);
        return 0;
    } else {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        imageRequestOptions.progressHandler = phProgressHandler;
        return [self.cacheManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _previewImage 中
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && !isDegraded;
            if (downloadFinined) {
                if (result) {
                    [self.imageCache setObject:result forKey:ID];
                }
            }
            if (completion) {
                completion(result, info, isDegraded);
            }
        }];
    }
}

- (NSInteger)requestImageDataForAsset:(PHAsset *)asset completion:(void(^)(NSData *__nullable imageData, UIImageOrientation orientation, NSDictionary *__nullable info, BOOL isDegraded))resultHandler
{
    //    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    //    imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
    //    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    //    imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    //    if (completion) completion(resultImage,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
    return [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSLog(@"leoliu===requestData ==dataUTI = %@ orientation = %tu info = %@",dataUTI,orientation,info);
        BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        resultHandler(imageData,orientation,info,isDegraded);
    }];
}

- (UIImage *)thumbnailForAsset:(PHAsset *)asset size:(CGSize)size {
    __block UIImage *resultImage;
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    phImageRequestOptions.synchronous = YES;
    phImageRequestOptions.networkAccessAllowed = NO;
    phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
    [self.cacheManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale)
                                contentMode:PHImageContentModeAspectFill options:phImageRequestOptions
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  resultImage = result;
                              }];
    return resultImage;
}

- (NSInteger)requestThumbnailImageForAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion {
    NSString *ID = [self identifierWithAssset:asset targetSize:size];
    if ([self.imageCache objectForKey:ID]) {
        completion([self.imageCache objectForKey:ID], nil,NO);
        return 0;
    } else {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        //        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        //        imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        return [self.cacheManager  requestImageForAsset:asset targetSize:CGSizeMake(size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _previewImage 中
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && !isDegraded;
            if (downloadFinined) {
                if (result) {
                    [self.imageCache setObject:result forKey:ID];
                }
            }
            if (completion) {
                completion(result, info,isDegraded);
            }
        }];
    }
}

- (UIImage *)previewImageForAsset:(PHAsset *)asset targetSize:(CGSize)size {
    __block UIImage *resultImage;
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    phImageRequestOptions.synchronous = YES;
    phImageRequestOptions.networkAccessAllowed = NO;
    phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    [self.cacheManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:phImageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultImage = result;
    }];
    return resultImage;
}

- (UIImage *)previewImageForAsset:(PHAsset *)asset {
    return [self previewImageForAsset:asset targetSize:[UIScreen mainScreen].bounds.size];
}

- (NSInteger)requestPreviewImageForAsset:(PHAsset *)asset withCompletion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion
{
    return [self requestPreviewImageForAsset:asset withCompletion:completion withProgressHandler:nil];
}

- (NSInteger)requestPreviewImageForAsset:(PHAsset *)asset withCompletion:(void (^)(UIImage *, NSDictionary *, BOOL isDegraded))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    CGSize size = [UIScreen mainScreen].bounds.size;
    NSString *ID = [self identifierWithAssset:asset targetSize:size];
    if ([self.imageCache objectForKey:ID]) {
        completion([self.imageCache objectForKey:ID], nil,NO);
        return 0;
    } else {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        imageRequestOptions.progressHandler = phProgressHandler;
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        return [self.cacheManager requestImageForAsset:asset targetSize:CGSizeMake(size.width, size.height) contentMode:PHImageContentModeAspectFit options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            // 排除取消，错误，低清图三种情况，即已经获取到了高清图时，把这张高清图缓存到 _previewImage 中
            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && !isDegraded;
            if (downloadFinined) {
                if (result) {
                    [self.imageCache setObject:result forKey:ID];
                }
            }
            if (completion) {
                completion(result, info,isDegraded);
            }
        }];
    }
}

- (void)getOriginImageBytesFromAsset:(PHAsset *)asset completion:(void (^)(NSString *totalBytes))completion {
    __block NSInteger dataLength = 0;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        dataLength += imageData.length;
        NSString *bytes = [self getBytesFromDataLength:dataLength];
        if (completion) completion(bytes);
    }];
}

- (NSString *)getBytesFromDataLength:(NSInteger)dataLength {
    NSString *bytes;
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%0.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%0.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}


- (NSInteger)requestVideoForAsset:(PHAsset *)asset exportPreset:(NSString *)exportPreset completion:(void (^)(AVAssetExportSession *exportSession, NSDictionary *info))resultHandler
{
    PHVideoRequestOptions *videoOptions = [[PHVideoRequestOptions alloc] init];
    videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    videoOptions.networkAccessAllowed = YES;
    return [self.cacheManager requestExportSessionForVideo:asset options:videoOptions exportPreset:exportPreset resultHandler:resultHandler];
}

- (NSInteger)requestVideoForAsset:(PHAsset *)asset completion:(void (^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))resultHandler{
    PHVideoRequestOptions *videoOptions = [[PHVideoRequestOptions alloc] init];
    videoOptions.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    videoOptions.networkAccessAllowed = YES;
    return [self.cacheManager requestAVAssetForVideo:asset options:videoOptions resultHandler:resultHandler];
}

@end


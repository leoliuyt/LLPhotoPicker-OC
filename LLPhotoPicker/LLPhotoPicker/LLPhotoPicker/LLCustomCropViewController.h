//
//  LLCustomCropViewController.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ELLSeletPhotoType) {
    ELLSeletPhotoTypeCamera = 1,   //相机拍照
    ELLSeletPhotoTypeAlbum  = 2,   //相册选图
};

@class LLCustomCropViewController;
@protocol LLCustomCropVCDelegate <NSObject>

- (void)imageCrop:(LLCustomCropViewController *)customCropVC didFinished:(UIImage *)editedImage;

- (void)imageCropDidCancel:(LLCustomCropViewController *)customCropVC;

- (void)imageCropDidRetry:(LLCustomCropViewController *)customCropVC;

@end

@interface LLCustomCropViewController : UIViewController

@property (nonatomic, assign) ELLSeletPhotoType type; // 1 相机 2 相册
@property (nonatomic, weak) id<LLCustomCropVCDelegate> delegate;
@property (nonatomic, assign) CGFloat cropScale;  //截图比例 默认710:400
@property (nonatomic, strong) UIImage *sourceImage;

@end

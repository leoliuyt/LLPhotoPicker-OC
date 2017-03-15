//
//  LLPhotoPreviewViewController.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol LLPhotoPreviewViewControllerDelegate <NSObject>

- (void)photoPreviewDidSendPhotos:(NSArray <PHAsset *>*)photos origin:(BOOL)isOrigin;
//- (void)photoPreviewDidSendVideo:(NSDictionary *)videoInfo;

@end
@interface LLPhotoPreviewViewController : UIViewController

@property (nonatomic, weak) id<LLPhotoPreviewViewControllerDelegate> delegate;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) void(^previewGoBack)();

@end

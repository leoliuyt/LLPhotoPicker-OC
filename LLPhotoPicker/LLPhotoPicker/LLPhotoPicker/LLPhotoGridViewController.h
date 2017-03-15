//
//  LLPhotoGridViewController.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

@protocol LLPhotoGridViewControllerDelegate <NSObject>

- (void)photoPickerDidSendPhotos:(NSArray <PHAsset *>*)photos origin:(BOOL)isOrigin;
- (void)photoPickerDidSendVideo:(NSDictionary *)videoInfo;
@end

@interface LLPhotoGridViewController : UIViewController

@property (nonatomic, weak) id<LLPhotoGridViewControllerDelegate> delegate;
@property (nonatomic, strong) PHFetchResult *fetchResult;

@property (nonatomic, copy) NSString *outputVideoFilePath;
@property (nonatomic, copy) NSString *outputVideoCoverPath;

@end

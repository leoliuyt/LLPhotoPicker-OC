//
//  LLPhotoTopView.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

@protocol LLPhotoTopViewDelegate <NSObject>

- (void)photoPickerBack;

@end

@interface LLPhotoTopView : UIView
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, weak) id<LLPhotoTopViewDelegate> delegate;

- (void)updateSelected:(BOOL)isSelected;

- (void)hideSelectBtn:(BOOL)hide;

+ (CGFloat)height;

@end

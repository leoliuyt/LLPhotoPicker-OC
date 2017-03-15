//
//  LLPhotoBottomView.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LLPhotoBottomViewDelegate <NSObject>

//发送选择图片
- (void)photoPickerDidSend:(BOOL)isOrigin;

- (void)photoPickerDidSelectOrigin:(BOOL)selectedOrigin;

@end

@interface LLPhotoBottomView : UIView

@property (nonatomic, weak) id<LLPhotoBottomViewDelegate> delegate;

- (void)originHidden:(BOOL)hide;

+ (CGFloat)height;

@end

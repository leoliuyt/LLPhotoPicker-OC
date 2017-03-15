//
//  JYImageScrollView.h
//  Demo
//
//  Created by weijingyun on 16/6/2.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JYImageScrollView;
@protocol JYImageScrollViewProtocol <NSObject>
@optional

- (void)imageScrollViewTap:(JYImageScrollView *)scrollView;

// 下载失败  用于是否加提示view
- (void)imageDownLoadfailed:(JYImageScrollView *)scrollView error:(NSError *)aError;

@end

@interface JYImageScrollView : UIScrollView

@property (nonatomic, weak) id<JYImageScrollViewProtocol> tapDelegate;
// 加载图
@property (nonatomic, strong, readonly) NSString *urlString;
@property (nonatomic, strong) UIImage *image;  
@property (nonatomic, assign) CGSize imageSize; //指定imageSize 否则取图片真实的

//- (void)setImageWithURLString:(NSString *)urlString;
//- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder;
//- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder completed:(void (^)(UIImage *,NSError *))aCompleted;
//
//- (void)setImageWithURL:(NSURL *)url;
//- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end

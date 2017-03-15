//
//  UIImage+LL.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LL)

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)ratioImageWithScaleSize:(CGSize)aScaleSize;

//- (UIImage *)addWatermarkImage:(UIImage*)aImage AndText:(NSString*)aText;

/** 图片旋转后得到新图片*/
- (UIImage *)imageRotatedByDegrees:(CGFloat)aDegrees;

/**
 *  图片旋转得到图片数组
 *
 *  @param aDegrees 旋转总角度
 *  @param aNumber  图片张数
 */
- (NSArray *)imagesRotatedByTotalDegrees:(CGFloat)aDegrees numberOfImages:(NSUInteger)aNumber;

/** 将一张横图平均裁剪返回裁剪后的图片数组*/
- (NSArray *)imagesByCroppingWidthWithCount:(NSInteger)count;


/**圆角图片**/
- (UIImage *)cornerImage:(CGFloat)radius;

//获得某个范围内的屏幕图像
- (UIImage *)croppedImageWithFrame:(CGRect)frame;
//获得某个范围内的屏幕图像,并且缩放到制定尺寸
- (UIImage *)croppedImageWithFrame:(CGRect)frame inSize:(CGSize)inSize;

/**
  *  // 截图
  *
  *  @param view 要截图的View
  *
  *  @return 将UIView 转换为图片
  */
+ (UIImage *)imageFormView:(UIView *)view;

- (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius;


@end

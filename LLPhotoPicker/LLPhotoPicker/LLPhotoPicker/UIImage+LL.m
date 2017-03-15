//
//  UIImage+LL.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "UIImage+LL.h"

@implementation UIImage (LL)

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size
{
    // Create a new size image context
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create a filled rect
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextAddRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
    CGContextFillPath(context);
    
    // Recturn new image
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (UIImage *)ratioImageWithScaleSize:(CGSize)aScaleSize
{
    float ratio = self.size.width / self.size.height;
    if (aScaleSize.height >= aScaleSize.width/ratio)
    {
        UIGraphicsBeginImageContext(CGSizeMake(aScaleSize.width, aScaleSize.height));
        [self drawInRect:CGRectMake(0, (aScaleSize.height-aScaleSize.width/ratio)/2, aScaleSize.width, aScaleSize.width/ratio)];
    }
    else
    {
        UIGraphicsBeginImageContext(CGSizeMake(aScaleSize.width, aScaleSize.height));
        [self drawInRect:CGRectMake((aScaleSize.width-aScaleSize.height*ratio)/2, 0, aScaleSize.height*ratio, aScaleSize.height)];
    }
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)aDegrees
{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scale, self.size.height * scale));
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, self.size.width * scale * 0.5, self.size.height * scale * 0.5);
    CGContextRotateCTM(bitmap, aDegrees);
    CGContextTranslateCTM(bitmap, - self.size.width * scale * 0.5, - self.size.height * scale * 0.5);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, self.size.width * scale, self.size.height * scale), self.CGImage);
    UIImage *bitmapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *outputImage = [UIImage imageWithCGImage:bitmapImage.CGImage scale:scale orientation:UIImageOrientationUp];
    return outputImage;
}

- (NSArray *)imagesRotatedByTotalDegrees:(CGFloat)aDegrees numberOfImages:(NSUInteger)aNumber
{
    if (!aNumber) {
        aNumber = 1;
    }
    CGFloat degrees = aDegrees / aNumber;
    NSMutableArray *imageArrayM = [NSMutableArray arrayWithCapacity:aNumber];
    for (int i = 0; i < aNumber; ++i) {
        UIImage *image = [self imageRotatedByDegrees:(degrees *(i + 1))];
        [imageArrayM addObject:image];
    }
    return imageArrayM.copy;
}

- (NSArray *)imagesByCroppingWidthWithCount:(NSInteger)count
{
    CGFloat scale = [UIScreen mainScreen].scale;
    NSMutableArray *imageArrayM = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; ++i) {
        CGFloat aH = self.size.height * scale;
        CGFloat aW = self.size.width / count * scale;
        CGFloat aY = 0;
        CGFloat aX = aW * i;
        CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectMake(aX, aY, aW, aH));
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        UIImage *outputImage = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
        [imageArrayM addObject:outputImage];
        CGImageRelease(imageRef);
    }
    
    return imageArrayM.copy;
}

- (UIImage *)cornerImage:(CGFloat)radius
{
    return [self imageByRoundCornerRadius:radius corners:UIRectCornerAllCorners borderWidth:0 borderColor:nil borderLineJoin:kCGLineJoinMiter];
}


- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                              corners:(UIRectCorner)corners
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor
                       borderLineJoin:(CGLineJoin)borderLineJoin {
    
    if (corners != UIRectCornerAllCorners) {
        UIRectCorner tmp = 0;
        if (corners & UIRectCornerTopLeft) tmp |= UIRectCornerBottomLeft;
        if (corners & UIRectCornerTopRight) tmp |= UIRectCornerBottomRight;
        if (corners & UIRectCornerBottomLeft) tmp |= UIRectCornerTopLeft;
        if (corners & UIRectCornerBottomRight) tmp |= UIRectCornerTopRight;
        corners = tmp;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    CGFloat minSize = MIN(self.size.width, self.size.height);
    if (borderWidth < minSize / 2) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, borderWidth, borderWidth) byRoundingCorners:corners cornerRadii:CGSizeMake(radius, borderWidth)];
        [path closePath];
        
        CGContextSaveGState(context);
        [path addClip];
        CGContextDrawImage(context, rect, self.CGImage);
        CGContextRestoreGState(context);
    }
    
    if (borderColor && borderWidth < minSize / 2 && borderWidth > 0) {
        CGFloat strokeInset = (floor(borderWidth * self.scale) + 0.5) / self.scale;
        CGRect strokeRect = CGRectInset(rect, strokeInset, strokeInset);
        CGFloat strokeRadius = radius > self.scale / 2 ? radius - self.scale / 2 : 0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:strokeRect byRoundingCorners:corners cornerRadii:CGSizeMake(strokeRadius, borderWidth)];
        [path closePath];
        
        path.lineWidth = borderWidth;
        path.lineJoinStyle = borderLineJoin;
        [borderColor setStroke];
        [path stroke];
    }
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)hasAlpha
{
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    return (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaPremultipliedLast);
}

- (UIImage *)croppedImageWithFrame:(CGRect)frame
{
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, ![self hasAlpha], self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
        [self drawAtPoint:CGPointZero];
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    //NSLog(@"cropped image size:%@",NSStringFromCGSize(croppedImage.size));
    return [UIImage imageWithCGImage:croppedImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
}

- (UIImage *)croppedImageWithFrame:(CGRect)frame inSize:(CGSize)inSize
{
    if (inSize.width==0 || inSize.height==0) {
        return nil;
    }
    UIImage *croppedImage = nil;
    CGFloat scaleX=inSize.width/frame.size.width;
    CGFloat scaleY=inSize.height/frame.size.height;
    UIGraphicsBeginImageContextWithOptions(inSize, ![self hasAlpha], self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, -frame.origin.x*scaleX, -frame.origin.y*scaleY);
        CGContextScaleCTM(context, scaleX, scaleY);
        [self drawAtPoint:CGPointZero];
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    //NSLog(@"cropped image size:%@",NSStringFromCGSize(croppedImage.size));
    return [UIImage imageWithCGImage:croppedImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
}

/**
  *  // 截图
  *
  *  @param view 要截图的View
  *
  *  @return 将UIView 转换为图片
  */
+ (UIImage *)imageFormView:(UIView *)view {
    
    // 开启位图上下文对象   大小 是否不透明 缩放(0.0不缩放)
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    // 获取一个上下文
    CGContextRef Ctx = UIGraphicsGetCurrentContext();
    
    // 将当前view的layer 写入 上下文
    [view.layer renderInContext:Ctx];
    
    // 从上下文对象中取出图片
    UIImage *imageScreen = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭位图上下文
    UIGraphicsEndImageContext();
    
    return imageScreen;
}

- (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius {
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    CGFloat scale = [UIScreen mainScreen].scale;
    // 防止圆角半径小于0，或者大于宽/高中较小值的一半。
    if (cornerRadius < 0)
        cornerRadius = 0;
    else if (cornerRadius > MIN(w, h))
        cornerRadius = MIN(w, h) / 2.;
    
    UIImage *image = nil;
    CGRect imageFrame = CGRectMake(0., 0., w, h);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, scale);
    [[UIBezierPath bezierPathWithRoundedRect:imageFrame cornerRadius:cornerRadius] addClip];
    [self drawInRect:imageFrame];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

//
//  UIImage+LL.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LL)

//获得某个范围内的屏幕图像
- (UIImage *)croppedImageWithFrame:(CGRect)frame;
@end

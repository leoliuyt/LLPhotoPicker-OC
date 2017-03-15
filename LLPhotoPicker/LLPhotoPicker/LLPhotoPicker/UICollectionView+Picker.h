//
//  UICollectionView+Picker.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Picker)

- (NSArray<NSIndexPath *>*) ll_indexPathForElementsInRect:(CGRect)rect;

@end

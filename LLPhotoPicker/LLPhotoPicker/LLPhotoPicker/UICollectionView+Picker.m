//
//  UICollectionView+Picker.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "UICollectionView+Picker.h"

@implementation UICollectionView (Picker)

- (NSArray<NSIndexPath *>*) ll_indexPathForElementsInRect:(CGRect)rect {
    NSArray<__kindof UICollectionViewLayoutAttributes *> *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count <= 0) {
        return nil;
    }
    NSMutableArray <NSIndexPath *>*indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    [allLayoutAttributes enumerateObjectsUsingBlock:^(__kindof UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:obj.indexPath];
    }];
    return [indexPaths copy];
}

@end

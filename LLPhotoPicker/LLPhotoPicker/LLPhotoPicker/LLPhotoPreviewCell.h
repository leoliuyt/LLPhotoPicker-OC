//
//  LLPhotoPreviewCell.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JYImageScrollView;
@interface LLPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *representedAssetIdentifier;
@property (nonatomic, strong, readonly) JYImageScrollView *scrollView;

- (void)setImage:(UIImage *)aImage;

@end

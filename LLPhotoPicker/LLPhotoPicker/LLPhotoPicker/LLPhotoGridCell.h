//
//  LLPhotoGridCell.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol LLPhotoGridCellDelegate <NSObject>

- (void)didSeletedMoreThanMax;

@end

@interface LLPhotoGridCell : UICollectionViewCell

@property (nonatomic, weak) id<LLPhotoGridCellDelegate> delegate;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong, readonly) UIImageView *photoImageView;
@property (nonatomic, strong) NSString *representedAssetIdentifier;

- (void)updateSelected:(BOOL)isSelected;

- (void)hideSeletedBtn:(BOOL)hide;
@end


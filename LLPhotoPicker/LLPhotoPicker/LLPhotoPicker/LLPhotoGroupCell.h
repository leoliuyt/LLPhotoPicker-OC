//
//  LLPhotoGroupCell.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLPhotoGroupModel;
@interface LLPhotoGroupCell : UITableViewCell

- (void)setCellContent:(LLPhotoGroupModel *)aCellContent;
+ (CGFloat)height;

@end

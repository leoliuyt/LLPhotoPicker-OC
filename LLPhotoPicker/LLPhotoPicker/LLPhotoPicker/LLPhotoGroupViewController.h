//
//  LLPhotoGroupViewController.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLPhotoPickerConfig.h"
#import "LLPhotoGridViewController.h"

@interface LLPhotoGroupViewController : UIViewController

@property (nonatomic, assign) ELLAssetResourceType resourceType;
@property (nonatomic, weak) id<LLPhotoGridViewControllerDelegate> gridDelegate;

@end


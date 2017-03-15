//
//  LLPhotoGroupModel.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface LLPhotoGroupModel : NSObject

@property (nonatomic, strong) PHFetchResult<PHAsset *> *groupFetchResult;
@property (nonatomic, copy) NSString *albumName;

@end

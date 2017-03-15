//
//  LLPhotoPickerConfig.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoPickerConfig.h"

//
//  LLPhotoPickerConfig.m
//  LLStudio
//
//  Created by lbq on 2017/1/19.
//  Copyright © 2017年 kimziv. All rights reserved.
//

#import "LLPhotoPickerConfig.h"
#import <Photos/Photos.h>

@interface LLPhotoPickerConfig()

@property (nonatomic, strong) PHFetchOptions *fetchOptions;

@end
@implementation LLPhotoPickerConfig

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static LLPhotoPickerConfig* shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    [self configure];
    
    return self;
}

- (void)configure {
}

- (NSInteger)colum {
    if(_colum <= 0) {
        return 5;
    }
    return _colum;
}

- (CGFloat)minimumInteritemSpacing {
    if (_minimumInteritemSpacing <= 0) {
        return 20.;
    }
    return _minimumInteritemSpacing;
}

- (NSInteger)maxSelectedCount {
    if (_maxSelectedCount <= 0) {
        return 1;
    }
    return _maxSelectedCount;
}

- (BOOL)isMutableSelect
{
    return self.maxSelectedCount > 1;
}

- (PHFetchOptions *)fetchOptions {
    PHFetchOptions *op = [[PHFetchOptions alloc] init];
    if (self.resourceType == ELLAssetResourceTypeVideo) {
        op.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeVideo];
        op.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    } else {
        op.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    }
    return op;
}

- (void)reset {
    self.isOriginal = NO;
    self.minSelectedCount = 0;
    self.maxSelectedCount = 1;
    self.outputVideoFilePath = nil;
    self.outputVideoCoverPath = nil;
    self.showType = ELLPickerShowTypeDefault;
}
@end

//
//  NSFileself+Clean.m
//  ArtStudio
//
//  Created by weijingyun on 2017/1/6.
//  Copyright © 2017年 kimziv. All rights reserved.
//

#import "NSFileManager+Clean.h"

@implementation NSFileManager (Clean)
// 保证目录存在
- (void)ll_createDirectoryAtPath:(NSString *)aPath {
    
    NSString *path = [aPath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end

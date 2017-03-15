//
//  NSFileManager+LL.m
//  LLPhotoPicker
//
//  Created by leoliu on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "NSFileManager+LL.h"

@implementation NSFileManager (LL)

- (void)ll_createDirectoryAtPath:(NSString *)aPath {
    
    NSString *path = [aPath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end

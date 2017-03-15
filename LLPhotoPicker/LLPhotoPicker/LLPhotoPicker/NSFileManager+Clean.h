//
//  NSFileManager+Clean.h
//  ArtStudio
//
//  Created by weijingyun on 2017/1/6.
//  Copyright © 2017年 kimziv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Clean)
// 保证目录存在
- (void)ll_createDirectoryAtPath:(NSString *)aPath;
    
@end

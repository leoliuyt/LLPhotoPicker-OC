//
//  LLTrimHoleView.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLTrimHoleView.h"

@implementation LLTrimHoleView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    [clipPath appendPath:self.holePath];
    for (UIBezierPath *path in self.holePaths) {
        [clipPath appendPath:path];
    }
    
    clipPath.usesEvenOddFillRule = YES;
    [clipPath addClip];
    
    if (!self.viewColor) {
        self.viewColor = [UIColor blackColor];
        CGContextSetAlpha(context, 0.7f);
    }
    [self.viewColor setFill];
    [clipPath fill];
}


@end

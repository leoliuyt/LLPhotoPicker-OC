//
//  JYIndicatorView.m
//  Demo
//
//  Created by weijingyun on 16/6/22.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "JYIndicatorView.h"

#define kIndicatorViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
// 图片下载进度指示器内部控件间的间距
#define kIndicatorViewItemMargin 10

@implementation JYIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kIndicatorViewBackgroundColor;
        self.clipsToBounds = YES;
        self.style = JYIndicatorStyleStudioDiagram;//圆
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    if (progress < 0.05) {
        progress = 0.05;
    }
    _progress = progress;
    [self setNeedsDisplay];
    if (progress >= 1) {
        [self removeFromSuperview];
    }
}

- (void)setFrame:(CGRect)frame
{
    frame.size.width = 56;
    frame.size.height = 56;
    self.layer.cornerRadius = 28;
    [super setFrame:frame];
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    [[UIColor whiteColor] set];
    
    switch (self.style) {
        case JYIndicatorStylePieDiagram:
        {
            CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - kIndicatorViewItemMargin;
            
            
            CGFloat w = radius * 2 + kIndicatorViewItemMargin;
            CGFloat h = w;
            CGFloat x = (rect.size.width - w) * 0.5;
            CGFloat y = (rect.size.height - h) * 0.5;
            CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
            CGContextFillPath(ctx);
            
            [kIndicatorViewBackgroundColor set];
            CGContextMoveToPoint(ctx, xCenter, yCenter);
            CGContextAddLineToPoint(ctx, xCenter, 0);
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
            CGContextClosePath(ctx);
            
            CGContextFillPath(ctx);
        }
            break;
            
        case JYIndicatorStyleLoopDiagram:
        {
            CGContextSetLineWidth(ctx, 4);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
            CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - kIndicatorViewItemMargin;
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
            CGContextStrokePath(ctx);
        }
            break;
            
        case JYIndicatorStyleStudioDiagram:
        {
            CGFloat radius = xCenter;
            CGContextAddArc(ctx, xCenter, yCenter, radius,0, M_PI * 2, 0);
            CGContextAddLineToPoint(ctx, xCenter, yCenter);
            CGContextClosePath(ctx);
            CGContextSetFillColor(ctx, CGColorGetComponents( [[UIColor colorWithWhite:1 alpha:0.5] CGColor]));
            CGContextFillPath(ctx);
            
            
            float angle_start = - M_PI_2;
            float angle_end = - M_PI_2 + self.progress * (2 * M_PI - M_PI_2);
        
            CGContextAddArc(ctx, xCenter, yCenter, radius - 3,  angle_start, angle_end, 0);
            CGContextAddLineToPoint(ctx, xCenter, yCenter);
            CGContextClosePath(ctx);
            CGContextSetFillColor(ctx, CGColorGetComponents( [[UIColor whiteColor] CGColor]));
            CGContextFillPath(ctx);
            
            self.layer.borderWidth = 2;
            self.layer.borderColor = [UIColor whiteColor].CGColor;
          
            
        }
            break;
            
    }
}

@end

//
//  JYAsynImageView.m
//  JYImageView
//
//  Created by weijingyun on 16/4/29.
//  Copyright © 2016年 weijingyun. All rights reserved.
//


#import "JYAsynImageView.h"
#import "YYAsyncLayer.h"
@interface JYAsynImageView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *currDisplayedImage;

@end

@implementation JYAsynImageView

- (void)setImage:(UIImage *)image{
    
    _image = image;
    [self redraw];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self transaction];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self transaction];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    [self transaction];
}

- (void)transaction{
    
    self.imageView.frame = self.bounds;
    
    if (self.currDisplayedImage == self.image) {
        return;
    }
    [self redraw];
}

- (void)redraw{
    
    self.imageView.frame = self.bounds;
    
    if (self.image == nil) {
        return;
    }
    
    if (self.image.size.width * self.image.size.height < self.limitLenght) {
        UIImage *image = self.image == nil ? self.thumbImage : self.image;
        self.imageView.hidden = NO;
        self.imageView.image = image;
        self.isAllowZoom = YES;
        return;
    }
    
    self.imageView.hidden = NO;
    self.isAllowZoom = NO;
    self.imageView.image = self.thumbImage;
    [[YYTransaction transactionWithTarget:self selector:@selector(contentsNeedUpdated)] commit];
}

- (void)contentsNeedUpdated {
    // do update
    [self layoutIfNeeded];
    [self.layer setNeedsDisplay];
}

#pragma mark - YYAsyncLayer
+ (Class)layerClass {
    return YYAsyncLayer.class;
}

- (YYAsyncLayerDisplayTask *)newAsyncDisplayTask {
    // capture current state to display task
    UIImage *image = self.image;
    return [self getAsyncLayerDisplayTaskByImage:image];
}

- (YYAsyncLayerDisplayTask *)getAsyncLayerDisplayTaskByImage:(UIImage *)image {
    
    YYAsyncLayerDisplayTask *task = [YYAsyncLayerDisplayTask new];
    __block CGRect rect = CGRectZero;
    __weak typeof(self) weakSelf = self;
    task.willDisplay = ^(CALayer *layer) {
        
        rect = [weakSelf frameForImageSize:image.size frameSize:weakSelf.frame.size];
        layer.bounds = rect;
        layer.position = weakSelf.center;
        CGFloat scale = [weakSelf scaleForImageSize:image.size frameSize:layer.frame.size];
        if (scale > 1.0) {
            layer.contentsScale = scale;
        }
    };
    
    task.display = ^(CGContextRef context, CGSize size, BOOL(^isCancelled)(void)) {
        if (isCancelled()) return;
        UIGraphicsPushContext(context);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIGraphicsPopContext();
        if (isCancelled()) return;
    };
    
    task.didDisplay = ^(CALayer *layer, BOOL finished) {
        
        if (finished) {
            // finished
            weakSelf.imageView.hidden = YES;
            weakSelf.isAllowZoom = YES;
            weakSelf.currDisplayedImage = image;
            if (weakSelf.image != image) { // 保证最后显示正确
                [weakSelf redraw];
            }
        } else {
            // cancelled
            NSLog(@"cancelled display");
        }
    };
    
    return task;
}

- (CGFloat)scaleForImageSize:(CGSize)imageSize frameSize:(CGSize)frameSize{
    
    CGFloat height = imageSize.height / imageSize.width * frameSize.width;
    if (height <= frameSize.height) {
        
        CGFloat scale = imageSize.width / frameSize.width;
        CGFloat kscale = [self limitLenght] / frameSize.width / frameSize.height / scale / scale;
        if (kscale < 1.0) {
            scale = scale * kscale;
        }
        return scale;
    }
    
    CGFloat width = imageSize.width / imageSize.height * frameSize.height;
    if (width <= frameSize.width) {
        CGFloat scale = imageSize.height / frameSize.height;
        CGFloat kscale = [self limitLenght] / frameSize.width / frameSize.height / scale / scale;
        if (kscale < 1.0) {
            scale = scale * kscale;
        }
        return scale;
    }
    
    return 1.0;
}

- (double)limitLenght{
    return 2000 * 2000;
}


- (CGRect)frameForImageSize:(CGSize)imageSize frameSize:(CGSize)frameSize{
    CGFloat height = imageSize.height / imageSize.width * frameSize.width;
    if (height <= frameSize.height) {
        CGRect frame = CGRectMake(0, (frameSize.height - height) * 0.5, frameSize.width, height);
        return frame;
    }
    
    CGFloat width = imageSize.width / imageSize.height * frameSize.height;
    if (width <= frameSize.width) {
        CGRect frame = CGRectMake((frameSize.width - width) * 0.5,0, width, frameSize.height);
        return frame;
    }
    return CGRectMake(0, 0, imageSize.width,imageSize.height);
}

#pragma mark - 懒加载
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
//        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self);
//        }];
        
    }
    return _imageView;
}


@end

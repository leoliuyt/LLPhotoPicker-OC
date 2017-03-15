//
//  JYImageScrollView.m
//  Demo
//
//  Created by weijingyun on 16/6/2.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import "JYImageScrollView.h"
#import "JYIndicatorView.h"
#import "JYAsynImageView.h"
//#import "ArtImageService.h"

#define asyn // 异步绘制暂时有问题

@interface JYImageScrollView ()<UIScrollViewDelegate>

#ifdef asyn
@property (nonatomic, strong) JYAsynImageView *zoomView;
#else
@property (nonatomic, strong) UIImageView *zoomView;
#endif

@property (nonatomic, assign) CGPoint pointToCenterAfterResize;
@property (nonatomic, assign) CGFloat scaleToRestoreAfterResize;

@property (nonatomic,strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic,strong) UITapGestureRecognizer *singleTap;

// 指示器
@property (nonatomic, strong) JYIndicatorView *indicatorView;

// 加载图
@property (nonatomic, strong) NSString *urlString;


@end

@implementation JYImageScrollView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        [self config];
    }
    return self;
}

- (void)config{
    //添加单双击事件
    [self addGestureRecognizer:self.doubleTap];
    [self addGestureRecognizer:self.singleTap];
}

#pragma mark 双击
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (!self.zoomView.isAllowZoom) {
        return;
    }
    CGPoint touchPoint = [recognizer locationInView:self];
    if (fabs(self.zoomScale - self.maximumZoomScale) > 0.0001) {
        CGFloat scale = self.zoomScale * 2.;
        if (scale > self.maximumZoomScale) {
            scale = self.maximumZoomScale;
        }
        CGRect zoomRect = [self zoomRectForScale:scale  withCenter:touchPoint];
        [self zoomToRect:zoomRect animated:YES];
        
    } else {
        CGRect zoomRect = [self zoomRectForScale:0.0001 withCenter:touchPoint];
        [self zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale ;
    zoomRect.size.width  = self.frame.size.width  / scale ;
    zoomRect.origin.x = center.x / self.zoomScale - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = center.y / self.zoomScale - (zoomRect.size.height /2.0);
    return zoomRect;
}

#pragma mark 单击
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    if ([self.tapDelegate respondsToSelector:@selector(imageScrollViewTap:)]) {
        [self.tapDelegate imageScrollViewTap:self];
    }
}

#pragma mrak - frame 改变
- (void)setFrame:(CGRect)frame {
    
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.zoomView.frame = frameToCenter;
}

#pragma mark - 显示图片
//- (void)setImageWithURL:(NSURL *)url{
//    [self setImageWithURLString:url.absoluteString];
//}
//
//- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder{
//    [self setImageWithURLString:url.absoluteString placeholderImage:placeholder];
//}
//
//- (void)setImageWithURLString:(NSString *)urlString {
//    [self setImageWithURLString:urlString placeholderImage:nil];
//}
//
//- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder  {
//    [self setImageWithURLString:urlString placeholderImage:placeholder completed:nil];
//}
//
//- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)placeholder completed:(void (^)(UIImage *,NSError *))aCompleted {
//
//    if (placeholder == nil) {
//        placeholder = [UIImage createImageWithColor:[UIColor colorWithRed:234./255. green:234./255. blue:234./255. alpha:1.0] size:CGSizeMake(48, 48)];
//    }
//    
//    if ([self.zoomView respondsToSelector:@selector(setThumbImage:)]) {
//        self.zoomView.thumbImage = placeholder;
//    }
//    
//    if ([urlString isEqualToString:self.urlString]) {
//        // 延时是为了在屏幕切换时 frame 还未改变过来的问题
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if (![urlString isEqualToString:self.urlString]) {
//                return;
//            }
//            [self displayImage:self.image];
//        });
//        return;
//    }
//
//    if (self.zoomView.image != placeholder) {
//        [self displayImage:placeholder];
//    }
//    self.urlString = urlString;
//    
//    __weak typeof(self)weakSelf = self;
//    if (![[ArtImageService shared] containsImageForURLString:urlString]) {
//        self.indicatorView.progress = 0.05;
//    }
//    
//    [[ArtImageService shared] downloadImageWithURL:urlString progress:^(CGFloat progress) {
//        if (![urlString isEqualToString:weakSelf.urlString]) {
//            return;
//        }
//        if (progress <= weakSelf.indicatorView.progress) {
//            return;
//        }
//        weakSelf.indicatorView.progress = progress;
//    } completed:^(UIImage *image, NSError *aError) {
//        
//        if (![urlString isEqualToString:weakSelf.urlString]) {
//            return;
//        }
//        [weakSelf.indicatorView removeFromSuperview];
//        weakSelf.indicatorView = nil;
//        
//        if (aError != nil) {
//            if ([weakSelf.tapDelegate respondsToSelector:@selector(imageDownLoadfailed:error:)]) {
//                [weakSelf.tapDelegate imageDownLoadfailed:weakSelf error:aError];
//            }
//            [weakSelf displayImage:placeholder];
//            if (aCompleted) {
//                aCompleted(nil,aError);
//            }
//            return;
//        }
//        
//        [weakSelf displayImage:image];
//        if (aCompleted) {
//            aCompleted(image,nil);
//        }
//        
//    }];
//}

- (void)setImage:(UIImage *)aImage{
    if (aImage != self.image) {
        [self displayImage:aImage];
    }
}

- (UIImage *)image{
    return self.zoomView.image;
}

- (void)displayImage:(UIImage *)image{
    
    if (image == nil) {
        return;
    }
    
    if (self.bounds.size.width < 1) {
        // 把高度搞出来
        self.zoomView.image = image;
       [self scrollViewDidZoom:self];
        [self.superview layoutIfNeeded];
    }
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    // make a new UIImageView for the new image
    self.zoomView.image = image;
//    CGSize imageSize = self.imageSize.width > 0 ? self.imageSize : image.size;
#pragma mark - 计算 保证最小
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = image.size;
    // 计算 min/max zoomscale
    CGFloat xScale = boundsSize.width  / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;   // the scale needed to perfectly fit the image height-wise
    CGFloat sc = MIN(xScale, yScale);
    imageSize = CGSizeMake(sc * imageSize.width, sc * imageSize.height);
    
    [self configureForImageSize:imageSize];
}



#pragma mark - 缩放 大小计算设置
- (void)configureForImageSize:(CGSize)imageSize
{
    self.zoomView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    if (self.bounds.size.width == 0) {
        [self.superview layoutIfNeeded];
    }
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageSize.width > 0 ? self.imageSize : self.image.size;
    // 计算 min/max zoomscale
    CGFloat xScale = boundsSize.width  / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    
//    CGFloat minScale =  MIN(xScale, yScale);
    // maximum zoom scale to 0.5. 考虑高分辨率屏幕
    CGFloat maxScale = 1.0;// / [UIScreen mainScreen].scale;
    CGFloat calculateMaxScale = MAX(2, MAX(xScale, yScale));
    self.maximumZoomScale =  MAX(calculateMaxScale, maxScale);
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    [self scrollViewDidZoom:self];
    
//    
//    // 应该展现的尺寸
//    CGFloat currentScale =  MIN(xScale, yScale); //imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
//    
//    // 图片的真实尺寸 maximum zoom scale to 0.5. 考虑高分辨率屏幕
//    CGFloat originalScale = 1.0 / [UIScreen mainScreen].scale;
//    
//    // 计算的最大最小尺寸
//    CGFloat calculateMinScale = currentScale * 0.5;
//    CGFloat calculateMaxScale = currentScale * 2.;
//    
//    self.maximumZoomScale = MAX(currentScale + 0.1, originalScale);
//    self.minimumZoomScale = currentScale;//MIN(currentScale, originalScale);
//    self.zoomScale = currentScale;
}

#pragma mark - frame改变后的调整 如 旋转
- (void)prepareToResize {
    
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.zoomView];
    
    self.scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (self.scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON){
        self.scaleToRestoreAfterResize = 0;
    }
}

- (void)recoverFromResizing {
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
    //第一步:恢复缩放尺度,首先确保在允许的范围内。
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, self.scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    //第二步:恢复中心点,首先确保在允许的范围内。
    
    // 2a: 把我们所需的中心指向自己的坐标空间
    CGPoint boundsCenter = [self convertPoint:self.pointToCenterAfterResize fromView:self.zoomView];
    
    // 2b: 计算内容中心点的偏移量
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: 恢复抵消,在允许的范围内调整
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset {
    
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    
    return CGPointZero;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{

    if (!self.zoomView.isAllowZoom) {
        return nil;
    }
    return self.zoomView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = self.zoomView.frame;
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    // center horizontally
    if (imgFrame.size.width <= boundsSize.width)
    {
        centerPoint.x = boundsSize.width/2;
    }
    // center vertically
    if (imgFrame.size.height <= boundsSize.height)
    {
        centerPoint.y = boundsSize.height/2;
    }
    self.zoomView.center = centerPoint;
}

#pragma mark - 懒加载
#ifdef asyn
- (JYAsynImageView *)zoomView{
    if (!_zoomView) {
        _zoomView = [[JYAsynImageView alloc] init];
        [self addSubview:_zoomView];
    }
    return _zoomView;
}
#else
- (UIImageView *)zoomView{
    if (!_zoomView) {
        _zoomView = [[UIImageView alloc] init];
        [self addSubview:_zoomView];
    }
    return _zoomView;
}

#endif

- (JYIndicatorView *)indicatorView{

    if (!_indicatorView) {
    
        _indicatorView = [[JYIndicatorView alloc] init];
        _indicatorView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
        UIView *view = self.superview == nil ? self : self.superview;
        [view addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UITapGestureRecognizer *)doubleTap
{
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired  =1;
    }
    return _doubleTap;
}

- (UITapGestureRecognizer *)singleTap
{
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
        //只能有一个手势存在
        [_singleTap requireGestureRecognizerToFail:self.doubleTap];
        
    }
    return _singleTap;
}

@end

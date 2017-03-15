//
//  LLCustomCropViewController.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLCustomCropViewController.h"
#import "LLTrimHoleView.h"

static CGFloat kMarginTop = 20.;
static CGFloat kMarginBottom = 72.;

@interface LLCustomCropViewController()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *frameView;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, assign) CGRect contentBounds;
@property (nonatomic, strong) LLTrimHoleView *underlayerView;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation LLCustomCropViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(kMarginBottom);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.bottomView);
        make.left.equalTo(self.bottomView).offset(kMarginBottom);
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.bottomView);
        make.right.equalTo(self.bottomView).offset(-kMarginBottom);
    }];
    
    CGFloat width = SCREEN_H - (kMarginTop + kMarginBottom);
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(width / self.cropScale);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
    [self.view addSubview:self.frameView];
    
    [self.frameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(width);
        make.height.equalTo(width / self.cropScale);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
    [self.view addSubview:self.underlayerView];
    [self.underlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutScrollView];
    
    self.underlayerView.holePath = [UIBezierPath bezierPathWithRect:self.frameView.frame];
    self.underlayerView.viewColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.underlayerView setNeedsDisplay];
}

- (BOOL)hiddenNavigation
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)layoutScrollView
{
    self.imageView.image = self.sourceImage;
    self.imageView.frame = CGRectMake(0, 0, self.sourceImage.size.width, self.sourceImage.size.height);
    
    CGSize imageSize = self.sourceImage.size;
    self.scrollView.frame = self.contentBounds;
    self.scrollView.contentSize = imageSize;
    [self.scrollView addSubview:self.imageView];
    
    CGFloat scale = 0.0f;
    
    // 计算 图片适应屏幕的 size
    CGSize cropBoxSize = self.frameView.bounds.size;
    
    //以cropboxsize 宽或者高最大的那个为基准
    scale = MAX(cropBoxSize.width/imageSize.width, cropBoxSize.height/imageSize.height);
    
    //按照比例算出初次展示的尺寸
    CGSize scaledSize = (CGSize){floorf(imageSize.width * scale), floorf(imageSize.height * scale)};
    
    //配置scrollview
    self.scrollView.minimumZoomScale = scale;
    self.scrollView.maximumZoomScale = 5.0f;
    
    //初始缩放系数
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    self.scrollView.contentSize = scaledSize;
    
    CGRect cropBoxFrame = self.frameView.frame;
    //调整位置 使其居中
    if (cropBoxFrame.size.width < scaledSize.width - FLT_EPSILON || cropBoxFrame.size.height < scaledSize.height - FLT_EPSILON) {
        CGPoint offset = CGPointZero;
        offset.x = -floorf((CGRectGetWidth(self.scrollView.frame) - scaledSize.width) * 0.5f);
        offset.y = -floorf((CGRectGetHeight(self.scrollView.frame) - scaledSize.height) * 0.5f);
        self.scrollView.contentOffset = offset;
    }
    
    // 以cropBoxFrame为基准设施 scrollview 的insets 使其与cropBoxFrame 匹配 防止 缩放时突变回顶部
    self.scrollView.contentInset = (UIEdgeInsets){CGRectGetMinY(cropBoxFrame),
        CGRectGetMinX(cropBoxFrame),
        CGRectGetMaxY(self.view.bounds) - CGRectGetMaxY(cropBoxFrame),
        CGRectGetMaxX(self.view.bounds) - CGRectGetMaxX(cropBoxFrame)};
}

//最后裁剪时图片位置确定
- (CGRect)imageCropFrame
{
    CGSize imageSize = self.imageView.image.size;
    CGSize contentSize = self.scrollView.contentSize;
    CGRect cropBoxFrame = self.frameView.frame;
    CGPoint contentOffset = self.scrollView.contentOffset;
    UIEdgeInsets edgeInsets = self.scrollView.contentInset;
    
    CGRect frame = CGRectZero;
    frame.origin.x = floorf((contentOffset.x + edgeInsets.left) * (imageSize.width / contentSize.width));
    frame.origin.x = MAX(0, frame.origin.x);
    
    frame.origin.y = floorf((contentOffset.y + edgeInsets.top) * (imageSize.height / contentSize.height));
    frame.origin.y = MAX(0, frame.origin.y);
    
    frame.size.width = ceilf(cropBoxFrame.size.width * (imageSize.width / contentSize.width));
    frame.size.width = MIN(imageSize.width, frame.size.width);
    
    frame.size.height = ceilf(cropBoxFrame.size.height * (imageSize.height / contentSize.height));
    frame.size.height = MIN(imageSize.height, frame.size.height);
    
    return frame;
}

- (void)saveAction:(id)sender
{
    UIImage *image = [self.imageView.image croppedImageWithFrame:[self imageCropFrame]];
    if ([self.delegate respondsToSelector:@selector(imageCrop:didFinished:)]) {
        [self.delegate imageCrop:self didFinished:image];
    }
}

- (void)cancelAction:(id)sender
{
    if (self.navigationController.viewControllers.count > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if ([self.delegate respondsToSelector:@selector(imageCropDidCancel:)]) {
            [self.delegate imageCropDidCancel:self];
        }
    }
}

- (void)retryPhotoAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(imageCropDidRetry:)]) {
        [self.delegate imageCropDidRetry:self];
    }
}
- (CGFloat)cropScale
{
    if (_cropScale < 0.00001) {
        //        return 16.0/9.0;
        //      return 8.0/5.0;
        return 71./40.;
    }
    return _cropScale;
}

- (void)setSourceImage:(UIImage *)sourceImage
{
    _sourceImage = sourceImage;
}

- (CGRect)contentBounds
{
    return CGRectMake(0, kMarginTop, SCREEN_W, SCREEN_H - kMarginTop - kMarginBottom);
}

//MARK: UIScrollviewdelgate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//MARK: Lazy Load
- (UIScrollView *)scrollView
{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if(!_imageView){
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}


- (UIImageView *)frameView
{
    if(!_frameView){
        _frameView = [[UIImageView alloc]init];
        UIImage *image = [UIImage imageNamed:@"icon_frame"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
        _frameView.image = image;
        _frameView.backgroundColor = [UIColor clearColor];
    }
    return _frameView;
}

- (UIButton *)saveBtn
{
    if(!_saveBtn){
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"使用照片" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:18.];
        @weakify(self);
        [[_saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self saveAction:nil];
        }];
        [self.bottomView addSubview:_saveBtn];
    }
    return _saveBtn;
}

- (UIButton *)cancelBtn
{
    if(!_cancelBtn){
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if(self.type == ELLSeletPhotoTypeCamera) {
            [_cancelBtn setTitle:@"重拍" forState:UIControlStateNormal];
        } else {
            [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        }
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18.];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        @weakify(self);
        [[_cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.type == ELLSeletPhotoTypeCamera) {
                [self retryPhotoAction:nil];
            } else {
                [self cancelAction:nil];
            }
        }];
        [self.bottomView addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

- (LLTrimHoleView *)underlayerView
{
    if(!_underlayerView){
        _underlayerView = [[LLTrimHoleView alloc] init];
        _underlayerView.backgroundColor = [UIColor clearColor];
        _underlayerView.viewColor = [UIColor colorWithWhite:0. alpha:0.4];
        _underlayerView.userInteractionEnabled = NO;
        [self.view addSubview:_underlayerView];
    }
    return _underlayerView;
}

- (UIView *)bottomView
{
    if(!_bottomView){
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

@end


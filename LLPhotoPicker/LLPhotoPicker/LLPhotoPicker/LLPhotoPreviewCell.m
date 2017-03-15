//
//  LLPhotoPreviewCell.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoPreviewCell.h"
#import "JYImageScrollView.h"

@interface LLPhotoPreviewCell()

@property (nonatomic, strong) JYImageScrollView *scrollView;

@end

@implementation LLPhotoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self configUI];
    }
    return self;
}

- (void)configUI{
    self.scrollView = [[JYImageScrollView alloc] init];
    [self.contentView addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self configBackgroundColor:[UIColor whiteColor]];
}

- (void)configBackgroundColor:(UIColor *)color {
    self.backgroundColor = color;
    self.contentView.backgroundColor = color;
    self.scrollView.backgroundColor = color;
}

- (void)setImage:(UIImage *)aImage {
    if (aImage != self.scrollView.image) {
        self.scrollView.image = aImage;
    }
}

@end


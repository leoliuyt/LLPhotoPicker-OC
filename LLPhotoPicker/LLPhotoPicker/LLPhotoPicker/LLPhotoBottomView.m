//
//  LLPhotoBottomView.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoBottomView.h"
#import "LLPhotoPickerService.h"
#import "LLPhotoPickerConfig.h"

@interface LLPhotoBottomView()

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIButton *originBtn;
@property (nonatomic, strong) UIButton *sendCoverBtn;

@property (nonatomic, assign) BOOL isOrigin;

@end

@implementation LLPhotoBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self makeUI];
    @weakify(self);
    [RACObserve([LLPhotoPickerService shared],selectedCount) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x integerValue] > 0) {
            self.countLabel.hidden = NO;
            self.sendBtn.enabled = YES;
            self.sendCoverBtn.enabled = YES;
            self.countLabel.transform = CGAffineTransformMakeScale(0.5, 0.5);
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.countLabel.transform = CGAffineTransformIdentity;
            } completion:nil];
            self.countLabel.text = [NSString stringWithFormat:@"%tu",x.integerValue];
        } else {
            self.countLabel.hidden = YES;
            self.sendBtn.enabled = NO;
            self.sendCoverBtn.enabled = NO;
        }
        
    }];
    
    return self;
}

- (void)makeUI {
    self.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20.);
        make.top.bottom.equalTo(self);
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sendBtn.mas_left).offset(-5.);
        make.width.height.equalTo(20.);
        make.centerY.equalTo(self);
    }];
    
    [self.originBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.countLabel.mas_left).offset(-44.);
        make.top.bottom.equalTo(self);
    }];
    
    [self.sendCoverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self.countLabel.mas_left);
        make.right.equalTo(self).offset(-20.);
    }];
}

- (void)originHidden:(BOOL)hide
{
    self.originBtn.hidden = hide;
}

+ (CGFloat)height {
    return 44.;
}

//MARK: lazy
- (UILabel *)countLabel
{
    if(!_countLabel){
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = [UIColor colorWithHexString:@"32BD77"];
        _countLabel.layer.cornerRadius = 10.;
        _countLabel.clipsToBounds = YES;
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_countLabel];
    }
    return _countLabel;
}

- (UIButton *)sendBtn
{
    if(!_sendBtn){
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"完成" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15.];
        [_sendBtn setTitleColor:[UIColor colorWithHexString:@"32BD77"] forState:UIControlStateNormal];
        //        WEAKSELF(weakSelf);
        //        [[_sendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
        //            NSLog(@"完成");
        //            if ([weakSelf.delegate respondsToSelector:@selector(photoPickerDidSend:)]) {
        //                [weakSelf.delegate photoPickerDidSend:weakSelf.isOrigin];
        //            }
        //        }];
        [self addSubview:_sendBtn];
    }
    return _sendBtn;
}


- (UIButton *)sendCoverBtn
{
    if(!_sendCoverBtn){
        _sendCoverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendCoverBtn setTitleColor:[UIColor colorWithHexString:@"32BD77"] forState:UIControlStateNormal];
        WEAKSELF(weakSelf);
        [[_sendCoverBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
            NSLog(@"完成");
            if ([weakSelf.delegate respondsToSelector:@selector(photoPickerDidSend:)]) {
                [weakSelf.delegate photoPickerDidSend:weakSelf.isOrigin];
            }
        }];
        [self addSubview:_sendCoverBtn];
    }
    return _sendCoverBtn;
}
- (UIButton *)originBtn
{
    if(!_originBtn){
        _originBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_originBtn setTitle:@"原图" forState:UIControlStateNormal];
        _originBtn.titleLabel.font = [UIFont systemFontOfSize:15.];
        [_originBtn setImage:[UIImage imageNamed:@"picker_original"] forState:UIControlStateNormal];
        [_originBtn setImage:[UIImage imageNamed:@"picker_original_selected"] forState:UIControlStateSelected];
        [_originBtn setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateNormal];
        _originBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        _originBtn.selected = [LLPhotoPickerConfig shared].isOriginal;
        WEAKSELF(weakSelf);
        [[_originBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
            NSLog(@"原图");
            x.selected = !x.selected;
            weakSelf.isOrigin = x.selected;
            [LLPhotoPickerConfig shared].isOriginal = weakSelf.isOrigin;
            if ([weakSelf.delegate respondsToSelector:@selector(photoPickerDidSelectOrigin:)]) {
                [weakSelf.delegate photoPickerDidSelectOrigin:x.isSelected];
            }
        }];
        [self addSubview:_originBtn];
    }
    return _originBtn;
}
@end

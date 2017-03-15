//
//  LLPhotoTopView.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoTopView.h"
#import "LLPhotoPickerService.h"
#import "LLPhotoPickerConfig.h"

@interface LLPhotoTopView()

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *selectIconBtn;

@property (nonatomic, assign) BOOL isOrigin;

@end

@implementation LLPhotoTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self makeUI];
    return self;
}

- (void)makeUI {
    self.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15.);
        make.top.equalTo(self).offset(20.);
        make.bottom.equalTo(self);
    }];
    
    [self.selectIconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20.);
        make.top.equalTo(self).offset(20.);
        make.bottom.equalTo(self);
        make.width.equalTo(44.);
    }];
}

- (void)updateSelected:(BOOL)isSelected
{
    //    self.selectBtn.selected = isSelected;
    self.selectIconBtn.selected = isSelected;
}

+ (CGFloat)height {
    return 64.;
}

- (void)hideSelectBtn:(BOOL)hide
{
    self.selectIconBtn.hidden = hide;
}

//MARK: lazy
- (UIButton *)backBtn
{
    if(!_backBtn){
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"viewController_common_LightBack"] forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:15.];
        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        WEAKSELF(weakSelf);
        [[_backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
            NSLog(@"完成");
            if ([weakSelf.delegate respondsToSelector:@selector(photoPickerBack)]) {
                [weakSelf.delegate photoPickerBack];
            }
        }];
        [self addSubview:_backBtn];
    }
    return _backBtn;
}
- (UIButton *)selectIconBtn
{
    if(!_selectIconBtn){
        _selectIconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectIconBtn setImage:[UIImage imageNamed:@"picker_select_selected_black"] forState:UIControlStateNormal];
        [_selectIconBtn setImage:[UIImage imageNamed:@"picker_select_selected"] forState:UIControlStateSelected];
        WEAKSELF(weakSelf);
        [[_selectIconBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
            if (!x.isSelected) {
                if ([LLPhotoPickerService shared].selectedCount >= [LLPhotoPickerConfig shared].maxSelectedCount) {
                    //show alert
                    //                    if([weakSelf.delegate respondsToSelector:@selector(didSeletedMoreThanMax)]) {
                    //                        [weakSelf.delegate didSeletedMoreThanMax];
                    //                    }
                    NSString *subMessage = [LLPhotoPickerConfig shared].resourceType == ELLAssetResourceTypeVideo ? @"个视频" : @"张图片";
                    NSString *message = [NSString stringWithFormat:@"最多只能选择%tu%@",[LLPhotoPickerConfig shared].maxSelectedCount,subMessage];
//                    [LLProgressHUD showInfoWithStatus:message];
                    return;
                }
            }
            x.selected = !x.isSelected;
            if (x.isSelected) {
                [[LLPhotoPickerService shared] addAsset:weakSelf.asset];
            } else {
                [[LLPhotoPickerService shared] removeAsset:weakSelf.asset];
            }
        }];
        [self addSubview:_selectIconBtn];
    }
    return _selectIconBtn;
}
@end


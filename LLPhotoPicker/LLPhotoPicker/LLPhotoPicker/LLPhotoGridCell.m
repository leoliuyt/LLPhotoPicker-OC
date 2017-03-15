//
//  LLPhotoGridCell.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoGridCell.h"

#import "LLPhotoPickerConfig.h"
#import "LLPhotoPickerService.h"

@interface LLPhotoGridCell()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIButton *selectIconBtn;
//@property (nonatomic, strong) UIButton *selectBtn;

@end
@implementation LLPhotoGridCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self makeUI];
    }
    return self;
}

- (void)makeUI
{
    self.layer.cornerRadius = 4.;
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.selectIconBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.width.height.equalTo(46.);
    }];
}

- (void)setAsset:(PHAsset *)asset
{
    _asset = asset;
}

- (void)updateSelected:(BOOL)isSelected
{
    self.selectIconBtn.selected = isSelected;
}

- (void)hideSeletedBtn:(BOOL)hide
{
    self.selectIconBtn.hidden = hide;
}

//MARK: lazy
- (UIImageView *)photoImageView
{
    if(!_photoImageView){
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.layer.cornerRadius = 4;
        _photoImageView.clipsToBounds = YES;
        _photoImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_photoImageView];
    }
    return _photoImageView;
}

- (UIButton *)selectIconBtn
{
    if(!_selectIconBtn){
        _selectIconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectIconBtn setImage:[UIImage imageNamed:@"picker_select_normal"] forState:UIControlStateNormal];
        [_selectIconBtn setImage:[UIImage imageNamed:@"picker_select_selected"] forState:UIControlStateSelected];
        WEAKSELF(weakSelf);
        [[_selectIconBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
            if (!x.isSelected) {
                if ([LLPhotoPickerService shared].selectedCount >= [LLPhotoPickerConfig shared].maxSelectedCount) {
                    //show alert
                    if([weakSelf.delegate respondsToSelector:@selector(didSeletedMoreThanMax)]) {
                        [weakSelf.delegate didSeletedMoreThanMax];
                    }
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
        [self.contentView addSubview:_selectIconBtn];
    }
    return _selectIconBtn;
}

@end


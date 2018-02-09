//
//  LLPhotoGroupCell.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoGroupCell.h"
#import "LLPhotoGroupModel.h"
#import "LLPhotoPickerService.h"
#import "LLPhotoPickerConfig.h"
@interface LLPhotoGroupCell()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) UILabel *albumLabel;
@property (nonatomic, strong) UILabel *photoCountLabel;

@end
@implementation LLPhotoGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self makeUI];
    return self;
}

- (void)makeUI {
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(10.);
        make.width.height.equalTo(70.);
    }];
    
    [self.albumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(10.);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.photoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.albumLabel.mas_right).offset(10.);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-20.);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)setCellContent:(LLPhotoGroupModel *)aCellContent
{
    self.albumLabel.text = aCellContent.albumName;
    
    NSInteger count = [LLPhotoPickerConfig shared].resourceType == ELLAssetResourceTypeVideo ? [aCellContent.groupFetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo] : aCellContent.groupFetchResult.count;
    self.photoCountLabel.text = [NSString stringWithFormat:@"(%tu)",count];
    PHAsset *firstAsset = aCellContent.groupFetchResult.firstObject;
    if (firstAsset) {
        WEAKSELF(weakSelf);
        [[LLPhotoPickerService shared] requestLowQualityImageForAsset:firstAsset size:CGSizeMake(90, 90) exactSize:YES completion:^(UIImage *aImage, NSDictionary *aInfo, BOOL isDegraded) {
            weakSelf.coverImageView.image = aImage;
        }];
    }
}

+ (CGFloat)height {
    return 90.;
}

//MARK: lazy
- (UIImageView *)coverImageView
{
    if(!_coverImageView){
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.layer.cornerRadius = 4.;
        _coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UIImageView *)arrow
{
    if(!_arrow){
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"picker_arrow_right"];
        [self.contentView addSubview:_arrow];
    }
    return _arrow;
}

- (UILabel *)albumLabel
{
    if(!_albumLabel){
        _albumLabel = [[UILabel alloc] init];
        _albumLabel.font = [UIFont systemFontOfSize:16.];
        _albumLabel.textColor = [UIColor colorWithHexString:@"333333"];
        [self.contentView addSubview:_albumLabel];
    }
    return _albumLabel;
}

- (UILabel *)photoCountLabel
{
    if(!_photoCountLabel){
        _photoCountLabel = [[UILabel alloc] init];
        _photoCountLabel.font = [UIFont systemFontOfSize:16.];
        _photoCountLabel.textColor = [UIColor colorWithHexString:@"999999"];
        [self.contentView addSubview:_photoCountLabel];
    }
    return _photoCountLabel;
}

@end


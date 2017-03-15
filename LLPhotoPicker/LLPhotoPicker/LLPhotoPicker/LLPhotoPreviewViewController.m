//
//  LLPhotoPreviewViewController.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//
#import "LLPhotoPreviewViewController.h"
#import "LLPhotoPreviewCell.h"
#import "LLPhotoBottomView.h"
#import "LLPhotoPickerService.h"
#import "LLPhotoPickerConfig.h"
//#import "UIImage+LL.h"
#import "LLPhotoTopView.h"

#define kPhotoPreviewIdentify NSStringFromClass([LLPhotoPreviewCell class])

@interface LLPhotoPreviewViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,LLPhotoBottomViewDelegate,LLPhotoTopViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LLPhotoBottomView *bottomView;
@property (nonatomic, strong) LLPhotoTopView *topView;

@end

@implementation LLPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self makeUI];
    [self configure];
    
    @weakify(self);
    [[RACObserve(self, currentIndex) distinctUntilChanged]subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if(self.collectionView.visibleCells.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:x.integerValue inSection:0];
            PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
            self.topView.asset = asset;
            if([LLPhotoPickerConfig shared].isMutableSelect) {
                [self.topView updateSelected:[[LLPhotoPickerService shared] containSelectedAsset:asset]];
            } else {
                [self.topView hideSelectBtn:YES];
            }
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.collectionView.visibleCells.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
        self.topView.asset = asset;
        if([LLPhotoPickerConfig shared].isMutableSelect) {
            [self.topView updateSelected:[[LLPhotoPickerService shared] containSelectedAsset:asset]];
        } else {
            [self.topView hideSelectBtn:YES];
        }
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        [UIView animateWithDuration:0.2 delay:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.collectionView.alpha = 1.0;
        } completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.alpha = 0;
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo([LLPhotoTopView height]);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo([LLPhotoBottomView height]);
    }];
    
    [self.collectionView registerClass:[LLPhotoPreviewCell class] forCellWithReuseIdentifier:kPhotoPreviewIdentify];
}

- (void)configure
{
     [self.bottomView originHidden:YES];
}

- (BOOL)hiddenNavigation
{
    return YES;
}

//- (void)cancelAction:(id)sender {
//    [[LLPhotoPickerService shared] removeAllAsset];
//    [[LLPhotoPickerService shared] removeAllCachedObjects];
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//}

//MARK: LLPhotoBottomViewDelegate
- (void)photoPickerDidSend:(BOOL)isOrigin
{
    if ([LLPhotoPickerService shared].selectedCount < [LLPhotoPickerConfig shared].minSelectedCount) {
        NSLog(@"alert");
        NSString *message = [NSString stringWithFormat:@"最少选择%tu张图片",[LLPhotoPickerConfig shared].minSelectedCount];
//        [self showText:message];
        return;
    }
    
    if ([LLPhotoPickerConfig shared].resourceType == ELLAssetResourceTypeAll) {
        if([self.delegate respondsToSelector:@selector(photoPreviewDidSendPhotos:origin:)]) {
            [self.delegate photoPreviewDidSendPhotos:[[LLPhotoPickerService shared].selectedAssets copy] origin:isOrigin];
        }
    }
}

- (void)photoPickerDidSelectOrigin:(BOOL)selectedOrigin
{
    PHAsset *asset = [self.fetchResult objectAtIndex:self.currentIndex];
    if (selectedOrigin) {
        if(![[LLPhotoPickerService shared] containSelectedAsset:asset]) {
            if ([LLPhotoPickerService shared].selectedCount >= [LLPhotoPickerConfig shared].maxSelectedCount) {
                NSString *subMessage = [LLPhotoPickerConfig shared].resourceType == ELLAssetResourceTypeVideo ? @"个视频" : @"张图片";
                NSString *message = [NSString stringWithFormat:@"最多只能选择%tu%@",[LLPhotoPickerConfig shared].maxSelectedCount,subMessage];
//                [LLProgressHUD showInfoWithStatus:message];
                return;
            }
            [[LLPhotoPickerService shared] addAsset:asset];
            [self.topView updateSelected:YES];
        }
    }
}
//MARK: LLPhotoTopViewDelegate
- (void)photoPickerBack
{
    if (self.previewGoBack) {
        self.previewGoBack();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLPhotoPreviewCell *cell = (LLPhotoPreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotoPreviewIdentify forIndexPath:indexPath];
    PHAsset *asset = nil;
    if (indexPath.row < self.fetchResult.count) {
        asset = [self.fetchResult objectAtIndex:indexPath.row];
        cell.representedAssetIdentifier = asset.localIdentifier;
        [[LLPhotoPickerService shared] requestPreviewImageForAsset:asset withCompletion:^(UIImage *aImage, NSDictionary *info, BOOL isDegraded) {
            if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                [cell setImage:aImage];
            }
        }];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    self.currentIndex = indexPath.row;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentIndex = (NSInteger)(scrollView.contentOffset.x / self.view.bounds.size.width);
}


//MARK: lazy
- (UICollectionView *)collectionView
{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing          = 0.0;
        layout.minimumInteritemSpacing     = 0.0;
        layout.itemSize = self.view.bounds.size;
        layout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (LLPhotoBottomView *)bottomView
{
    if(!_bottomView){
        _bottomView = [[LLPhotoBottomView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"F2F2F2" alpha:0.6];
        [_bottomView originHidden:YES];
        _bottomView.delegate = self;
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (LLPhotoTopView *)topView
{
    if(!_topView){
        _topView = [[LLPhotoTopView alloc] init];
        //        _topView.backgroundColor = [UIColor colorWithHexString:@"32BD77" alpha:0.8];
        _topView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        _topView.delegate = self;
        [self.view addSubview:_topView];
    }
    return _topView;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end

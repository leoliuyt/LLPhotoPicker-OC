//
//  LLPhotoGroupViewController.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "LLPhotoGroupViewController.h"
#import "LLPhotoGroupCell.h"
#import "LLPhotoGroupModel.h"
#import "LLPhotoPickerConfig.h"
#import "LLPhotoGridViewController.h"
#import "LLPhotoPickerService.h"

#define kGroupIdentifier  NSStringFromClass([LLPhotoGroupCell class])

@interface LLPhotoGroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<LLPhotoGroupModel *> *albums;

@end

@implementation LLPhotoGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.albums = [NSMutableArray array];
    [self makeUI];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeUI
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.tableView.rowHeight = [LLPhotoGroupCell height];
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.estimatedRowHeight = [LLPhotoGroupCell height];
    self.tableView.estimatedSectionHeaderHeight = 0.0;
    self.tableView.estimatedSectionFooterHeight = 0.0;
    [self registerCell];
}

- (void)registerCell
{
    [self.tableView registerClass:[LLPhotoGroupCell class] forCellReuseIdentifier:kGroupIdentifier];
}

- (void)loadData {
    [self.albums removeAllObjects];
    
    // 获取所有资源的集合，并按资源的创建时间排序
    //    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    //    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:[LLPhotoPickerConfig shared].fetchOptions];
    LLPhotoGroupModel *model = [[LLPhotoGroupModel alloc] init];
    model.groupFetchResult = assetsFetchResults;
    model.albumName = self.resourceType == ELLAssetResourceTypeVideo ? @"全部视频":@"全部照片";
    [self.albums addObject:model];
    //智能相册
    PHFetchResult<PHAssetCollection *> *smLLResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smLLResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            [self filterFetchResult:obj];
        }
    }];
    
    // 用户创建的相册
    // 列出所有用户创建的相册
    PHFetchResult<PHCollection *> *userResult = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    [userResult enumerateObjectsUsingBlock:^(PHCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = (PHAssetCollection *)obj;
        [self filterFetchResult:collection];
    }];
    
    [self.tableView reloadData];
}

- (void)filterFetchResult:(PHAssetCollection *)collection {
    PHFetchResult<PHAsset *>*result = [PHAsset fetchAssetsInAssetCollection:collection options:[LLPhotoPickerConfig shared].fetchOptions];
    if ([LLPhotoPickerConfig shared].resourceType == ELLAssetResourceTypeVideo) {
        if ([result countOfAssetsWithMediaType:PHAssetMediaTypeVideo] > 0) {
            LLPhotoGroupModel *model = [[LLPhotoGroupModel alloc] init];
            model.groupFetchResult = result;
            model.albumName = collection.localizedTitle;
            [self.albums addObject:model];
        }
    } else {
        if (result.count > 0) {
            LLPhotoGroupModel *model = [[LLPhotoGroupModel alloc] init];
            model.groupFetchResult = result;
            model.albumName = collection.localizedTitle;
            [self.albums addObject:model];
        }
    }
    
}

- (void)cancelAction:(id)sender {
    self.gridDelegate = nil;
    [[LLPhotoPickerService shared] removeAllAsset];
    [[LLPhotoPickerService shared] removeAllCachedObjects];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setResourceType:(ELLAssetResourceType)resourceType
{
    _resourceType = resourceType;
    self.title = resourceType == ELLAssetResourceTypeVideo ? @"视频":@"照片";
}

//MARK: UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LLPhotoGroupCell *cell = (LLPhotoGroupCell *)[tableView dequeueReusableCellWithIdentifier:kGroupIdentifier];
    LLPhotoGroupModel *model = nil;
    if (indexPath.row < self.albums.count) {
        model = [self.albums objectAtIndex:indexPath.row];
    }
    [cell setCellContent:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LLPhotoGroupModel *model = nil;
    if (indexPath.row < self.albums.count) {
        model = [self.albums objectAtIndex:indexPath.row];
    }
    LLPhotoGridViewController *gridVC = [[LLPhotoGridViewController alloc] init];
    gridVC.fetchResult = model.groupFetchResult;
    gridVC.title = model.albumName;
    gridVC.delegate = self.gridDelegate;
    [self.navigationController pushViewController:gridVC animated:YES];
}

//MARK: lazy
- (UITableView *)tableView
{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end

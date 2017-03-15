//
//  ViewController.m
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "ViewController.h"
#import "LLPhotoPickerService.h"
#import "LLPhotoPickerViewController.h"
#import "LLCustomCropViewController.h"

@interface ViewController ()<LLPhotoPickerViewControllerDelegate,LLCustomCropVCDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterAction:(id)sender {
    WEAKSELF(weakSelf);
    [LLPhotoPickerService requestAuthorization:^() {
        LLPhotoPickerViewController *vc = [[LLPhotoPickerViewController alloc] init];
        vc.showType = ELLPickerShowTypeDefault;
        vc.maximumNumberOfSelection = 3;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        vc.pickerDelegate = weakSelf;
        [weakSelf presentViewController:vc animated:YES completion:nil];
    }];
}

- (void)photoPicker:(LLPhotoPickerViewController *)pickerVC didSelectedPhotos:(NSArray<PHAsset *> *)photos origin:(BOOL)isOrigin
{
    PHAsset *asset = photos.firstObject;
    WEAKSELF(weakSelf);
    [[LLPhotoPickerService shared] requestOriginImageForAsset:asset completion:^(UIImage *aImage, NSDictionary *aDict, BOOL isDegraded) {
        if (!isDegraded) {
            weakSelf.coverImageView.image = aImage;
//            LLCustomCropViewController *cropVc = [[LLCustomCropViewController alloc] init];
//            cropVc.type = ELLSeletPhotoTypeAlbum;
//            cropVc.cropScale = 1.;
//            cropVc.sourceImage = aImage;
//            cropVc.delegate = weakSelf;
//            [pickerVC pushViewController:cropVc animated:YES];
        }
    }];
    [pickerVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCrop:(LLCustomCropViewController *)customCropVC didFinished:(UIImage *)editedImage {
    [customCropVC dismissViewControllerAnimated:YES completion:^{
        self.coverImageView.image = editedImage;
    }];
}

- (void)imageCropDidCancel:(LLCustomCropViewController *)customCropVC {
    [customCropVC.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropDidRetry:(LLCustomCropViewController *)customCropVC
{
    [customCropVC.navigationController dismissViewControllerAnimated:NO completion:^{
//        [self gotoCamera];
    }];
}

@end

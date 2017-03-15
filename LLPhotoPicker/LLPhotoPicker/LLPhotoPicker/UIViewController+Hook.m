//
//  UIViewController+Hook.m
//  LLPhotoPicker
//
//  Created by leoliu on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "UIViewController+Hook.h"
#import "LLSwizzlingDefine.h"
#import "UIViewController+Nav.h"
@interface UIViewController()<UINavigationControllerDelegate>

@end

@implementation UIViewController (Hook)

+ (void)load
{
    swizzling_exchangeMethod([self class], @selector(viewWillAppear:), @selector(swizzling_viewWillAppear:));
    swizzling_exchangeMethod([self class], @selector(viewDidAppear:), @selector(swizzling_viewDidAppear:));
}

- (void)swizzling_viewWillAppear:(BOOL)animated
{
    [self swizzling_viewWillAppear:animated];
    self.navigationController.delegate = self;
}

- (void)swizzling_viewDidAppear:(BOOL)animated
{
    [self swizzling_viewDidAppear:animated];
    
    // 每次回来刷下状态栏
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // 不能影响系统的
    NSString *classString = NSStringFromClass([viewController class]);
    if (!viewController.isHiddenNavigationBar && [classString rangeOfString:@"LL"].length <= 0) {
        return;
    }
    
    BOOL hiddenNav = [viewController hiddenNavigation];
    [self.navigationController setNavigationBarHidden:hiddenNav animated:animated];
}
@end

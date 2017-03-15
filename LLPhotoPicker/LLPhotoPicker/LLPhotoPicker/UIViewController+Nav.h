//
//  UIViewController+Nav.h
//  LLPhotoPicker
//
//  Created by leoliu on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Nav)

//MARK: - NavigationBar 显示隐藏控制 只对 LL 前缀的控制器有效
@property (nonatomic, assign) BOOL isHiddenNavigationBar;
- (BOOL)hiddenNavigation;

@end

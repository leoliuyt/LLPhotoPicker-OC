//
//  UIViewController+Nav.m
//  LLPhotoPicker
//
//  Created by leoliu on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import "UIViewController+Nav.h"
#import <objc/runtime.h>

@implementation UIViewController (Nav)

//MARK: NavigationBar 显示隐藏控制
- (BOOL)hiddenNavigation {
    return self.isHiddenNavigationBar;
}

- (void)setIsHiddenNavigationBar:(BOOL)isHiddenNavigationBar {
    objc_setAssociatedObject(self, @selector(isHiddenNavigationBar), [NSNumber numberWithBool:isHiddenNavigationBar], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isHiddenNavigationBar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end

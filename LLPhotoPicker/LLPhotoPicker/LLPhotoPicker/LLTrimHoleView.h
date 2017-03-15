//
//  LLTrimHoleView.h
//  LLPhotoPicker
//
//  Created by lbq on 2017/3/15.
//  Copyright © 2017年 lbq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLTrimHoleView : UIView

@property (nonatomic, strong) UIBezierPath *holePath;

@property (nonatomic, strong) NSArray<UIBezierPath *> *holePaths;

@property (nonatomic, strong) UIColor *viewColor; // default is black, alpha 0.7

@end

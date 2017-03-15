//
//  JYIndicatorView.h
//  Demo
//
//  Created by weijingyun on 16/6/22.
//  Copyright © 2016年 weijingyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JYIndicatorStyleLoopDiagram, // 环形
    JYIndicatorStylePieDiagram,   // 饼型
    JYIndicatorStyleStudioDiagram // 为智慧校园添加的
} JYIndicatorStyle;

@interface JYIndicatorView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) JYIndicatorStyle style;//显示模式

@end

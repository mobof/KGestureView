//
//  KGestureTrace.h
//  KZTDemo
//
//  Created by 熊清 on 2020/8/19.
//  Copyright © 2020 格尔软件. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KGestureTrace : UIView
/// 实例化方法
/// @param pointColor 圆点的颜色
/// @param radialColor 选择后的连线颜色和圆点辐射圈颜色
- (instancetype)initWithPointColor:(UIColor*)pointColor
                          radialColor:(UIColor*)radialColor;

/// 实时刷新选中的点的颜色
/// @param points 选中的点
- (void)realTimeDraw:(NSArray *)points;

/// 通过颜色体现手势输入状态
/// @param color 状态颜色
- (void)reDrawWithColor:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END

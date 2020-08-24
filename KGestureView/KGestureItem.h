//
//  KGestureItem.h
//  KZTDemo
//
//  Created by 熊清 on 2020/8/19.
//  Copyright © 2020 格尔软件. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ITEM_DIAM      60 //每个点的直径
#define TAG_START      1000 //点的标记开始的值
NS_ASSUME_NONNULL_BEGIN
typedef enum {
    ITEM_STATE_NOMAL,//初始状态
    ITEM_STATE_SELECT,//连接的点
    ITEM_STATE_WRONG,//连接错误
} ITEM_STATE;
@interface KGestureItem : UIView

/// 圆点状态
@property(nonatomic,assign)ITEM_STATE state;

/// 圆点是否已选择
@property(nonatomic,assign)BOOL isSelect;

/// 实例化方法
/// @param pointColor 圆点的颜色
/// @param radialColor 选择后的连线颜色和圆点辐射圈颜色
- (instancetype)initWithPointColor:(UIColor*)pointColor
                          radialColor:(UIColor*)radialColor;

/// 滑动方向标记
/// @param point 活动到的点
- (void)displayDirection:(CGPoint)point;

/// 重置点样式
- (void)reset;

@end

NS_ASSUME_NONNULL_END

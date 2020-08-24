//
//  KGestureView.h
//  KZTDemo
//
//  Created by 熊清 on 2020/8/19.
//  Copyright © 2020 格尔软件. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    GESTURE_MODEL_MODIFY,//修改手势，输入两次不一样的手势返回
    GESTURE_MODEL_VERIFY,//验证手势密码，输入一次即返回
    GESTURE_MODEL_REGIST,//设置或重置手势密码，需要两次输入相同手势才返回
} GESTURE_MODEL;


@interface KGestureView : UIView

/// 初始化手势UI
/// @param frame 布局范围
- (instancetype)initWithFrame:(CGRect)frame;

/// 手势密码模型
@property (assign,nonatomic) IBInspectable GESTURE_MODEL mode;

/// 是否显示迷你九宫格
@property (assign,nonatomic) IBInspectable BOOL showMini;

/// 密码的最短长度
@property (assign,nonatomic) IBInspectable int minLength;

/// 未划过时的点颜色
@property (strong,nonatomic) IBInspectable UIColor *unselectedColor;

/// 划过后的点的颜色，底色是颜色的0.2透明度
@property (strong,nonatomic) IBInspectable UIColor *selectedColor;

/// 提示文字的颜色
@property (strong,nonatomic) IBInspectable UIColor *tipLabelColor;

/// 异常提示文字的颜色
@property (strong,nonatomic) IBInspectable UIColor *errTipLabelColor;

/// 设置手势以及验证手势时的回调
@property (strong,nonatomic) void (^pwdBlock)(NSString* pwd);

/// 修改手势时的回调
@property (strong,nonatomic) void (^pwdEditBlock)(NSString* oldPwd,NSString* newPwd);

@end

NS_ASSUME_NONNULL_END

//
//  KGestureTrace.m
//  KZTDemo
//
//  Created by 熊清 on 2020/8/19.
//  Copyright © 2020 格尔软件. All rights reserved.
//

#import "KGestureTrace.h"
#import "KGestureItem.h"

#define POINT_DIAM      10 //每个点的直径

@interface KGestureTrace()
@property (nonatomic,strong) UIColor *nomalColor;
@property (nonatomic,strong) UIColor *selectedColor;
@property (nonatomic,strong) NSMutableArray<CAShapeLayer*> *points;
@end

@implementation KGestureTrace

- (instancetype)initWithPointColor:(UIColor*)pointColor
                         radialColor:(UIColor*)radialColor{
    if (self = [super init]) {
        _nomalColor = pointColor;
        _selectedColor = radialColor;
    }
    return self;
}

- (void)didMoveToSuperview {
    self.backgroundColor = self.superview.backgroundColor;
    [self initializeSubviews];
}

- (void)realTimeDraw:(NSArray *)points {
    [points enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self updatePoint:obj.tag - TAG_START color:_selectedColor];
    }];
    [self setNeedsDisplay];
}

- (void)reDrawWithColor:(UIColor*)color {
    [_points enumerateObjectsUsingBlock:^(CAShapeLayer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self updatePoint:idx color:color ? color : _nomalColor];
    }];
}

#pragma mark - Layout Subviews
- (void)initializeSubviews {
    CGFloat space = (self.frame.size.width - 3 * POINT_DIAM) / 2;
    for (int i = 0; i < 9; i++){
        int row = i / 3;
        int col = i % 3;
        //绘制点
        CAShapeLayer *shape = [self drawPoint:CGRectMake(col * (space + POINT_DIAM), row * (space + POINT_DIAM) , POINT_DIAM , POINT_DIAM) color:_nomalColor];
        [self.layer addSublayer:shape];
        //将点记录下来
        if (!_points) {
            _points = [NSMutableArray arrayWithCapacity:0];
        }
        [_points addObject:shape];
    }
}

- (CAShapeLayer*)drawPoint:(CGRect)frame color:(UIColor *)color{
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = frame;
    shape.fillColor = color.CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:shape.bounds];
    shape.path = path.CGPath;
    return shape;
}

- (void)updatePoint:(NSInteger)index color:(UIColor *)color{
    CAShapeLayer *shape = _points[index];
    shape.fillColor = color.CGColor;
}

@end

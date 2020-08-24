//
//  KGestureItem.m
//  KZTDemo
//
//  Created by 熊清 on 2020/8/19.
//  Copyright © 2020 格尔软件. All rights reserved.
//

#import "KGestureItem.h"

@interface KGestureItem()
@property (nonatomic,strong) UIColor *pointColor;
@property (nonatomic,strong) UIColor *radialColor;
@property (nonatomic,strong) CAShapeLayer *radialLayer;//点的辐射
@property (nonatomic,strong) CAShapeLayer *pointLayer;//点
@property (nonatomic,strong) CAShapeLayer *linkerLayer;//点之间连线
@end

@implementation KGestureItem

- (instancetype)initWithPointColor:(UIColor*)pointColor
                         radialColor:(UIColor*)radialColor{
    if (self = [super init]) {
        _pointColor = pointColor;
        _radialColor = radialColor;
    }
    return self;
}

- (void)didMoveToSuperview {
    self.backgroundColor = self.superview.backgroundColor;
    [self.layer addSublayer:self.radialLayer];
    [self.layer addSublayer:self.pointLayer];
    [self.layer addSublayer:self.linkerLayer];
    self.layer.cornerRadius = self.frame.size.height / 2;
}

-(void)setState:(ITEM_STATE)state {
    switch (state) {
        case ITEM_STATE_WRONG:
            self.pointLayer.fillColor  = UIColor.redColor.CGColor;
            self.radialLayer.strokeColor = [UIColor.redColor colorWithAlphaComponent:0.2].CGColor;
            self.isSelect = NO;
            break;
        case ITEM_STATE_SELECT:
            self.pointLayer.fillColor  = _radialColor.CGColor;
            self.radialLayer.strokeColor = [_radialColor colorWithAlphaComponent:0.2].CGColor;
            self.isSelect = YES;
            break;
        default:
            self.pointLayer.fillColor  = _pointColor.CGColor;
            self.radialLayer.strokeColor = UIColor.clearColor.CGColor;
            self.isSelect = NO;
            break;
    }
}

#pragma mark - Public interface
- (void)displayDirection:(CGPoint)point {
    self.linkerLayer.hidden = NO;
    
    CGPoint origin = self.center;
    CGFloat angle = atan2(point.y - origin.y, origin.x - point.x);
    self.transform = CGAffineTransformMakeRotation(-angle - M_PI_2);
}

- (void)reset {
    self.isSelect = NO;
    self.state = ITEM_STATE_NOMAL;
    self.linkerLayer.hidden = YES;
}

#pragma mark - Lazy properties
- (CAShapeLayer *)pointLayer{
    if (!_pointLayer) {
        _pointLayer = [CAShapeLayer layer];
        _pointLayer.frame = CGRectMake(self.frame.size.width / 3, self.frame.size.height / 3, self.frame.size.width / 3,self.frame.size.height / 3);
        _pointLayer.fillColor = _pointColor.CGColor;
        
        UIBezierPath *innerLayer = [UIBezierPath bezierPathWithOvalInRect:self.pointLayer.bounds];
        _pointLayer.path = innerLayer.CGPath;
    }
    return _pointLayer;
}

- (CAShapeLayer *)radialLayer{
    if (!_radialLayer) {
        _radialLayer = [CAShapeLayer layer];
        _radialLayer.frame = CGRectMake(self.frame.size.width / 6, self.frame.size.height / 6, self.frame.size.width * 2 / 3,self.frame.size.height * 2 / 3);
        _radialLayer.fillColor = self.backgroundColor.CGColor;//实现穿透效果
        _radialLayer.strokeColor = UIColor.clearColor.CGColor;
        _radialLayer.lineWidth = self.frame.size.width / 3;
        
        UIBezierPath *radialLayer = [UIBezierPath bezierPathWithOvalInRect:self.radialLayer.bounds];
        _radialLayer.path = radialLayer.CGPath;
    }
    return _radialLayer;
}

- (CAShapeLayer *)linkerLayer{
    if (!_linkerLayer) {
        _linkerLayer = [CAShapeLayer layer];
        _linkerLayer.frame = CGRectZero;
        _linkerLayer.fillColor = _radialColor.CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.frame.size.width/2 , self.pointLayer.frame.origin.y-10 )];
        [path addLineToPoint:CGPointMake(self.frame.size.width/2-5, self.pointLayer.frame.origin.y-3)];
        [path addLineToPoint:CGPointMake(self.frame.size.width/2+5, self.pointLayer.frame.origin.y-3)];
        _linkerLayer.path = path.CGPath;
        _linkerLayer.hidden = YES;
    }
    return _linkerLayer;
}

@end

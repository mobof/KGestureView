//
//  KGestureView.m
//  KZTDemo
//
//  Created by 熊清 on 2020/8/19.
//  Copyright © 2020 格尔软件. All rights reserved.
//

#import "KGestureView.h"
#import "KGestureTrace.h"
#import "KGestureItem.h"

//未选中点的颜色
#define ITEMCOLOR               [UIColor colorWithRed:222.f/255.f green:224.f/255.f blue:229.f/255.f alpha:1]
//选中点颜色
#define SELECTCOLOR             [UIColor colorWithRed:20.f/255.f green:103.f/255.f blue:237.f/255.f alpha:1]
//手势密码错误时提示颜色
#define LABELWRONGCOLOR         [UIColor colorWithRed:0.94 green:0.31 blue:0.36 alpha:1]
//提示文字颜色
#define LABELCOLOR              [UIColor colorWithRed:0.49 green:0.54 blue:0.6 alpha:1]
//密码最小长度
#define PWD_LENGTH_MIN          6

#define PWD_VERIFY_TIP          @"验证手势"
#define PWD_SET_TIP             @"滑动设置手势"
#define PWD_RESET_TIP           @"滑动确认手势"
#define PWD_DIF_TIP             @"两次手势输入不一致"
#define PWD_MATCH_TIP           @"手势设置完成"
#define PWD_WRONG_TIP           [NSString stringWithFormat:@"请至少选择%d个点",_minLength > 0 ? _minLength : PWD_LENGTH_MIN]
#define PWD_OLD_TIP             @"请输入旧手势"
#define PWD_NEW_TIP             @"请输入新手势"
#define PWD_SAME_TIP            @"新手势不能与旧手势相同"
#define PWD_INPUT_TIP           @"手势输入完成"

@interface KGestureView()
@property (strong,nonatomic) UILabel *descLabel;
@property (strong,nonatomic) KGestureTrace *traceView;
@property (nonatomic,assign) CGPoint movePoint;//移动过程中的点
@property (strong,nonatomic) NSMutableArray<KGestureItem*> *selectedPoints;//已选中的点
@property (copy,nonatomic) NSString *firPwd;//设置或修改手势时，第一次输入的手势
@end
@implementation KGestureView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeSubviews];
}

- (void)showTip:(NSString*)tip isError:(BOOL)error {
    _descLabel.text = tip;
    _descLabel.textColor = error ? (_errTipLabelColor ? _errTipLabelColor : LABELWRONGCOLOR) : (_tipLabelColor ? _tipLabelColor : LABELCOLOR);
}

#pragma mark - ^ Layout Subviews
- (void)initializeSubviews{
    //1.设置背景色为superview背景色
    self.backgroundColor = self.superview.backgroundColor;
    
    //2.动态显示选择的点
    if (_showMini) {
        [self addSubview:self.traceView];
    }
    
    //3.布局提示语
    [self addSubview:self.descLabel];
    
    //4.布局九个点
    [self layoutNinePoint];
}

- (void)setMode:(GESTURE_MODEL)mode {
    _mode = mode;
    switch (mode) {
        case GESTURE_MODEL_REGIST:
            _descLabel.text = PWD_SET_TIP;
            break;
        case GESTURE_MODEL_MODIFY:
            _descLabel.text = PWD_OLD_TIP;
            break;
        default:
            _descLabel.text = PWD_VERIFY_TIP;
            break;
    }
}

#pragma mark - | Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    //如果是点击缩略视图，直接提示错误
    if (CGRectContainsPoint(_traceView.frame, point)) {
        [self shake:_traceView];
        return;
    }
    if (CGRectContainsPoint(_descLabel.frame, point)) {
        return;
    }
    [self isPointSelected:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    //如果是点击缩略视图，直接提示错误
    if (CGRectContainsPoint(_traceView.frame, point)) {
        return;
    }
    if (CGRectContainsPoint(_descLabel.frame, point)) {
        return;
    }
    //选择圆点
    [self isPointSelected:point];
    //重绘
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    //密码少于特定长度
    if (self.selectedPoints.count < (_minLength > 0 ? _minLength : PWD_LENGTH_MIN)) {
        _descLabel.textColor = _errTipLabelColor ? _errTipLabelColor : LABELWRONGCOLOR;
        _descLabel.text = PWD_WRONG_TIP;
        [self shake:_descLabel];
        //输入错误，重置小九宫格颜色
        [_traceView reDrawWithColor:_unselectedColor ? _unselectedColor : ITEMCOLOR];
    }else{
        //根据手势密码类型处理业务
        [self handlePwd:[self convertToPwd]];
    }
    //恢复原始UI状态
    for (KGestureItem *item in self.subviews){
        if ([item isKindOfClass:KGestureTrace.class]){
            continue;
        }
        if ([item isKindOfClass:KGestureItem.class]) {
            [item reset];
        }
    }
    //清空选中的点
    [_selectedPoints removeAllObjects];
    [self setNeedsDisplay];
}

#pragma mark - | 实时绘制
- (void)drawRect:(CGRect)rect{
    UIBezierPath *path = [UIBezierPath bezierPath];

    //连接点
    for (int i=0; i<self.selectedPoints.count; i++){
        KGestureItem *item = (KGestureItem *)self.selectedPoints[i];
        if (i==0) {
            [path moveToPoint:item.center];
        }else{
            [path addLineToPoint:item.center];
        }
    }
    //连接触点
    KGestureItem *item = self.selectedPoints.lastObject;
    if (!CGPointEqualToPoint(CGPointZero, _movePoint) && NSStringFromCGPoint(_movePoint)){
        [path addLineToPoint:_movePoint];

        //标记触点方向
        [item displayDirection:_movePoint];
    }

    [path setLineCapStyle:kCGLineCapRound];
    [path setLineJoinStyle:kCGLineJoinRound];
    [path setLineWidth:3.f];
    [_selectedColor ? _selectedColor : SELECTCOLOR setStroke];
    [path stroke];
}

#pragma mark - | Subviews structure
- (KGestureTrace *)traceView{
    if (!_traceView) {
        _traceView = [[KGestureTrace alloc] initWithPointColor:_unselectedColor ? _unselectedColor : ITEMCOLOR radialColor:_selectedColor ? _selectedColor : SELECTCOLOR];
        [_traceView setFrame:CGRectMake((UIScreen.mainScreen.bounds.size.width-40)/2, 20, 40, 40)];
    }
    return _traceView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:(CGRect){0,CGRectGetMaxY(_traceView.frame),UIScreen.mainScreen.bounds.size.width,40}];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _descLabel.textColor = _tipLabelColor ? _tipLabelColor : LABELCOLOR;
    }
    return _descLabel;
}

- (void)layoutNinePoint {
    CGFloat space = (UIScreen.mainScreen.bounds.size.width - 3 * ITEM_DIAM) / 4;
    for (int i = 0; i < 9; i++){
        int row = i / 3;
        int col = i % 3;
        
        KGestureItem *item = [[KGestureItem alloc] initWithPointColor:_unselectedColor ? _unselectedColor : ITEMCOLOR radialColor:_selectedColor ? _selectedColor : SELECTCOLOR];
        [item setFrame:CGRectMake(space + col * (ITEM_DIAM + space) ,row * (ITEM_DIAM + space) + CGRectGetMaxY(_descLabel.frame) + 20 ,ITEM_DIAM ,ITEM_DIAM)];
        item.userInteractionEnabled = YES;
        item.backgroundColor = [UIColor clearColor];
        item.isSelect = NO;
        item.tag = TAG_START + i;
        [self addSubview:item];
    }
}

#pragma mark - | Private method
- (void)isPointSelected:(CGPoint)point{
    for (KGestureItem *item in self.subviews){
        if (!CGRectContainsPoint(item.frame, point) || item.isSelect){
            _movePoint = point;
            continue;
        }
        if (!_selectedPoints) {
            _selectedPoints = [NSMutableArray arrayWithCapacity:0];
        }else if(_selectedPoints.count == 0) {
            [_traceView reDrawWithColor:_unselectedColor ? _unselectedColor : ITEMCOLOR];
        }
        _movePoint = CGPointZero;//在drawRect时避免多次绘制连线
        [_selectedPoints addObject:item];
        item.state = ITEM_STATE_SELECT;
        [_traceView realTimeDraw:self.selectedPoints];
    }
}

- (NSString *)convertToPwd{
    NSMutableString *resultStr = [NSMutableString string];
    for (KGestureItem *item in self.selectedPoints){
        if (![item isKindOfClass:KGestureTrace.class] && [item isKindOfClass:KGestureItem.class]){
            [resultStr appendString:@"A"];
            [resultStr appendString:[NSString stringWithFormat:@"%ld", (long)item.tag-TAG_START + 1]];
        }
    }
    
    return (NSString *)resultStr;
}

- (void)shake:(UIView *)myView{
    int offset = 8;
    
    CALayer *lbl = [myView layer];
    CGPoint posLbl = [lbl position];
    CGPoint y = CGPointMake(posLbl.x-offset, posLbl.y);
    CGPoint x = CGPointMake(posLbl.x+offset, posLbl.y);
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.06];
    [animation setRepeatCount:2];
    [lbl addAnimation:animation forKey:nil];
}

- (void)handlePwd:(NSString *)pwd{
    switch (_mode) {
        case GESTURE_MODEL_MODIFY:
            if (!_firPwd) {//首次输入
                _firPwd = pwd;
                _descLabel.text = PWD_NEW_TIP;
                _descLabel.textColor = _tipLabelColor ? _tipLabelColor : LABELCOLOR;
                return;
            }
            if ([pwd isEqualToString:_firPwd]) {//两次输入相同
                self.descLabel.text = PWD_SAME_TIP;
                _descLabel.textColor = _errTipLabelColor ? _errTipLabelColor : LABELWRONGCOLOR;
                [_traceView reDrawWithColor:_unselectedColor ? _unselectedColor : ITEMCOLOR];
                [self shake:_descLabel];
                return;
            }
            _descLabel.text = PWD_INPUT_TIP;
            _descLabel.textColor = _tipLabelColor ? _tipLabelColor : LABELCOLOR;
            if (_pwdEditBlock) _pwdEditBlock([_firPwd stringByReplacingOccurrencesOfString:@"A" withString:@""],[pwd stringByReplacingOccurrencesOfString:@"A" withString:@""]);
            _firPwd = nil;
            break;
        case GESTURE_MODEL_REGIST:
            if (!_firPwd) {//首次输入
                _firPwd = pwd;
                _descLabel.text = PWD_RESET_TIP;
                _descLabel.textColor = _tipLabelColor ? _tipLabelColor : LABELCOLOR;
                return;
            }
            if (![pwd isEqualToString:_firPwd]) {//两次输入不一致
                _descLabel.text = PWD_DIF_TIP;
                _descLabel.textColor = _errTipLabelColor ? _errTipLabelColor : LABELWRONGCOLOR;
                [_traceView reDrawWithColor:_unselectedColor ? _unselectedColor : ITEMCOLOR];
                [self shake:_descLabel];
                return;
            }
            _descLabel.text = PWD_MATCH_TIP;
            _descLabel.textColor = _tipLabelColor ? _tipLabelColor : LABELCOLOR;
            if (_pwdBlock) _pwdBlock([pwd stringByReplacingOccurrencesOfString:@"A" withString:@""]);
            _firPwd = nil;
            break;
        case GESTURE_MODEL_VERIFY:
            _descLabel.text = PWD_INPUT_TIP;
            _descLabel.textColor = _tipLabelColor ? _tipLabelColor : LABELCOLOR;
            if (_pwdBlock) _pwdBlock([pwd stringByReplacingOccurrencesOfString:@"A" withString:@""]);
            break;
        default:
            break;
    }
}

@end

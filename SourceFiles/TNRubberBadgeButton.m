//
//  TNRubberBadgeButton.m
//  BaseProject
//
//  Created by Tony on 2017/8/15.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TNRubberBadgeButton.h"


@interface TNRubberBadgeButton ()

/** shape */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

/** dismiss images array*/
@property (nonatomic, strong) NSMutableArray *images;

/** small circle */
@property (nonatomic, strong) UIView *smallCircleView;

@property (nonatomic, weak) UIView *superView;

@end


@implementation TNRubberBadgeButton


#define kBadgeColor [UIColor redColor]
#pragma mark - 懒加载
- (NSMutableArray *)images{
    if (_images == nil) {
        _images = [NSMutableArray array];
        for (int i = 1; i < 6; i++) {
            NSString *imageName = [NSString stringWithFormat:@"tnRubberBadge_destroy_%d_ic", i];
            UIImage *image = [UIImage imageNamed:imageName];
            [_images addObject:image];
        }
    }
    
    return _images;
}

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = kBadgeColor.CGColor;
        [self.superview.layer insertSublayer:_shapeLayer below:self.layer];
    }
    
    return _shapeLayer;
}

- (UIView *)smallCircleView{
    if (!_smallCircleView) {
        
        _smallCircleView = [[UIView alloc] init];
        _smallCircleView.backgroundColor = kBadgeColor;
    }
    
    return _smallCircleView;
}


- (void)setBadgeValue:(NSInteger)badgeValue{
    _badgeValue = badgeValue;
    if (badgeValue == 0) {
        self.hidden = YES;
        self.smallCircleView.hidden = YES;
        if (_smallCircleView) {
            self.center = self.smallCircleView.center;
        }
    }else{
        self.hidden = NO;
        self.smallCircleView.hidden = NO;
        [self setTitle:[NSString stringWithFormat:@"%ld",(long)badgeValue] forState:UIControlStateNormal];
        if (badgeValue>99) {
            [self setTitle:@"99+" forState:UIControlStateNormal];
        }
    }
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self commonInit];
}



- (void)commonInit{
    
    self.badgeValue = 1;
    
    self.backgroundColor = kBadgeColor;
    
    CGFloat btnH = self.bounds.size.height;
    CGFloat btnW = self.bounds.size.width;
    
    CGFloat cornerRadius = (btnH > btnW ? btnW * 0.5 : btnH * 0.5);
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.maxDistance = cornerRadius * 4;
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGR];
    
    [self addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    [self smallCircleView];
    [self.smallCircleView removeFromSuperview];
    [self.superview insertSubview:self.smallCircleView belowSubview:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat btnH = self.bounds.size.height;
    CGFloat btnW = self.bounds.size.width;
    CGFloat cornerRadius = (btnH > btnW ? btnW * 0.5 : btnH * 0.5);
    CGRect samllCireleRect = CGRectMake(0, 0, cornerRadius, cornerRadius);
    self.smallCircleView.bounds = samllCireleRect;
    self.smallCircleView.center = self.center;
    self.smallCircleView.layer.cornerRadius = self.smallCircleView.bounds.size.width / 2;
}

#pragma mark - 手势
- (void)pan:(UIPanGestureRecognizer *)pan{
    
    if (pan.state == UIGestureRecognizerStateBegan){
        [self addToTopView];
    }
    
    [self.layer removeAnimationForKey:@"shake"];
    
    CGPoint panPoint = [pan translationInView:self];
    
    CGPoint changeCenter = self.center;
    changeCenter.x += panPoint.x;
    changeCenter.y += panPoint.y;
    
    self.center = changeCenter;
    
    
    [pan setTranslation:CGPointZero inView:self];
    
    //俩个圆的中心点之间的距离
    CGFloat dist = [self pointToPoitnDistanceWithPoint:self.center potintB:self.smallCircleView.center];
    
    if (dist < self.maxDistance) {
        
        if (self.smallCircleView.hidden == NO && dist > 0) {
            //画不规则矩形
            self.shapeLayer.hidden = NO;
            
            self.shapeLayer.path = [self pathWithBigCirCleView:self smallCirCleView:self.smallCircleView].CGPath;
        }
    } else {
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.shapeLayer.hidden = YES;
        [CATransaction commit];
        
        self.smallCircleView.hidden = YES;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if (dist > self.maxDistance) {
            
            //play destroy animations;
            [self startDestroyAnimations];
            
            //move to super view;
            [self addToSuperView];
            
            //set badge value and reset position;
            self.badgeValue = 0;
            
        } else {
            
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.shapeLayer.hidden = YES;
            [CATransaction commit];
            
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.center = self.smallCircleView.center;
            } completion:^(BOOL finished) {
                self.smallCircleView.hidden = NO;
                [self addToSuperView];
            }];
        }
    }
}

- (void)addToTopView{
    
    self.superView = self.superview;
    
    UIWindow *topWindow = [[UIApplication sharedApplication].delegate window];
    
    self.frame = [self.superview convertRect:self.frame toView:topWindow];
    self.smallCircleView.frame = [self.superview convertRect:self.smallCircleView.frame toView:topWindow];
    
    [topWindow addSubview:self.smallCircleView];
    [topWindow addSubview:self];
    
    [self.smallCircleView.superview bringSubviewToFront:topWindow];
    [self.superview bringSubviewToFront:self];
    [self.superview.layer insertSublayer:self.shapeLayer below:self.layer];
}

- (void)addToSuperView{
    
    self.frame = [self.superview convertRect:self.frame toView:self.superView];
    self.smallCircleView.frame = [self.superview convertRect:self.smallCircleView.frame toView:self.superView];
    
    [self.superView addSubview:self.smallCircleView];
    [self.superView addSubview:self];
    
    [self.smallCircleView.superview bringSubviewToFront:self.smallCircleView];
    [self.superview bringSubviewToFront:self];
    [self.superview.layer insertSublayer:self.shapeLayer below:self.layer];
}


#pragma mark - 俩个圆心之间的距离
- (CGFloat)pointToPoitnDistanceWithPoint:(CGPoint)pointA potintB:(CGPoint)pointB{
    CGFloat offestX = pointA.x - pointB.x;
    CGFloat offestY = pointA.y - pointB.y;
    CGFloat dist = sqrtf(offestX * offestX + offestY * offestY);
    
    return dist;
}

- (void)killAll{
    [self removeFromSuperview];
    [self.smallCircleView removeFromSuperview];
    self.smallCircleView = nil;
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
}



#pragma mark - 不规则路径
- (UIBezierPath *)pathWithBigCirCleView:(UIView *)bigCirCleView  smallCirCleView:(UIView *)smallCirCleView{
    CGPoint bigCenter = bigCirCleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigCirCleView.bounds.size.width / 2;
    
    CGPoint smallCenter = smallCirCleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallCirCleView.bounds.size.width / 2;
    
    // 获取圆心距离
    CGFloat d = [self pointToPoitnDistanceWithPoint:self.smallCircleView.center potintB:self.center];
    CGFloat sinθ = (x2 - x1) / d;
    CGFloat cosθ = (y2 - y1) / d;
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinθ , pointA.y + d / 2 * cosθ);
    CGPoint pointP = CGPointMake(pointB.x + d / 2 * sinθ , pointB.y + d / 2 * cosθ);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // A
    [path moveToPoint:pointA];
    // AB
    [path addLineToPoint:pointB];
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    // CD
    [path addLineToPoint:pointD];
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

#pragma mark - button消失动画
- (void)startDestroyAnimations{
    UIImageView *ainmImageView = [[UIImageView alloc] initWithFrame:self.frame];
    ainmImageView.animationImages = self.images;
    ainmImageView.animationRepeatCount = 1;
    ainmImageView.animationDuration = 0.5;
    [ainmImageView startAnimating];
    
    [self.superview addSubview:ainmImageView];
}

- (void)buttonDidClick:(id)sender{
    
}

#pragma mark - 设置长按时候左右摇摆的动画
- (void)setHighlighted:(BOOL)highlighted{
    
    [self.layer removeAnimationForKey:@"shake"];
    
    CGFloat shakeMagnitude = 6;
    
    CAKeyframeAnimation *keyAnim = [CAKeyframeAnimation animation];
    keyAnim.keyPath = @"transform.translation.x";
    keyAnim.values = @[@(-shakeMagnitude--), @(shakeMagnitude--), @(-shakeMagnitude--), @(shakeMagnitude--), @(-shakeMagnitude--)];
    keyAnim.removedOnCompletion = NO;
    keyAnim.repeatCount = 0;
    
    keyAnim.duration = 0.4;
    [self.layer addAnimation:keyAnim forKey:@"shake"];
}



@end

//
//  WaveLoadingView.m
//  TestDemo
//
//  Created by 王恒求 on 2016/2/21.
//  Copyright © 2016年 王恒求. All rights reserved.
//

#import "WaveLoadingView.h"

typedef enum {
    WaveType_Sin,
    WaveType_Cos
}WaveType;

@interface WaveLoadingView()

/** 主要的实现原理就是将一张灰色，一张灰绿色，一张绿色的图片重叠防止，然后将最上面的两张图片的mask图层分别设置为正弦波动图层和余弦波动图层，然后结合图层向上移动，就可以形成水波加载动画*/

/** 最下面的灰色底图*/
@property (nonatomic,strong) UIImageView *downImageView;
/** 中间的灰绿色图片*/
@property (nonatomic,strong) UIImageView *midImageView;
/** 上面的绿色图片*/
@property (nonatomic,strong) UIImageView *upImageView;
/** 需要执行正弦波动的图层*/
@property (nonatomic,strong) CAShapeLayer *waveSinLayer;
/** 需要执行余弦波动的图层*/
@property (nonatomic,strong) CAShapeLayer *waveCosLayer;
/** 刷新的计时器*/
@property (nonatomic,strong) CADisplayLink *displayLink;

#pragma mark 设置一些波浪的相关属性
/** 正弦余弦的最大高度要等于图层的最高点*/

/** 波浪的频率，1表示在波浪宽度内恰好有一个正弦波或者一个余弦波*/
@property (nonatomic,assign) CGFloat frequency;
/** 波浪的宽度*/
@property (nonatomic,assign) CGFloat waveWidth;
/** 波浪的高度*/
@property (nonatomic,assign) CGFloat waveHeight;
/** 波浪的中间高度，就是起始位置*/
@property (nonatomic,assign) CGFloat waveMidHeight;
/** 中间的位置*/
@property (nonatomic,assign) CGFloat midHeigh;
/** 正弦余弦相位*/
@property (nonatomic, assign) CGFloat phase;
/** 振幅*/
@property (nonatomic,assign) CGFloat amplitude;

@end

@implementation WaveLoadingView

+ (instancetype)loadingView
{
    return [[WaveLoadingView alloc] initWithFrame:CGRectMake(0, 0, 40, 31)];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self =[super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    
    return self;
}

-(void)setupSubViews
{
    self.downImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.downImageView.image=[UIImage imageNamed:@"du"];
    [self addSubview:self.downImageView];
    
    self.midImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.midImageView.image = [UIImage imageNamed:@"gray"];
    [self addSubview:self.midImageView];
    
    self.upImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.upImageView.image = [UIImage imageNamed:@"blue"];
    [self addSubview:self.upImageView];
    
    self.waveSinLayer = [CAShapeLayer layer];
    self.waveSinLayer.fillColor = [UIColor blackColor].CGColor;
    self.waveSinLayer.backgroundColor = [UIColor greenColor].CGColor;
    /** 初始位置的y值是图片的高度，是为了一开始图片的主图层与mask图层的交集为空，以此来达到一开始不显示最上面两张图片的目的*/
    [self.waveSinLayer setFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
    
    self.waveCosLayer = [CAShapeLayer layer];
    self.waveCosLayer.fillColor = [UIColor blackColor].CGColor;
    self.waveCosLayer.backgroundColor = [UIColor blueColor].CGColor;
    [self.waveCosLayer setFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height)];
    
    self.midImageView.layer.mask = self.waveCosLayer;
    self.upImageView.layer.mask = self.waveSinLayer;
    
    self.waveHeight = CGRectGetHeight(self.bounds);
    self.waveWidth  = CGRectGetWidth(self.bounds);
    self.frequency = 3;
    self.midHeigh = self.waveHeight * 0.4;
    self.amplitude = self.waveHeight * 0.6;
}

-(void)startLoading
{
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePath:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    CGPoint position = self.waveSinLayer.position;
    position.y = position.y - self.bounds.size.height - 15;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:self.waveSinLayer.position];
    animation.toValue = [NSValue valueWithCGPoint:position];
    animation.duration = 5;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    [self.waveSinLayer addAnimation:animation forKey:@"positionWave"];
    [self.waveCosLayer addAnimation:animation forKey:@"positionWave"];
}

- (void)updatePath:(CADisplayLink *)displayLink
{
    self.phase += 5;
    self.waveSinLayer.path = [self createWavePathWithType:WaveType_Sin].CGPath;
    self.waveCosLayer.path = [self createWavePathWithType:WaveType_Cos].CGPath;
}

- (UIBezierPath *)createWavePathWithType:(WaveType)pathType
{
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    CGFloat endX = 0;
    for (CGFloat x = 0; x < self.waveWidth + 1; x += 1) {
        endX=x;
        CGFloat y = 0;
        if (pathType == WaveType_Sin) {
            y = self.amplitude  * sinf(x * 2 * M_PI * self.frequency + self.phase * M_PI/ 180) + self.midHeigh;
        } else {
            y = self.amplitude  * cosf(x * 2 * M_PI * self.frequency + self.phase * M_PI/ 180) + self.midHeigh;
        }
        
        if (x == 0) {
            [wavePath moveToPoint:CGPointMake(x, y)];
        } else {
            [wavePath addLineToPoint:CGPointMake(x, y)];
        }
    }
    
    CGFloat endY = CGRectGetHeight(self.bounds) + 20;
    [wavePath addLineToPoint:CGPointMake(endX, endY)];
    [wavePath addLineToPoint:CGPointMake(0, endY)];
    
    return wavePath;
}

- (void)stopLoading
{
    [self.displayLink invalidate];
    [self.waveSinLayer removeAllAnimations];
    [self.waveCosLayer removeAllAnimations];
    self.waveSinLayer.path = nil;
    self.waveCosLayer.path = nil;
}

@end

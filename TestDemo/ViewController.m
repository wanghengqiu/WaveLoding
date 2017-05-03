//
//  ViewController.m
//  TestDemo
//
//  Created by 王恒求 on 2016/2/21.
//  Copyright © 2016年 王恒求. All rights reserved.
//

#import "ViewController.h"
#import "AppUtily.h"
#import "WaveLoadingView.h"

@interface ViewController ()

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,assign) int phase;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,strong) WaveLoadingView *loadingView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phase=0;
    
    self.shapeLayer=[CAShapeLayer layer];
    self.shapeLayer.frame=CGRectMake(0, 100, kSCREEN_WIDTH, 200);
    self.shapeLayer.fillColor=[UIColor yellowColor].CGColor;
    self.shapeLayer.path=[self createSinPath].CGPath;
    [self.view.layer addSublayer:self.shapeLayer];

    [self startLoading];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _loadingView = [WaveLoadingView loadingView];
    [self.view addSubview:_loadingView];
    _loadingView.center = self.view.center;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_loadingView startLoading];
    });
}

- (void)startLoading
{
    [_displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(updateWave:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];
}

- (void)updateWave:(CADisplayLink *)displayLink
{
    self.phase += 10;//逐渐累加初相
    self.shapeLayer.path = [self createSinPath].CGPath;
}

- (UIBezierPath *)createSinPath
{
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    CGFloat endX = 0;
    for (CGFloat x = 0; x < kSCREEN_WIDTH+1; x += 1) {
        endX=x;
        CGFloat y = 25 * sinf(2*x*M_PI/kSCREEN_WIDTH + self.phase * M_PI/180) + 90;
        if (x == 0) {
            [wavePath moveToPoint:CGPointMake(x, y)];
        } else {
            [wavePath addLineToPoint:CGPointMake(x, y)];
        }
    }
    
    CGFloat endY = 200;
    [wavePath addLineToPoint:CGPointMake(kSCREEN_WIDTH, endY)];
    [wavePath addLineToPoint:CGPointMake(0, endY)];
    [wavePath closePath];
    return wavePath;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

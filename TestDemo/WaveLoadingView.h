//
//  WaveLoadingView.h
//  TestDemo
//
//  Created by 王恒求 on 2016/2/21.
//  Copyright © 2016年 王恒求. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveLoadingView : UIView

+ (instancetype)loadingView;

- (void)startLoading;

- (void)stopLoading;

@end

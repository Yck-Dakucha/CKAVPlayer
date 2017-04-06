//
//  CKAVPlayerOverlayView.h
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKGradualTransparentView.h"
#import "CKDurationSlider.h"

@interface CKAVPlayerOverlayView : UIView
/**
 播放器顶部控制
 */
@property (nonatomic, strong, readonly) CKGradualTransparentView *topBar;
/**
 播放器底部控制
 */
@property (nonatomic, strong, readonly) CKGradualTransparentView *bottomBar;
/**
 播放暂停按钮
 */
@property (nonatomic, strong, readonly) UIButton *playPauseButton;
/**
 进度条
 */
@property (nonatomic, strong, readonly) CKDurationSlider *durationSlider;
/**
 上下视图显示情况
 */
@property (nonatomic, assign, readonly) BOOL isBarVisiable;
/**
 默认为YES,设置为NO时，animateShowBars则会失效
 */
@property (nonatomic, assign) BOOL isBarEnabled;
/**
 缓冲进度轮
 */
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;

/**
 显示上下控制栏
 */
- (void)ck_animateHideBars;
/**
 隐藏上下控制栏
 */
- (void)ck_animateShowBars;
/**
 显示loading状态

 @param completion
 */
- (void)ck_showLoadingIndicator:(void(^)())completion;
/**
 隐藏loading状态

 @param completion 
 */
- (void)ck_hideLoadingIndicator:(void(^)())completion;

@end

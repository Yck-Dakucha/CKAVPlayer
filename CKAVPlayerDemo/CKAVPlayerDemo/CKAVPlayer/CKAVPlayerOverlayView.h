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

typedef NS_ENUM(NSInteger,CKAVPlayerFullScreenStatus) {
    CKAVPlayerFullScreenStatusBeFullScreen,   //全屏状态
    CKAVPlayerFullScreenStatusBeNormal,       //小屏状态
};

@interface CKAVPlayerOverlayView : UIView

/**
 视图状态
 */
@property (nonatomic, assign,         ) CKAVPlayerFullScreenStatus playerStatus;
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
 已播放时长
 */
@property (nonatomic, strong, readonly) UILabel *timeElapsedLabel;
/**
 总时长
 */
@property (nonatomic, strong, readonly) UILabel *timeTotalLabel;
/**
 进度条
 */
@property (nonatomic, strong, readonly) CKDurationSlider *durationSlider;
/**
 全屏/返回小屏按钮
 */
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
/**
 上下视图显示情况
 */
@property (nonatomic, assign, readonly) BOOL isBarVisiable;
/**
 默认为YES,设置为NO时，animateShowBars则会失效
 */
@property (nonatomic, assign,         ) BOOL isBarEnabled;
/**
 缓冲进度轮
 */
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;
/**
 返回按钮
 */
@property (nonatomic, strong, readonly) UIButton *backButton;
/**
 视频标题
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;
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

 @param completion <#completion description#>
 */
- (void)ck_showLoadingIndicator:(void(^)())completion;
/**
 隐藏loading状态

 @param completion <#completion description#>
 */
- (void)ck_hideLoadingIndicator:(void(^)())completion;
/**
 设置播放时间

 @param currentTime <#currentTime description#>
 @param totalTime <#totalTime description#>
 */
- (void)ck_setTimeLabelValues:(double)currentTime totalTime:(double)totalTime;
@end

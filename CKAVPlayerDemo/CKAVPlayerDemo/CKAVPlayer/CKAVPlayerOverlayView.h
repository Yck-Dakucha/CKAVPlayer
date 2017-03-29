//
//  CKAVPlayerOverlayView.h
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKGradualTransparentView;
@class CKDurationSlider;

@interface CKAVPlayerOverlayView : UIView
/**
 播放器顶部控制
 */
@property (nonatomic, strong, readonly) CKGradualTransparentView *topView;
/**
 播放器底部控制
 */
@property (nonatomic, strong, readonly) CKGradualTransparentView *bottomView;
/**
 播放暂停按钮
 */
@property (nonatomic, strong, readonly) UIButton *playPauseButton;
/**
 进度条
 */
@property (nonatomic, strong, readonly) CKDurationSlider *durationSlider;

@end

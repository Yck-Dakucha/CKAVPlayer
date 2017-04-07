//
//  CKAVPlayerController.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/28.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKAVPlayerController.h"

@interface CKAVPlayerController ()<CKAVPlayerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) CKAVPlayer *player;
@property (nonatomic, strong) CKAVPlayerOverlayView *overlayView;
/**
 是否正在Seek
 */
@property (nonatomic, assign) BOOL isSeeking;
/**
 单击手势
 */
@property (nonatomic, strong) UITapGestureRecognizer   *tapRecognizer;
/**
 手动左快速滑屏幕
 */
@property (nonatomic, retain) UISwipeGestureRecognizer *leftSwipeRecognizer;
/**
 手动右快速滑屏幕
 */
@property (nonatomic, retain) UISwipeGestureRecognizer *rightSwipeRecognizer;
/**
 拖动，慢速移动
 */
@property (nonatomic, strong) UIPanGestureRecognizer   *panRecognizer;


@end

@implementation CKAVPlayerController

#pragma mark -  getter
- (UIView *)view {
    return self.player;
}
#pragma mark -  overLayerView lazy
- (CKAVPlayerOverlayView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[CKAVPlayerOverlayView alloc] init];
    }
    return _overlayView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _player = [[CKAVPlayer alloc] init];
        _player.delegate = self;
        [_player addSubview:self.overlayView];
        [self configConstraints];
        [self configControlAction];
        [self addGestureRecognizer];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        _player = [[CKAVPlayer alloc] initWithFrame:frame];
        _player.delegate = self;
        self.overlayView.frame = frame;
        [_player addSubview:self.overlayView];
        [self configControlAction];
        [self addGestureRecognizer];
    }
    return self;
}

#pragma mark -  添加约束
- (void)configConstraints {

    [_player addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_player
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0]];
    
    [_player addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_player
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    [_player addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_player
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0]];
    [_player addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_player
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
}


#pragma mark -  设置OverlayView的Action
- (void)configControlAction{
    [self.overlayView.playPauseButton addTarget:self action:@selector(playOrPauseButtonClick:) forControlEvents:UIControlEventTouchUpInside];

}

#pragma mark - addGestureRecognizer
- (void)addGestureRecognizer {
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapRecognizer.delegate = self;
    [self.player addGestureRecognizer:_tapRecognizer];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - GestureRecognizerEvent
// 处理皮肤的隐／现
- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    if ([self.overlayView isBarVisiable]) {
        [self.overlayView ck_animateHideBars];
    } else {
        [self.overlayView ck_animateShowBars];
    }
}

#pragma mark -  播放器代理
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer statusDidChange:(CKAVPlayerPlayStatus)status error:(NSError *)error {
    if (error) {
        NSLog(@"VideoPlayer ERROR >>> %@",error);
    }
    switch (status) {
        case CKAVPlayerPlayStatusUnKnow: {
            [self.overlayView ck_showLoadingIndicator:nil];
            break;
        }
        case CKAVPlayerPlayStatusLoadVideoInfo: {
            [self.overlayView ck_showLoadingIndicator:nil];
            break;
        }
        case CKAVPlayerPlayStatusReadyToPlay: {
            [self.overlayView ck_hideLoadingIndicator:nil];
            self.overlayView.durationSlider.maximumValue = avPlayer.totalDuration;
            [self enableSlider:YES];
            break;
        }
        case CKAVPlayerPlayStatusBuffering: {
            [self.overlayView ck_showLoadingIndicator:nil];
            break;
        }
        case CKAVPlayerPlayStatusBufferFinished: {
            [self.overlayView ck_hideLoadingIndicator:nil];
            break;
        }
        case CKAVPlayerPlayStatusPlayedToTheEnd: {
            break;
        }
        case CKAVPlayerPlayStatusError: {
            NSLog(@"ERROR");
            break;
        }
        default:
            break;
    }
}

- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer timeDidChange:(NSTimeInterval)time {
//    NSLog(@"player currentTime >>> %f",time);
    if (!self.isSeeking) {
        self.overlayView.durationSlider.value = time;
    }
}

- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer loadedTimeDidChange:(NSTimeInterval)time {
    if (self.isSeeking) {
        return;
    }
    [self.overlayView.durationSlider ck_setPlayableValue:time/avPlayer.totalDuration];
}

#pragma mark -  设置播放信息
- (void)ck_playWithURL:(NSURL *)url {
    [self.player ck_playWithURL:url];
}

#pragma mark -  播放器控制
- (void)playOrPauseButtonClick:(UIButton *)button {
    self.overlayView.playPauseButton.selected = !button.selected;
    if (self.overlayView.playPauseButton.selected) {
        //播放
        [self.player ck_play];
    }else {
        //暂停
        [self.player ck_pause];
    }
}

- (void)durationSliderTouchBegan:(UISlider *)slider {
    self.isSeeking = YES;
}

- (void)durationSliderValueChanged:(UISlider *)slider {
    [NSObject cancelPreviousPerformRequestsWithTarget:self.overlayView
                                             selector:@selector(ck_animateHideBars)
                                               object:nil];
}

- (void)durationSliderTouchEnded:(UISlider *)slider {
    [self.player ck_seekToTime:floor(slider.value)];
    [self.overlayView performSelector:@selector(ck_animateHideBars)
                           withObject:nil
                           afterDelay:5.0];
    self.isSeeking = NO;
}


- (void)enableSlider: (BOOL)shouldEnableSlider
{
    //未设置slider是否可见
    if (shouldEnableSlider) {
        self.overlayView.durationSlider.enabled = YES;
        [self.overlayView.durationSlider addTarget:self
                                               action:@selector(durationSliderValueChanged:)
                                     forControlEvents:UIControlEventValueChanged];
        
        [self.overlayView.durationSlider addTarget:self
                                               action:@selector(durationSliderTouchBegan:)
                                     forControlEvents:UIControlEventTouchDown];
        
        [self.overlayView.durationSlider addTarget:self
                                               action:@selector(durationSliderTouchEnded:)
                                     forControlEvents:UIControlEventTouchUpInside];
        
        [self.overlayView.durationSlider addTarget:self
                                               action:@selector(durationSliderTouchEnded:)
                                     forControlEvents:UIControlEventTouchUpOutside];
    } else {
        self.overlayView.durationSlider.enabled = NO;
        [self.overlayView.durationSlider removeTarget:self
                                                  action:@selector(durationSliderValueChanged:)
                                        forControlEvents:UIControlEventValueChanged];
        
        [self.overlayView.durationSlider removeTarget:self
                                                  action:@selector(durationSliderTouchBegan:)
                                        forControlEvents:UIControlEventTouchDown];
        
        [self.overlayView.durationSlider removeTarget:self
                                                  action:@selector(durationSliderTouchEnded:)
                                        forControlEvents:UIControlEventTouchUpInside];
        
        [self.overlayView.durationSlider removeTarget:self
                                                  action:@selector(durationSliderTouchEnded:)
                                        forControlEvents:UIControlEventTouchUpOutside];
    }
}

#pragma mark -  外部接口
/**
 播放
 */
- (void)ck_play {
    self.overlayView.playPauseButton.selected = YES;
    //播放
    [self.player ck_play];
}
/**
 暂停
 */
- (void)ck_pause {
    self.overlayView.playPauseButton.selected = NO;
    //播放
    [self.player ck_pause];
}
@end

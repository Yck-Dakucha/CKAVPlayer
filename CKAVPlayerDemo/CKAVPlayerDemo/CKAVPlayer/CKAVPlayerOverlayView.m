//
//  CKAVPlayerOverlayView.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKAVPlayerOverlayView.h"

#define kCKBarHeight         44.f
#define kCKSliderHeight      12.f
#define kCKMargin            10.f
#define kCKAnimationDuration 0.5f
#define kCKHideBarDelay       5.f
#define kCKButtonWidth       30.f
#define kCKLableWidth        40.f

@interface CKAVPlayerOverlayView ()

/**
 播放器顶部控制
 */
@property (nonatomic, strong, readwrite) CKGradualTransparentView *topBar;
/**
 播放器底部控制
 */
@property (nonatomic, strong, readwrite) CKGradualTransparentView *bottomBar;
/**
 播放暂停按钮
 */
@property (nonatomic, strong, readwrite) UIButton *playPauseButton;
/**
 进度条
 */
@property (nonatomic, strong, readwrite) CKDurationSlider *durationSlider;
/**
 缓冲进度轮
 */
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *activityIndicatorView;
/**
 全屏/返回小屏按钮
 */
@property (nonatomic, strong, readwrite) UIButton *fullScreenButton;
/**
 已播放时长
 */
@property (nonatomic, strong, readwrite) UILabel *timeElapsedLabel;
/**
 总时长
 */
@property (nonatomic, strong, readwrite) UILabel *timeTotalLabel;
/**
 返回按钮
 */
@property (nonatomic, strong, readwrite) UIButton *backButton;
/**
 视频标题
 */
@property (nonatomic, strong, readwrite) UILabel *titleLabel;


@property (nonatomic, strong) NSLayoutConstraint *topBarHightConstraint;

@end

@implementation CKAVPlayerOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isBarEnabled = YES;
        _playerStatus = CKAVPlayerFullScreenStatusBeNormal;
        [self creatUI];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

}

#pragma mark -  上下控制栏控制

- (void)setPlayerStatus:(CKAVPlayerFullScreenStatus)playerStatus {
    _playerStatus = playerStatus;
    [self ck_animateHideBars];
    if (playerStatus == CKAVPlayerFullScreenStatusBeFullScreen) {
        self.topBarHightConstraint.constant = kCKBarHeight + 22;
    }else {
        self.topBarHightConstraint.constant = kCKBarHeight;
    }
}

- (void)ck_animateHideBars {
    if (!self.isBarVisiable) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ck_animateShowBars) object:nil];
    [UIView animateWithDuration:kCKAnimationDuration animations:^{
        self.topBar.alpha = self.bottomBar.alpha = 0.0f;
        
    }completion:^(BOOL finished) {
    }];
    if (self.playerStatus == CKAVPlayerFullScreenStatusBeFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)ck_animateShowBars {
    if (!self.isBarEnabled) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ck_animateHideBars) object:nil];
    [UIView animateWithDuration:kCKAnimationDuration animations:^{
        self.topBar.alpha = self.bottomBar.alpha = 1.0f;
        
    }completion:^(BOOL finished) {
        [self performSelector:@selector(ck_animateHideBars) withObject:nil afterDelay:kCKHideBarDelay];
    }];
    if (self.playerStatus == CKAVPlayerFullScreenStatusBeFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)setIsBarEnabled:(BOOL)isBarEnabled {
    _isBarEnabled = isBarEnabled;
    if (!_isBarEnabled) {
        // Bar被设置为无效，则立即隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ck_animateShowBars) object:nil];
        self.topBar.alpha = 0.f;
        self.bottomBar.alpha = 0.f;
    }
}

- (BOOL)isBarVisiable {
    BOOL result;
    if (self.topBar && self.bottomBar) {
        result = self.topBar.alpha > 0 || self.bottomBar.alpha > 0;
    }
    return result;
}

#pragma mark -  loading状态控制
- (void)ck_showLoadingIndicator:(void(^)())completion {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ck_hideLoadingIndicator:) object:nil];
    [self.activityIndicatorView startAnimating];
    [UIView animateWithDuration:kCKAnimationDuration animations:^{
        self.activityIndicatorView.superview.alpha = 1.0f;
    }completion:^(BOOL finished) {
        if (finished && completion) {
            completion();
        }
    }];
}

- (void)ck_hideLoadingIndicator:(void(^)())completion {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ck_showLoadingIndicator:) object:nil];
    [self.activityIndicatorView stopAnimating];
    [UIView animateWithDuration:kCKAnimationDuration animations:^{
        self.activityIndicatorView.superview.alpha = 0.0f;
    }completion:^(BOOL finished) {
        if (finished && completion) {
            completion();
        }
    }];
}

#pragma mark -  进度设置
- (void)ck_setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    if (isnan(minutesElapsed)) {
        minutesElapsed = 0.0;
    }
    if (isnan(secondsElapsed)) {
        secondsElapsed = 0.0;
    }
    self.timeElapsedLabel.text = [NSString stringWithFormat:@"%.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);
    double secondsRemaining = fmod(totalTime, 60.0);
    if (isnan(minutesRemaining)) {
        minutesRemaining = 0.0;
    }
    if (isnan(secondsRemaining)) {
        secondsRemaining = 0.0;
    }
    
    self.timeTotalLabel.text = [NSString stringWithFormat:@"%.0f:%02.0f", minutesRemaining, secondsRemaining] ;
}

#pragma mark -  设置UI
- (void)creatUI {
    self.backgroundColor = [UIColor clearColor];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.topBar = ({
        CKGradualTransparentView *view = [[CKGradualTransparentView alloc] init];
        view.type = CKGradualTransoarentViewTypeUpToDown;
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0]];
        self.topBarHightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:kCKBarHeight];
        [view addConstraint:self.topBarHightConstraint];

        view;
    });
    
    self.bottomBar = ({
        CKGradualTransparentView *view = [[CKGradualTransparentView alloc] initWithFrame:CGRectZero];
        view.type = CKGradualTransoarentViewTypeDownToUp;
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:kCKBarHeight]];

        view;
    });
    
    self.playPauseButton = ({
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"CKAVPlayer-play"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"CKAVPlayer-pause"] forState:UIControlStateSelected];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bottomBar addSubview:button];
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.bottomBar
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:kCKMargin]];
        
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.bottomBar
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:kCKButtonWidth]];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:30]];

        button;
    });
    
    self.fullScreenButton = ({
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"CKAVPlayer-fullscreen"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"CKAVPlayer-shrinkscreen"] forState:UIControlStateSelected];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.bottomBar addSubview:button];
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBar
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:-kCKMargin]];
        
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBar
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0]];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:kCKButtonWidth]];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:30]];
        
        button;
    });
    
    self.timeElapsedLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentRight;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = @"0:00";
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.bottomBar addSubview:label];
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.playPauseButton
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:kCKMargin]];
        
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBar
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0]];
        [label addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:kCKLableWidth]];
        label;
    });
    
    self.timeTotalLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = @"0:00";
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.bottomBar addSubview:label];
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.fullScreenButton
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:-kCKMargin]];
        
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBar
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0]];
        [label addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:kCKLableWidth]];
        label;
    });
    
    self.durationSlider = ({
        CKDurationSlider *slider = [[CKDurationSlider alloc] init];
        slider.value = 0;
        [slider setThumbImage:[UIImage imageNamed:@"CKAVPlayer-point"] forState:UIControlStateNormal];
        [self.bottomBar addSubview:slider];
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:slider
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.timeElapsedLabel
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:kCKMargin]];
        
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:slider
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.bottomBar
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:0]];
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:slider
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.timeTotalLabel
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:-kCKMargin]];
        [slider addConstraint:[NSLayoutConstraint constraintWithItem:slider
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:20]];
        slider;
    });
    
    UIView *backView = ({
        UIView *view = [[UIView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        view.layer.cornerRadius = 10;
        view.alpha = 0.0;
        [self addSubview:view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:44]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:44]];
        view;
    });
    
    self.activityIndicatorView = ({
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        view.hidesWhenStopped = NO;
        [backView addSubview:view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:44]];
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:44]];
        view;
    });
    
    self.backButton = ({
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"CKAVPlayer-back"] forState:UIControlStateNormal];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.topBar addSubview:button];
        [self.topBar addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.topBar
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:kCKMargin]];
        
        [self.topBar addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.topBar
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:-(kCKBarHeight - 30)/2.0]];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:kCKButtonWidth]];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:30]];
        
        button;
    });
    
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentRight;
        label.adjustsFontSizeToFitWidth = YES;
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.topBar addSubview:label];
        [self.topBar addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.backButton
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:kCKMargin]];
        
        [self.topBar addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.backButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0]];
        
        [self.topBar addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationLessThanOrEqual
                                                                   toItem:self.topBar
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1.0
                                                                 constant:-kCKMargin]];
        label;
    });

}

@end

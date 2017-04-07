//
//  CKAVPlayerOverlayView.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKAVPlayerOverlayView.h"

#define alColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define kCKBarHeight 44
#define kCKMargin  10
#define kCKAnimationDuration 0.5f
#define kCKHideBarDelay 5.f

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

@end

@implementation CKAVPlayerOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isBarEnabled = YES;
        [self creatUI];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

}

#pragma mark -  上下控制栏控制
- (void)ck_animateHideBars {
    if (!self.isBarVisiable) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ck_animateShowBars) object:nil];
    [UIView animateWithDuration:kCKAnimationDuration animations:^{
        self.topBar.alpha = self.bottomBar.alpha = 0.0f;
    }completion:^(BOOL finished) {
    }];
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
        self.activityIndicatorView.alpha = 1.0f;
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
        self.activityIndicatorView.alpha = 0.0f;
    }completion:^(BOOL finished) {
        if (finished && completion) {
            completion();
        }
    }];
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
        [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:kCKBarHeight]];

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
        [button setTitle:@"播放" forState:UIControlStateNormal];
        [button setTitle:@"暂停" forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 0.5;
        button.layer.cornerRadius = 5;
        button.clipsToBounds = YES;
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
                                                          constant:44]];
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:30]];

        button;
    });
    
    self.durationSlider = ({
        CKDurationSlider *slider = [[CKDurationSlider alloc] init];
        slider.value = 0;
        [self.bottomBar addSubview:slider];
        [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:slider
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.playPauseButton
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
                                                                       toItem:self.bottomBar
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:-kCKMargin]];
        slider;
    });
    
    self.activityIndicatorView = ({
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] init];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.alpha = 0.0f;
        view.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        view.hidesWhenStopped = NO;
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
}

@end

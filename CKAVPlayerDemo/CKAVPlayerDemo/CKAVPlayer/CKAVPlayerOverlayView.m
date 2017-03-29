//
//  CKAVPlayerOverlayView.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKAVPlayerOverlayView.h"
#import "CKGradualTransparentView.h"
#import "CKDurationSlider.h"

#define alColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define kBarHeight 44
#define kCKMargin  10

@interface CKAVPlayerOverlayView ()

/**
 播放器顶部控制
 */
@property (nonatomic, strong, readwrite) CKGradualTransparentView *topView;
/**
 播放器底部控制
 */
@property (nonatomic, strong, readwrite) CKGradualTransparentView *bottomView;
/**
 播放暂停按钮
 */
@property (nonatomic, strong, readwrite) UIButton *playPauseButton;
/**
 进度条
 */
@property (nonatomic, strong, readwrite) CKDurationSlider *durationSlider;

@end

@implementation CKAVPlayerOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatUI];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat viewW = CGRectGetWidth(rect);
    CGFloat viewH = CGRectGetHeight(rect);
//    self.topView.frame = CGRectMake(0, 0, viewW, kBarHeight);
    self.bottomView.frame = CGRectMake(0, viewH - kBarHeight, viewW, kBarHeight);
    self.playPauseButton.frame = CGRectMake(kCKMargin, 0, 44, 30);
    self.playPauseButton.center = CGPointMake(self.playPauseButton.center.x, kBarHeight/2.0);
}

- (void)creatUI {
    self.backgroundColor = [UIColor clearColor];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.topView = ({
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
                                                          constant:kBarHeight]];

        view;
    });
    
    self.bottomView = ({
        CKGradualTransparentView *view = [[CKGradualTransparentView alloc] initWithFrame:CGRectZero];
        view.type = CKGradualTransoarentViewTypeDownToUp;
        [self addSubview:view];
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
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bottomView addSubview:button];
        button;
    });
    
    self.durationSlider = ({
        CKDurationSlider *slider = [[CKDurationSlider alloc] init];
        slider.value = 0;
        [self.bottomView addSubview:slider];
        slider;
    });
}

@end

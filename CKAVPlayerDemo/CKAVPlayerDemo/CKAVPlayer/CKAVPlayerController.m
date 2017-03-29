//
//  CKAVPlayerController.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/28.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKAVPlayerController.h"
#import "CKAVPlayer.h"
#import "CKAVPlayerOverlayView.h"

@interface CKAVPlayerController ()

@property (nonatomic, strong) CKAVPlayer *player;
@property (nonatomic, strong) CKAVPlayerOverlayView *overlayView;

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
        [_player addSubview:self.overlayView];
        [self configConstraints];
        [self configControlAction];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        _player = [[CKAVPlayer alloc] initWithFrame:frame];
        self.overlayView.frame = frame;
        [_player addSubview:self.overlayView];
        [self configControlAction];
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

@end

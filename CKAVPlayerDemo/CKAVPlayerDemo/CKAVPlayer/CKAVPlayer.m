//
//  CKAVPlayer.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKAVPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface CKAVPlayer ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation CKAVPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self creatPlayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatPlayer];
    }
    return self;
}

- (void)ck_play {
    [self.player play];
}

- (void)drawRect:(CGRect)rect {
    self.playerLayer.frame = rect;
}


- (void)creatPlayer {
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"http://znf.oss-cn-shanghai.aliyuncs.com/course/znf2017031401/znf2017031401001.mp4"]];
    _player = [AVPlayer playerWithPlayerItem:item];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [self.layer addSublayer:_playerLayer];
}

@end

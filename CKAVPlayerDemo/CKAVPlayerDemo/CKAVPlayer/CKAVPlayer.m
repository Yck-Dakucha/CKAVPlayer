//
//  CKAVPlayer.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKAVPlayer.h"
//frameWork
#import <AVFoundation/AVFoundation.h>

@interface CKAVPlayer ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id timeObsever;
/**
 当前播放时间
 */
@property (nonatomic, assign, readwrite) NSTimeInterval playBackTime;
/**
 影片总时长
 */
@property (nonatomic, assign, readwrite) NSTimeInterval totalDuration;
/**
 已缓冲时长
 */
@property (nonatomic, assign, readwrite) NSTimeInterval playableDuration;
/**
 播放器状态
 */
@property (nonatomic, assign, readwrite) CKAVPlayerStatus status;
@end

@implementation CKAVPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self creatPlayer];
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatPlayer];
    }
    return self;
}

- (void)creatPlayer {
    _player = [[AVPlayer alloc] init];
    ((AVPlayerLayer *)self.layer).player = _player;
}


- (void)setStatus:(CKAVPlayerStatus)status {
    _status = status;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ck_AVPlayer:playerStatusDidChange:error:)]) {
        __weak typeof(self) weakSelf = self;
        [self.delegate ck_AVPlayer:weakSelf playerStatusDidChange:status error:self.player.currentItem.error];
    }
}

#pragma mark -  外部接口
- (void)ck_playWithURL:(NSURL *)url {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    if (self.playerItem) {
        [self.player removeTimeObserver:self.timeObsever];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
        self.timeObsever = nil;
    }
    self.playerItem = playerItem;
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)ck_play {
    //判断是否播放
    if ([self.delegate respondsToSelector:@selector(ck_AVPlayerVideoShouldPlay:)]) {
         __weak typeof(self) weakSelf = self;
        BOOL isPlay = [self.delegate ck_AVPlayerVideoShouldPlay:weakSelf];
        if (!isPlay) {
            return;
        }
    }
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.player play];
    if (self.playerItem.status != AVPlayerItemStatusReadyToPlay) {
        self.status = CKAVPlayerStatusLoadVideoInfo;
    }
}

- (void)ck_pause {
    [self.player pause];
}

/**
 停止
 */
- (void)ck_stop {
    [self.player cancelPendingPrerolls];
    [self.player seekToTime:CMTimeMake(0, 1.0)];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"about:blank"]];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self.player cancelPendingPrerolls];
}


- (void)ck_seekToTime:(NSTimeInterval)time {
    if (!self.playerItem) {
        return;
    }
    [self.playerItem seekToTime:CMTimeMake(time, 1.0)];
}

- (CKAVPlayerTimeControlStatus )timeControlStatus {
    switch (self.player.timeControlStatus) {
        case AVPlayerTimeControlStatusPaused:
            return CKAVPlayerTimeControlStatusPaused;
            break;
        case AVPlayerTimeControlStatusPlaying:
            return CKAVPlayerTimeControlStatusPlaying;
            break;
        case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate:
            return CKAVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate;
            break;
        default:
            break;
    }
}

#pragma mark -  
#pragma mark -  KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        //状态监听
//        NSLog(@"playerItem status >>>> %ld",(long)item.status);
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            [self addTimeObseverForPlayer];
            self.totalDuration = CMTimeGetSeconds(item.duration);
            self.status = CKAVPlayerStatusReadyToPlay;
        }else if (item.status == AVPlayerItemStatusUnknown) {
            self.status = CKAVPlayerStatusUnKnow;
        }else if (item.status == AVPlayerItemStatusFailed) {
            self.status = CKAVPlayerStatusError;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
    
        NSTimeInterval loadedTime = [self getLoadedTime];
        self.playableDuration = loadedTime;
        if (self.delegate && [self.delegate respondsToSelector:@selector(ck_AVPlayer:loadedTimeDidChange:)]) {
            __weak typeof(self) weakSelf = self;
            [self.delegate ck_AVPlayer:weakSelf loadedTimeDidChange:loadedTime];
        }
        if (self.playBackTime < self.totalDuration - 5) {
            //缓冲不足
            if (self.playableDuration < self.playBackTime + 2) {
                self.status = CKAVPlayerStatusBuffering;
            }else {
                if (self.status == CKAVPlayerStatusBuffering) {
                    self.status = CKAVPlayerStatusBufferFinished;
                }
            }
        }else {
            if (self.status == CKAVPlayerStatusBuffering) {
                self.status = CKAVPlayerStatusBufferFinished;
            }
        }
        //播放结束
        if (self.playBackTime == self.totalDuration && self.totalDuration != 0) {
            self.status = CKAVPlayerStatusPlayedToTheEnd;
        }
    }else if ([keyPath isEqualToString:@"timeControlStatus"]) {
        AVPlayer *player = (AVPlayer *)object;
        if (self.delegate && [self.delegate respondsToSelector:@selector(ck_AVPlayer:timeControlStatusDidChange:)]) {
            __weak typeof(self) weakSelf = self;
            switch (player.timeControlStatus) {
                case AVPlayerTimeControlStatusPlaying:
                    [self.delegate ck_AVPlayer:weakSelf timeControlStatusDidChange:CKAVPlayerTimeControlStatusPlaying];
                    break;
                case AVPlayerTimeControlStatusPaused:
                    [self.delegate ck_AVPlayer:weakSelf timeControlStatusDidChange:CKAVPlayerTimeControlStatusPaused];
                    break;
                case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate:
                    [self.delegate ck_AVPlayer:weakSelf timeControlStatusDidChange:CKAVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate];
                    break;
                default:
                    break;
            }
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -  播放进度监听
- (void)addTimeObseverForPlayer {
    __weak typeof(self) weakSelf = self;
    self.timeObsever = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ck_AVPlayer:timeDidChange:)]) {
            NSTimeInterval timeInterval = CMTimeGetSeconds(time);
            weakSelf.playBackTime = timeInterval;
            [weakSelf.delegate ck_AVPlayer:weakSelf timeDidChange:timeInterval];
        }
    }];
}

#pragma mark -  获取缓冲时间
- (NSTimeInterval)getLoadedTime {
    NSArray *loadedTimeRanges = [self.playerItem loadedTimeRanges];
    //获取缓冲区域
    CMTimeRange range = [loadedTimeRanges.firstObject CMTimeRangeValue];
    NSTimeInterval startTime = CMTimeGetSeconds(range.start);
    NSTimeInterval duration = CMTimeGetSeconds(range.duration);
    return startTime + duration;
}



#pragma mark -  销毁
- (void)dealloc {
    [self.player removeTimeObserver:self.timeObsever];
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
    }
}
@end

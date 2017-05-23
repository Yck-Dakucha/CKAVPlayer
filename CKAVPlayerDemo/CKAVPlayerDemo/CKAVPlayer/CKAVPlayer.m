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
@property (nonatomic, assign, readwrite) CKAVPlayerPlayStatus status;
@end

@implementation CKAVPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

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

- (void)creatPlayer {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    _player = [[AVPlayer alloc] init];
    ((AVPlayerLayer *)self.layer).player = _player;
}


- (void)setStatus:(CKAVPlayerPlayStatus)status {
    _status = status;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ck_AVPlayer:statusDidChange:error:)]) {
        __weak typeof(self) weakSelf = self;
        [self.delegate ck_AVPlayer:weakSelf statusDidChange:status error:self.player.currentItem.error];
    }
}

#pragma mark -  外部接口
- (void)ck_playWithURL:(NSURL *)url {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    if (self.playerItem) {
        [self.player removeTimeObserver:self.timeObsever];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        self.timeObsever = nil;
    }
    self.playerItem = playerItem;
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)ck_play {
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.player play];
    if (self.playerItem.status != AVPlayerItemStatusReadyToPlay) {
        self.status = CKAVPlayerPlayStatusLoadVideoInfo;
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

#pragma mark -  
#pragma mark -  KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem *item = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        //状态监听
        NSLog(@"playerItem status >>>> %ld",(long)item.status);
        if (item.status == AVPlayerItemStatusReadyToPlay) {
            [self addTimeObseverForPlayer];
            self.totalDuration = CMTimeGetSeconds(item.duration);
            self.status = CKAVPlayerPlayStatusReadyToPlay;
        }else if (item.status == AVPlayerItemStatusUnknown) {
            self.status = CKAVPlayerPlayStatusUnKnow;
        }else if (item.status == AVPlayerItemStatusFailed) {
            self.status = CKAVPlayerPlayStatusError;
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
                self.status = CKAVPlayerPlayStatusBuffering;
            }else {
                if (self.status == CKAVPlayerPlayStatusBuffering) {
                    self.status = CKAVPlayerPlayStatusBufferFinished;
                }
            }
        }else {
            if (self.status == CKAVPlayerPlayStatusBuffering) {
                self.status = CKAVPlayerPlayStatusBufferFinished;
            }
        }
        //播放结束
        if (self.playBackTime == self.totalDuration && self.totalDuration != 0) {
            self.status = CKAVPlayerPlayStatusPlayedToTheEnd;
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
    }
}
@end

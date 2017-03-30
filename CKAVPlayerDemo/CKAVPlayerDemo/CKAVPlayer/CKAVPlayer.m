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
 影片总时长
 */
@property (nonatomic, assign, readwrite) NSTimeInterval totalDuration;
/**
 已缓冲时长
 */
@property (nonatomic, assign, readwrite) NSTimeInterval playableDuration;
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
}

- (void)ck_pause {
    [self.player pause];
}



- (void)creatPlayer {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    _player = [[AVPlayer alloc] init];
    ((AVPlayerLayer *)self.layer).player = _player;
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
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval loadedTime = [self getLoadedTime];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ckAVPlayer:loadedTimeDidChange:)]) {
            __weak typeof(self) weakSelf = self;
            [self.delegate ckAVPlayer:weakSelf loadedTimeDidChange:loadedTime];
        }
    }
}

#pragma mark -  播放进度监听
- (void)addTimeObseverForPlayer {
    __weak typeof(self) weakSelf = self;
    self.timeObsever = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ckAVPlayer:timeDidChange:)]) {
            NSTimeInterval timeInterval = CMTimeGetSeconds(time);
            [weakSelf.delegate ckAVPlayer:weakSelf timeDidChange:timeInterval];
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

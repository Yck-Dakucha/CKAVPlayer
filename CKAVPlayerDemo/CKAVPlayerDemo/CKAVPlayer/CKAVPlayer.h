//
//  CKAVPlayer.h
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKAVPlayer;

//播放器状态
typedef NS_ENUM(NSInteger,CKAVPlayerStatus) {
    CKAVPlayerStatusUnKnow,         //未知状态
    CKAVPlayerStatusLoadVideoInfo,  //获取视频数据
    CKAVPlayerStatusReadyToPlay,    //可以播放
    CKAVPlayerStatusBuffering,      //正在缓冲
    CKAVPlayerStatusBufferFinished, //缓冲结束
    CKAVPlayerStatusPlayedToTheEnd, //播放完毕
    CKAVPlayerStatusError,          //播放错误
};
//播放状态
typedef NS_ENUM(NSInteger,CKAVPlayerTimeControlStatus) {
    CKAVPlayerTimeControlStatusPaused,                         //暂停
    CKAVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate,   //等待播放指定时间
    CKAVPlayerTimeControlStatusPlaying                         //播放中
};

@protocol CKAVPlayerDelegate <NSObject>

@required

@optional

/**
 视频预备播放

 @param avPlayer player
 @return 是否播放  返回YES 播放 NO 不播放
 */
- (BOOL)ck_AVPlayerVideoShouldPlay:(CKAVPlayer *)avPlayer;

/**
 播放器状态变化

 @param avPlayer player
 @param status 播放状态
 @param error 错误返回
 */
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer playerStatusDidChange:(CKAVPlayerStatus)status error:(NSError *)error;
/**
 播放中状态变化

 @param avPlayer player
 @param status 播放状态
 */
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer timeControlStatusDidChange:(CKAVPlayerTimeControlStatus)status;
/**
 播放时间变化

 @param avPlayer player
 @param time 播放时间
 */
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer timeDidChange:(NSTimeInterval)time;
/**
 缓冲时间变化

 @param avPlayer player
 @param time 缓冲时间
 */
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer loadedTimeDidChange:(NSTimeInterval)time;

@end

@interface CKAVPlayer : UIView

/**
 播放器代理
 */
@property (nonatomic, weak) id<CKAVPlayerDelegate> delegate;
/**
 播放器状态
 */
@property (nonatomic, assign, readonly) CKAVPlayerStatus status;
/**
 播放状态
 */
@property (nonatomic, assign, readonly) CKAVPlayerTimeControlStatus timeControlStatus;

/**
 当前播放时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval playBackTime;
/**
 影片总时长
 */
@property (nonatomic, assign, readonly) NSTimeInterval totalDuration;
/**
 已缓冲时长
 */
@property (nonatomic, assign, readonly) NSTimeInterval playableDuration;
/**
 设置播放信息

 @param url 视频播放地址
 */
- (void)ck_playWithURL:(NSURL *)url;
/**
 播放
 */
- (void)ck_play;
/**
 暂停
 */
- (void)ck_pause;
/**
 停止
 */
- (void)ck_stop;
/**
 跳转到时间

 @param time 目标时间
 */
- (void)ck_seekToTime:(NSTimeInterval)time;
@end

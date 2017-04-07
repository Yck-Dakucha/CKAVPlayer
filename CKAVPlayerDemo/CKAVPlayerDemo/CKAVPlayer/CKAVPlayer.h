//
//  CKAVPlayer.h
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKAVPlayer;

typedef NS_ENUM(NSInteger,CKAVPlayerPlayStatus) {
    CKAVPlayerPlayStatusUnKnow,         //未知状态
    CKAVPlayerPlayStatusLoadVideoInfo,  //获取视频数据
    CKAVPlayerPlayStatusReadyToPlay,    //可以播放
    CKAVPlayerPlayStatusBuffering,      //正在缓冲
    CKAVPlayerPlayStatusBufferFinished, //缓冲结束
    CKAVPlayerPlayStatusPlayedToTheEnd, //播放完毕
    CKAVPlayerPlayStatusError,          //播放错误
};

@protocol CKAVPlayerDelegate <NSObject>

@required

@optional

/**
 播放状态变化

 @param avPlayer player
 @param status 播放状态
 @param error 错误返回
 */
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer statusDidChange:(CKAVPlayerPlayStatus)status error:(NSError *)error;
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
@property (nonatomic, assign, readonly) CKAVPlayerPlayStatus status;
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
 跳转到时间

 @param time 目标时间
 */
- (void)ck_seekToTime:(NSTimeInterval)time;
@end

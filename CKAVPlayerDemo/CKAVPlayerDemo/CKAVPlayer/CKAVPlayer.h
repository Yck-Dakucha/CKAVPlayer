//
//  CKAVPlayer.h
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKAVPlayer;

@protocol CKAVPlayerDelegate <NSObject>

@required

@optional

/**
 播放时间变化

 @param avPlayer player
 @param time 播放时间
 */
- (void)ckAVPlayer:(CKAVPlayer *)avPlayer timeDidChange:(NSTimeInterval)time;
/**
 缓冲时间变化

 @param avPlayer player
 @param time 缓冲时间
 */
- (void)ckAVPlayer:(CKAVPlayer *)avPlayer loadedTimeDidChange:(NSTimeInterval)time;

@end

@interface CKAVPlayer : UIView

/**
 播放器代理
 */
@property (nonatomic, weak) id<CKAVPlayerDelegate> delegate;
/**
 影片总时长
 */
@property (nonatomic, assign, readonly) NSTimeInterval totalDuration;
/**
 以缓冲时长
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
@end

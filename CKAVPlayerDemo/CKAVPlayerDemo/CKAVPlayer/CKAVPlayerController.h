//
//  CKAVPlayerController.h
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/28.
//  Copyright © 2017年 yck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKAVPlayer.h"
#import "CKAVPlayerOverlayView.h"

typedef NS_ENUM(NSInteger,CKAVPlayerFullScreenStatus) {
    CKAVPlayerFullScreenStatusBeFullScreen,   //全屏状态
    CKAVPlayerFullScreenStatusBeNormal,       //小屏状态
};

@protocol CKAVPlayerControllerDelegate <NSObject>

@required

@optional

/**
 播放状态变化
 
 @param avPlayer player
 @param status 播放状态
 @param error 错误返回
 */
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer playStatusDidChange:(CKAVPlayerPlayStatus)status error:(NSError *)error;
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

/**
 全屏状态变化

 @param avPlayer player
 @param status 全屏状态
 */
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer fullScreenStatus:(CKAVPlayerFullScreenStatus)status;

@end

@interface CKAVPlayerController : NSObject
/**
 播放视图
 */
@property (nonatomic, strong, readonly) UIView *view;
/**
 代理
 */
@property (nonatomic, weak) id<CKAVPlayerControllerDelegate> delegate;
/**
 全屏状态
 */
@property (nonatomic, assign, readonly) CKAVPlayerFullScreenStatus fullScreenStatus;

- (instancetype)initWithFrame:(CGRect)frame;
/**
 设置视频播放地址

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

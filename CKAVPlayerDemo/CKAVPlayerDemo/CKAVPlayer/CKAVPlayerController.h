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

@interface CKAVPlayerController : NSObject
/**
 播放视图
 */
@property (nonatomic, strong, readonly) UIView *view;

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

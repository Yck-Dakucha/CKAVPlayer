//
//  CKAVPlayerController.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/28.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKAVPlayerController.h"
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MediaPlayer.h>

#define kCKScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kCKScreenHeight [UIScreen mainScreen].bounds.size.height
#define kCKSystemVersion ([[[UIDevice currentDevice] systemVersion] floatValue])

@interface CKAVPlayerController ()<CKAVPlayerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) CKAVPlayer *player;
@property (nonatomic, strong) CKAVPlayerOverlayView *overlayView;
@property (nonatomic, assign) CGRect originalFrame;
/**
 是否正在Seek
 */
@property (nonatomic, assign) BOOL isSeeking;
/**
 单击手势
 */
@property (nonatomic, strong) UITapGestureRecognizer   *tapRecognizer;
/**
 手动左快速滑屏幕
 */
@property (nonatomic, retain) UISwipeGestureRecognizer *leftSwipeRecognizer;
/**
 手动右快速滑屏幕
 */
@property (nonatomic, retain) UISwipeGestureRecognizer *rightSwipeRecognizer;
/**
 拖动，慢速移动
 */
@property (nonatomic, strong) UIPanGestureRecognizer   *panRecognizer;
/**
 上一次调节音量时的音量大小
 */
@property (nonatomic, assign) float lastVolume;
/**
 获取MediaPlayer的Slider
 */
@property (nonatomic, strong) UISlider* volumeViewSlider;
/**
 全屏状态
 */
@property (nonatomic, assign, readwrite) CKAVPlayerFullScreenStatus fullScreenStatus;



@end

@implementation CKAVPlayerController {
    NSMutableArray *playerConArray;
    NSMutableArray *playerSuperViewConArray;
    NSLayoutConstraint *widthCon;
    NSLayoutConstraint *heightCon;
}

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
        _player.delegate = self;
        _fullScreenStatus = CKAVPlayerFullScreenStatusBeNormal;
        [_player addSubview:self.overlayView];
        [self configConstraints];
        [self configControlAction];
        [self addGestureRecognizer];
        //订阅UIApplicationDidChangeStatusBarOrientationNotification通知
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(deviceDidChangeStatusBarOrientation:)
//                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
//                                                   object:nil];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        _player = [[CKAVPlayer alloc] initWithFrame:frame];
        _player.delegate = self;
//        self.overlayView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _fullScreenStatus = CKAVPlayerFullScreenStatusBeNormal;
        [_player addSubview:self.overlayView];
        [self configConstraints];
        [self configControlAction];
        [self addGestureRecognizer];
//        //订阅UIApplicationDidChangeStatusBarOrientationNotification通知
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(deviceDidChangeStatusBarOrientation:)
//                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
//                                                   object:nil];
        
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
    [self.overlayView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView.backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - addGestureRecognizer
- (void)addGestureRecognizer {
    //tapRecognizer手势
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapRecognizer.delegate = self;
    [self.player addGestureRecognizer:_tapRecognizer];
    
    // panRecognizer手势
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.player addGestureRecognizer:_panRecognizer];
    self.panRecognizer.delegate = self;
    
    // leftSwipeRecognizer手势
    self.leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [self.leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft ];
    if (self.panRecognizer) {
        [self.panRecognizer requireGestureRecognizerToFail:self.leftSwipeRecognizer];
    }
    
    [self.player addGestureRecognizer:self.leftSwipeRecognizer];
    
    // leftSwipeRecognizer手势
    self.rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [self.rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    if (self.panRecognizer) {
        [self.panRecognizer requireGestureRecognizerToFail:self.rightSwipeRecognizer];
    }
    [self.player addGestureRecognizer:self.rightSwipeRecognizer];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //防止滑动事件阻碍按钮事件
    if([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UISlider class]] || [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {
        return NO;
    }
    //滑动控制音量的时候剔除上下bar的范围
    if(self.overlayView.isBarVisiable && gestureRecognizer == self.panRecognizer)
    {
        CGPoint panPointInBottomBar = [touch locationInView:self.overlayView.bottomBar];
        CGPoint panPointInTopBar = [touch locationInView:self.overlayView.topBar];
        if ([self.overlayView.bottomBar pointInside:panPointInBottomBar withEvent:nil]
            || [self.overlayView.topBar pointInside:panPointInTopBar withEvent:nil])
        {
            //如果上下bar显示时，touch是从上下bar的范围开始的，则不识别为pan调音量
            return NO;
        }
    }
    return YES;
}

#pragma mark - GestureRecognizerEvent
// 处理皮肤的隐／现
- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    if ([self.overlayView isBarVisiable]) {
        [self.overlayView ck_animateHideBars];
    } else {
        [self.overlayView ck_animateShowBars];
    }
}

// 处理音量和亮度
- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    CGPoint location = [recognizer locationInView:self.player];
    CGPoint point = [recognizer translationInView:recognizer.view];
    
    if (location.x > kCKScreenWidth * 0.5) {
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            self.lastVolume = [self ck_GetCurrentVolume];
        }
        
        float volumeDelta = point.y / (recognizer.view.bounds.size.height) * 0.5;
        float newVolume = self.lastVolume - volumeDelta;
        
        [self ck_SetVolume:newVolume];
        
    } else {
        
        float brightness = [UIScreen mainScreen].brightness;  //0 .. 1.0
        float delta = -point.y / recognizer.view.bounds.size.height * 0.1;
        
        brightness = ((brightness + delta) >= 1) ? 1 : (brightness + delta) ;
        brightness = (brightness <= 0) ? 0 : brightness ;
        
        [[UIScreen mainScreen] setBrightness:brightness];
    }
}
// 处理快进和快退
- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    switch (recognizer.direction)
    {
        case UISwipeGestureRecognizerDirectionRight:
        {
            //快进
            float currentPlaybackTime = [self.player playBackTime];
            [self.player ck_seekToTime:(currentPlaybackTime + 10.f)];
        }
            break;
        case UISwipeGestureRecognizerDirectionLeft:
        {
            //快退
            float currentPlaybackTime = [self.player playBackTime];
            [self.player ck_seekToTime:(currentPlaybackTime - 10.f)];
        }
        default:
            break;
            
    }
}

// 兼容iOS 7.0前后的音量控制
- (float)ck_GetCurrentVolume {
    
    //方法一 通过控制播放器音量 控制音量
    //    return  self.player.volume;
    //方法二 通过控制系统声音 控制音量
    
    if (kCKSystemVersion >= 7) {
        if (_volumeViewSlider) {
            return _volumeViewSlider.value;
        }
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider*)view;
                break;
            }
        }
        return _volumeViewSlider.value;
    } else {
        
        return [[MPMusicPlayerController applicationMusicPlayer] volume];
    }
    
    return [[MPMusicPlayerController applicationMusicPlayer] volume];
    
}

- (void)ck_SetVolume:(float)newVolume {
    //方法一 通过控制播放器音量 控制音量
    //     [self.player setVolume:newVolume];
    
    //方法二 通过控制系统声音 控制音量
    newVolume = newVolume > 1 ? 1 : newVolume;
    newVolume = newVolume < 0 ? 0 : newVolume;
    
    if (kCKSystemVersion >= 7) {
        [self.volumeViewSlider setValue:newVolume animated:NO];
    } else {
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:newVolume];
    }
}



#pragma mark -  播放器代理
- (BOOL)ck_AVPlayerVideoShouldPlay:(CKAVPlayer *)avPlayer {
    if ([self.delegate respondsToSelector:@selector(ck_AVPlayerVideoShouldPlay:)]) {
        return [self.delegate ck_AVPlayerVideoShouldPlay:avPlayer];
    }else {
        return YES;
    }
}
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer playerStatusDidChange:(CKAVPlayerStatus)status error:(NSError *)error {
    if (error) {
        NSLog(@"VideoPlayer ERROR >>> %@",error);
    }
    switch (status) {
        case CKAVPlayerStatusUnKnow: {
            [self.overlayView ck_showLoadingIndicator:nil];
            break;
        }
        case CKAVPlayerStatusLoadVideoInfo: {
            [self.overlayView ck_showLoadingIndicator:nil];
            break;
        }
        case CKAVPlayerStatusReadyToPlay: {
            [self.overlayView ck_hideLoadingIndicator:nil];
            self.overlayView.durationSlider.minimumValue = 0.f;
            self.overlayView.durationSlider.maximumValue = avPlayer.totalDuration;
            [self.overlayView ck_setTimeLabelValues:0 totalTime:avPlayer.totalDuration];
            [self enableSlider:YES];
            break;
        }
        case CKAVPlayerStatusBuffering: {
            [self.overlayView ck_showLoadingIndicator:nil];
            break;
        }
        case CKAVPlayerStatusBufferFinished: {
            [self.overlayView ck_hideLoadingIndicator:nil];
            break;
        }
        case CKAVPlayerStatusPlayedToTheEnd: {
            break;
        }
        case CKAVPlayerStatusError: {
            NSLog(@"ERROR");
            break;
        }
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(ck_AVPlayer:playerStatusDidChange:error:)]) {
        [self.delegate ck_AVPlayer:avPlayer playerStatusDidChange:status error:error];
    }
}

- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer timeControlStatusDidChange:(CKAVPlayerTimeControlStatus)status {
    if ([self.delegate respondsToSelector:@selector(ck_AVPlayer:timeControlStatusDidChange:)]) {
        [self.delegate ck_AVPlayer:avPlayer timeControlStatusDidChange:status];
    }
}

- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer timeDidChange:(NSTimeInterval)time {
//    NSLog(@"player currentTime >>> %f",time);
    if (!self.isSeeking) {
        self.overlayView.durationSlider.value = time;
        [self.overlayView ck_setTimeLabelValues:time totalTime:avPlayer.totalDuration];
    }
    if ([self.delegate respondsToSelector:@selector(ck_AVPlayer:timeDidChange:)]) {
        [self.delegate ck_AVPlayer:avPlayer timeDidChange:time];
    }
}

- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer loadedTimeDidChange:(NSTimeInterval)time {
    if (self.isSeeking) {
        return;
    }
    [self.overlayView.durationSlider ck_setPlayableValue:time/avPlayer.totalDuration];
    if ([self.delegate respondsToSelector:@selector(ck_AVPlayer:loadedTimeDidChange:)]) {
        [self.delegate ck_AVPlayer:avPlayer loadedTimeDidChange:time];
    }
}


#pragma mark -
#pragma mark -  播放器控制
#pragma mark -  播放暂停
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
#pragma mark -  滑动条
- (void)durationSliderTouchBegan:(UISlider *)slider {
    self.isSeeking = YES;
}

- (void)durationSliderValueChanged:(UISlider *)slider {
    [NSObject cancelPreviousPerformRequestsWithTarget:self.overlayView
                                             selector:@selector(ck_animateHideBars)
                                               object:nil];
}

- (void)durationSliderTouchEnded:(UISlider *)slider {
    [self.player ck_seekToTime:floor(slider.value)];
    [self.overlayView performSelector:@selector(ck_animateHideBars)
                           withObject:nil
                           afterDelay:5.0];
    self.isSeeking = NO;
}


- (void)enableSlider: (BOOL)shouldEnableSlider
{
    //未设置slider是否可见
    if (shouldEnableSlider) {
        self.overlayView.durationSlider.enabled = YES;
        [self.overlayView.durationSlider addTarget:self
                                               action:@selector(durationSliderValueChanged:)
                                     forControlEvents:UIControlEventValueChanged];
        
        [self.overlayView.durationSlider addTarget:self
                                               action:@selector(durationSliderTouchBegan:)
                                     forControlEvents:UIControlEventTouchDown];
        
        [self.overlayView.durationSlider addTarget:self
                                               action:@selector(durationSliderTouchEnded:)
                                     forControlEvents:UIControlEventTouchUpInside];
        
        [self.overlayView.durationSlider addTarget:self
                                               action:@selector(durationSliderTouchEnded:)
                                     forControlEvents:UIControlEventTouchUpOutside];
    } else {
        self.overlayView.durationSlider.enabled = NO;
        [self.overlayView.durationSlider removeTarget:self
                                                  action:@selector(durationSliderValueChanged:)
                                        forControlEvents:UIControlEventValueChanged];
        
        [self.overlayView.durationSlider removeTarget:self
                                                  action:@selector(durationSliderTouchBegan:)
                                        forControlEvents:UIControlEventTouchDown];
        
        [self.overlayView.durationSlider removeTarget:self
                                                  action:@selector(durationSliderTouchEnded:)
                                        forControlEvents:UIControlEventTouchUpInside];
        
        [self.overlayView.durationSlider removeTarget:self
                                                  action:@selector(durationSliderTouchEnded:)
                                        forControlEvents:UIControlEventTouchUpOutside];
    }
}

#pragma mark -  返回事件
- (void)backButtonClick:(UIButton *)button {
    if (self.fullScreenStatus == CKAVPlayerFullScreenStatusBeFullScreen) {
        [self.overlayView.fullScreenButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }else if (self.fullScreenStatus == CKAVPlayerFullScreenStatusBeNormal ) {
        if ([self.delegate respondsToSelector:@selector(ck_AVPlayerBackButtonClickOnNormailWithPlayer:)]) {
            [self.delegate ck_AVPlayerBackButtonClickOnNormailWithPlayer:self.player];
        }
    }
}

#pragma mark -  全屏事件
- (void)fullScreenButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
//        [self changeDeviceOrientation:UIInterfaceOrientationLandscapeLeft];
        [self enterFullSCreen];
    }else {
//        [self changeDeviceOrientation:UIInterfaceOrientationPortrait];
        [self exitFullscreen];
        
    }
}

- (void)setFullScreenStatus:(CKAVPlayerFullScreenStatus)fullScreenStatus {
    _fullScreenStatus = fullScreenStatus;
    self.overlayView.playerStatus = fullScreenStatus;
    if ([self.delegate respondsToSelector:@selector(ck_AVPlayer:fullScreenStatus:)]) {
        [self.delegate ck_AVPlayer:self.player fullScreenStatus:fullScreenStatus];
    }
}

////手动设置设备方向，这样就能收到转屏事件
//- (void)changeDeviceOrientation:(UIInterfaceOrientation)toOrientation
//{
//    NSString *orientationBase64Str = @"c2V0T3JpZW50YXRpb246";
//    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:orientationBase64Str options:0];
//    NSString *selectorStr = [[NSString alloc] initWithData:decodeData encoding:NSASCIIStringEncoding];
//    SEL selector = NSSelectorFromString(selectorStr);
//    if ([[UIDevice currentDevice] respondsToSelector:selector])
//    {
//        //        NSLog(@"手动设置设备方向，这样就能收到转屏事件");
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//        [invocation setSelector:selector];
//        [invocation setTarget:[UIDevice currentDevice]];
//        int val = toOrientation;
//        [invocation setArgument:&val atIndex:2];
//        [invocation invoke];
//    }
//}

//// deviceDidChangeStatusBarOrientation
//- (void)deviceDidChangeStatusBarOrientation: (NSNotification*)notify
//{
////    UIViewController *currentVC = [ZXApplicationTools getCurrentVC];
//    //收到的消息是上一个InterfaceOrientation的值
//    UIInterfaceOrientation currInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//    switch (currInterfaceOrientation)
//    {
//        case UIInterfaceOrientationPortrait:
//        case UIInterfaceOrientationPortraitUpsideDown:
//        {
//            if (self.player) {
//                float width = self.originalFrame.size.width;
//                float height = self.originalFrame.size.height;
//                float originX = self.originalFrame.origin.x;
//                float originY = self.originalFrame.origin.y;
//                [self.player.superview setNeedsUpdateConstraints];
//                [self.player setNeedsUpdateConstraints];
//                [self.player.superview.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    @autoreleasepool {
//                        if (obj.firstItem == self.player) {
//                            if (obj.firstAttribute == NSLayoutAttributeLeft) {
//                                obj.constant = originX;
//                            }else if (obj.firstAttribute == NSLayoutAttributeTop) {
//                                obj.constant = originY;
//                            }
//                        }
//                        
//                    }
//                }];
//                [self.player.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    @autoreleasepool {
//                        if (obj.firstAttribute == NSLayoutAttributeWidth) {
//                            obj.constant = width;
//                        }else if (obj.firstAttribute == NSLayoutAttributeHeight) {
//                            obj.constant = height;
//                        }
//                    }
//                }];
//                [self.player.superview updateConstraintsIfNeeded];
//                [self.player updateConstraintsIfNeeded];
//                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                    [UIApplication sharedApplication].statusBarHidden = NO;
//                    [self.player.superview layoutIfNeeded];
//                    [self.player layoutIfNeeded];
//                }completion:^(BOOL finish){
//                    self.fullScreenStatus = CKAVPlayerFullScreenStatusBeNormal;
//                }];
//            }
//        }
//            break;
//        case UIInterfaceOrientationLandscapeLeft:
//        case UIInterfaceOrientationLandscapeRight:
//        {
//            if (self.player) {
//                if (!self.originalFrame.size.width) {
//                    self.originalFrame = self.player.frame;
//                }
//                [UIApplication sharedApplication].statusBarHidden = YES;
//                CGRect frame = [UIScreen mainScreen].bounds;
//                float width = frame.size.width;
//                float height = frame.size.height;
//                [self.player.superview setNeedsUpdateConstraints];
//                [self.player setNeedsUpdateConstraints];
//                [self.player.superview.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    @autoreleasepool {
//                        if (obj.firstItem == self.player) {
//                            if (obj.firstAttribute == NSLayoutAttributeLeft) {
//                                obj.constant = 0;
//                            }else if (obj.firstAttribute == NSLayoutAttributeTop) {
//                                obj.constant = 0;
//                            }
//                        }
//                    }
//                }];
//                [self.player.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    @autoreleasepool {
//                        if (obj.firstAttribute == NSLayoutAttributeWidth) {
//                            obj.constant = width;
//                        }else if (obj.firstAttribute == NSLayoutAttributeHeight) {
//                            obj.constant = height;
//                        }
//                    }
//                }];
//                [self.player.superview updateConstraintsIfNeeded];
//                [self.player updateConstraintsIfNeeded];
//                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                    [UIApplication sharedApplication].statusBarHidden = YES;
//                    [self.player.superview layoutIfNeeded];
//                    [self.player layoutIfNeeded];
//                }completion:^(BOOL finish){
//                    self.fullScreenStatus = CKAVPlayerFullScreenStatusBeFullScreen;
//                }];
//            }
//        }
//            break;
//            
//        default:
//            break;
//    }
//}

- (void)enterFullSCreen {
    if (self.fullScreenStatus != CKAVPlayerFullScreenStatusBeNormal) {
        return;
    }
//    NSLog(@" >>>>>> \n%@",self.player.constraints);
//    NSLog(@" SUPER VIEW>>>>>> %@",self.player.superview.constraints);
    
    UIWindow *winodow = [UIApplication sharedApplication].keyWindow;
    
    playerConArray = [NSMutableArray array];
    playerSuperViewConArray = [NSMutableArray array];
    
    [self.player.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            if (obj.firstItem == self.player && obj.secondItem == nil) {
                [playerConArray addObject:obj];
            }
        }
    }];
    
    [self.player.superview.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            if (obj.firstItem == self.player || obj.secondItem == self.player) {
                [playerSuperViewConArray addObject:obj];
            }
        }
    }];
    
    /*
     * 记录进入全屏前的parentView和frame
     */
    self.player.normalParentView = self.player.superview;

    CGRect rectInWindow = [self.player convertRect:self.player.bounds toView:[UIApplication sharedApplication].keyWindow];
    [self.player removeFromSuperview];
    [self.player removeConstraints:playerConArray];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.player];
    
    NSLayoutConstraint *templeftCon = [NSLayoutConstraint constraintWithItem:self.player
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:winodow
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1.0
                                                                constant:rectInWindow.origin.x];
    NSLayoutConstraint *temptopCon = [NSLayoutConstraint constraintWithItem:self.player
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:winodow
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:rectInWindow.origin.y];
    
    NSLayoutConstraint *tempwidthCon = [NSLayoutConstraint constraintWithItem:self.player
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:rectInWindow.size.width];
    NSLayoutConstraint *tempheightCon = [NSLayoutConstraint constraintWithItem:self.player
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:rectInWindow.size.height];
    
    [winodow addConstraint:temptopCon];
    [winodow addConstraint:templeftCon];
    
    [self.player addConstraint:tempwidthCon];
    [self.player addConstraint:tempheightCon];
    
    [winodow layoutIfNeeded];
    
    [winodow removeConstraint:temptopCon];
    [winodow removeConstraint:templeftCon];
    
    [self.player removeConstraint:tempwidthCon];
    [self.player removeConstraint:tempheightCon];
    
    [winodow addConstraint:[NSLayoutConstraint constraintWithItem:self.player
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:winodow
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    [winodow addConstraint:[NSLayoutConstraint constraintWithItem:self.player
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:winodow
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];
    [self.player addConstraint:({
        widthCon = [NSLayoutConstraint constraintWithItem:self.player
                                                attribute:NSLayoutAttributeWidth
                                                relatedBy:NSLayoutRelationEqual
                                                   toItem:nil
                                                attribute:NSLayoutAttributeNotAnAttribute
                                               multiplier:1.0
                                                 constant:CGRectGetHeight(self.player.superview.bounds)];
        widthCon;
    })];
    [self.player addConstraint:({
        heightCon = [NSLayoutConstraint constraintWithItem:self.player
                                                 attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nil
                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                multiplier:1.0
                                                  constant:CGRectGetWidth(self.player.superview.bounds)];
        heightCon;
    })];
    /*
     * 执行动画
     */
    [UIView animateWithDuration:0.5 animations:^{
        self.player.transform = CGAffineTransformMakeRotation(M_PI_2);
        [winodow layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.fullScreenStatus = CKAVPlayerFullScreenStatusBeFullScreen;
        [self.player setNeedsDisplay];
    }];
    
    [self refreshStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)exitFullscreen {
    
    if (self.fullScreenStatus != CKAVPlayerFullScreenStatusBeFullScreen) {
        return;
    }
    [self.player removeFromSuperview];
     [self.player.normalParentView addSubview:self.player];
    [self.player removeConstraint:widthCon];
    [self.player removeConstraint:heightCon];
    [self.player addConstraints:playerConArray];
    [self.player.normalParentView addConstraints:playerSuperViewConArray];

    [UIView animateWithDuration:0.5 animations:^{
        self.player.transform = CGAffineTransformIdentity;
        [self.player.normalParentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        /*
         * movieView回到小屏位置
         */
        self.fullScreenStatus = CKAVPlayerFullScreenStatusBeNormal;
    }];
    
    [self refreshStatusBarOrientation:UIInterfaceOrientationPortrait];
}

- (void)refreshStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation animated:YES];
}


#pragma mark -
#pragma mark -  外部接口

/**
 设置播放信息

 @param url 视频播放地址
 */
- (void)ck_playWithURL:(NSURL *)url {
    [self.player ck_playWithURL:url];
}
/**
 播放
 */
- (void)ck_play {
    self.overlayView.playPauseButton.selected = YES;
    //播放
    [self.player ck_play];
}
/**
 暂停
 */
- (void)ck_pause {
    self.overlayView.playPauseButton.selected = NO;
    //播放
    [self.player ck_pause];
}
/**
 停止
 */
- (void)ck_stop {
    self.overlayView.playPauseButton.selected = NO;
    [self.player ck_stop];
}

- (NSTimeInterval)currentTime {
    return self.player.playBackTime;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.overlayView.titleLabel.text = title;
}

- (CKAVPlayerTimeControlStatus)timeControlStatus {
    return self.player.timeControlStatus;
}
@end

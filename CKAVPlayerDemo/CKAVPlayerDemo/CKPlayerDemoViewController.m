//
//  CKPlayerDemoViewController.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKPlayerDemoViewController.h"
#import "CKAVPlayerController.h"

@interface CKPlayerDemoViewController ()<CKAVPlayerControllerDelegate>

@property (nonatomic, strong) CKAVPlayerController *videoPlayerController;

@end

@implementation CKPlayerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.videoPlayerController = [[CKAVPlayerController alloc] init];
    [self.view addSubview:self.videoPlayerController.view];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayerController.view
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayerController.view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:64]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayerController.view
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0]];
    [self.videoPlayerController.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayerController.view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:[UIScreen mainScreen].bounds.size.width * 9/16.0]];
    [self.videoPlayerController ck_playWithURL:[NSURL URLWithString:@"http://znf.oss-cn-shanghai.aliyuncs.com/course/znf2017031401/znf2017031401001.mp4"]];
    self.videoPlayerController.delegate = self;
    self.videoPlayerController.title = @"fuckTitle";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -  delegate
- (void)ck_AVPlayer:(CKAVPlayer *)avPlayer fullScreenStatus:(CKAVPlayerFullScreenStatus)status {
    if (status == CKAVPlayerFullScreenStatusBeFullScreen) {
        self.navigationController.navigationBarHidden = YES;
    }else {
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)ck_AVPlayerBackButtonClickOnNormailWithPlayer:(CKAVPlayer *)avPlayer {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -  点击事件
- (IBAction)playAction:(UIButton *)sender {
    [self.videoPlayerController ck_play];
}
- (IBAction)pauseAction:(UIButton *)sender {
    [self.videoPlayerController ck_pause];
}

- (IBAction)stopAction:(UIButton *)sender {
    [self.videoPlayerController ck_stop];
}



@end

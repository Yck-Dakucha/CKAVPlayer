//
//  CKPlayerDemoViewController.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/24.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKPlayerDemoViewController.h"
#import "CKAVPlayerController.h"

@interface CKPlayerDemoViewController ()

@property (nonatomic, strong) CKAVPlayerController *videoPlayerController;

@end

@implementation CKPlayerDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.videoPlayerController = [[CKAVPlayerController alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 9/16.0)];
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (IBAction)playAction:(UIButton *)sender {
    [self.videoPlayerController ck_play];
}
- (IBAction)pauseAction:(UIButton *)sender {
    [self.videoPlayerController ck_pause];
}

- (IBAction)stopAction:(UIButton *)sender {
}

@end

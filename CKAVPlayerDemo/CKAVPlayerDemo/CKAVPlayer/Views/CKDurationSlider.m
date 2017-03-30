//
//  CKDurationSlider.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/29.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKDurationSlider.h"

#define POINT_OFFSET    (2)

@interface CKDurationSlider ()

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation CKDurationSlider

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.maximumTrackTintColor = [UIColor clearColor];
        self.minimumTrackTintColor = [UIColor orangeColor];
        
        _progressView = [[UIProgressView alloc] init];
        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
        self.progressView.userInteractionEnabled = NO;
        self.progressView.progressViewStyle = UIProgressViewStyleDefault;
        self.progressView.progressTintColor = [UIColor colorWithRed:174.0/255.0 green:173.0/255.0 blue:166.0/255.0 alpha:1.0];
        self.progressView.trackTintColor = [UIColor colorWithRed:98.0/255.0 green:97.0/255.0 blue:88.0/255.0 alpha:1.0];
        [self addProgressViewConstraint];
    }
    return self;
}

//- (void)setFrame:(CGRect)frame {
//    [super setFrame:frame];
//    if (self.progressView == nil) {
//        return;
//    }
//    
//    CGRect rect = self.bounds;
//    rect.size.width -= POINT_OFFSET * 2;
//    
//    self.progressView.bounds = rect;
//    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//        self.progressView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
//}

- (void)addProgressViewConstraint {
    [self addSubview:self.progressView];
    [self sendSubviewToBack:self.progressView];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                      constant:- POINT_OFFSET * 2]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0]];
    
}

- (void)ck_setPlayableValue:(CGFloat)duration {
    self.progressView.progress = duration;
}

//点击seek
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //不要调用super方法，否则事件发两次
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat scale = point.x / self.bounds.size.width;
    [self setValue:(scale * self.maximumValue) animated:YES];
    [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

- (void)dealloc {
    self.progressView = nil;
}


@end

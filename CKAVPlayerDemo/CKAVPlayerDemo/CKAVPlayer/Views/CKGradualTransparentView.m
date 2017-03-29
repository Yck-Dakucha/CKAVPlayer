//
//  CKGradualTransparentView.m
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/28.
//  Copyright © 2017年 yck. All rights reserved.
//

#import "CKGradualTransparentView.h"

@implementation CKGradualTransparentView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setupColor];
        self.type = CKGradualTransoarentViewTypeUpToDown;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setupColor];
        self.type = CKGradualTransoarentViewTypeUpToDown;
    }
    return self;
}

- (void)setType:(CKGradualTransoarentViewType)type {
    _type = type;
    switch (type) {
        case CKGradualTransoarentViewTypeUpToDown: {
            _startPoint = CGPointMake(0, 0);
            _endPoint = CGPointMake(0, 1);
            break;
        }
        case CKGradualTransoarentViewTypeDownToUp: {
            _startPoint = CGPointMake(0, 1);
            _endPoint = CGPointMake(0, 0);
            break;
        }
        case CKGradualTransoarentViewTypeLeftToRight: {
            _startPoint = CGPointMake(0, 0);
            _endPoint = CGPointMake(1, 0);
            break;
        }
        case CKGradualTransoarentViewTypeRightToLeft: {
            _startPoint = CGPointMake(1, 0);
            _endPoint = CGPointMake(0, 0);
            break;
        }
        default:
            break;
    }
    [self setupDirection];
}


#pragma mark - private
- (void)setupColor {
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[[[UIColor blackColor] colorWithAlphaComponent:0.65] CGColor] ,
                            (id)[[[UIColor blackColor] colorWithAlphaComponent:0.0] CGColor],
                            nil];
}

- (void)setupDirection {
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.startPoint = _startPoint;
    gradientLayer.endPoint = _endPoint;
}
@end

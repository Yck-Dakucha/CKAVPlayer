//
//  CKGradualTransparentView.h
//  CKAVPlayerDemo
//
//  Created by Yck on 2017/3/28.
//  Copyright © 2017年 yck. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CKGradualTransoarentViewType) {
    CKGradualTransoarentViewTypeUpToDown,
    CKGradualTransoarentViewTypeDownToUp,
    CKGradualTransoarentViewTypeLeftToRight,
    CKGradualTransoarentViewTypeRightToLeft,
};

/**
 半透明视图
 */
@interface CKGradualTransparentView : UIView

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;

@property (nonatomic, assign) CKGradualTransoarentViewType type;

@end

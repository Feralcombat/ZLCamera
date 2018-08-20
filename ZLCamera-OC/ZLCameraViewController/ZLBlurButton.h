//
//  ZLBlurButton.h
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ZLBlurButtonActionType) {
    ZLBlurButtonActionTypeTap,
    ZLBlurButtonActionTypeLongPress,
};

@class ZLBlurButton;
@protocol ZLBlurButtonDelegate <NSObject>
@optional
- (void)blurButtonPressed:(ZLBlurButton *)button;
- (void)blurButtonLongPressed:(ZLBlurButton *)button isStart:(BOOL)isStart;
@end

@interface ZLBlurButton : UIVisualEffectView
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, weak) id<ZLBlurButtonDelegate> delegate;

- (void)setProgress:(CGFloat)progress;
- (void)requestEndLongPress;
@end

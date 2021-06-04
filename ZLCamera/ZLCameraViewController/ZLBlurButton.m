//
//  ZLBlurButton.m
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import "ZLBlurButton.h"
#import "ZLProgressView.h"
#import <Masonry/Masonry.h>

@interface ZLBlurButton ()
@property (nonatomic, strong) ZLProgressView *progressView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;
@end

@implementation ZLBlurButton

- (void)dealloc{
    [self.longGesture removeObserver:self forKeyPath:@"state"];
}

- (instancetype)initWithEffect:(UIVisualEffect *)effect{
    self = [super initWithEffect:effect];
    if (self) {
        self.circleView = [[UIView alloc] init];
        self.circleView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0  blue:245.0/255.0  alpha:1.0f];
        [self.contentView addSubview:self.circleView];
        
        self.progressView = [[ZLProgressView alloc] initWithFrame:CGRectZero];
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        
        self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        self.longGesture.minimumPressDuration = 0.8;
        
        [self.circleView addGestureRecognizer:self.tapGesture];
        [self.circleView addGestureRecognizer:self.longGesture];
        
        [self.longGesture addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.contentView);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(60);
        }];
    }
    return self;
}

- (void)tap:(UIGestureRecognizer *)sender{

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.25;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSValue *animationValue1 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    NSValue *animationValue2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)];
    NSValue *animationValue3 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.6, 0.6, 1.0)];
    NSValue *animationValue4 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    animation.values = @[animationValue1,animationValue2,animationValue3,animationValue4];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:@"easeInEaseOut"];
    [self.circleView.layer addAnimation:animation forKey:nil];
    
    if ([self.delegate respondsToSelector:@selector(blurButtonPressed:)]) {
        [self.delegate blurButtonPressed:self];
    }
}

- (void)longPress:(UITapGestureRecognizer *)sender{
    
}

- (void)setProgress:(CGFloat)progress{
    if (![self.contentView.subviews containsObject:self.progressView]) {
        self.progressView.frame = CGRectMake(2, 2, self.contentView.bounds.size.width - 4, self.contentView.bounds.size.height - 4);
        [self.contentView addSubview:self.progressView];
    }
    [self.progressView updateProgress:progress];
}

- (void)requestEndLongPress{
    self.longGesture.enabled = NO;
}

- (void)setSingleClickEnabled:(BOOL)enabled{
    self.tapGesture.enabled = enabled;
}

- (void)setLongPressEnabled:(BOOL)enabled{
    self.longGesture.enabled = enabled;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"state"]) {
        UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
        if (state == UIGestureRecognizerStateBegan) {
            if ([self.delegate respondsToSelector:@selector(blurButtonLongPressed:isStart:)]) {
                [self.delegate blurButtonLongPressed:self isStart:YES];
            }
        }
        else if (state == UIGestureRecognizerStateEnded){
            [self.progressView removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(blurButtonLongPressed:isStart:)]) {
                [self.delegate blurButtonLongPressed:self isStart:NO];
            }
        }
        else if (state == UIGestureRecognizerStateCancelled){
            [self.progressView removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(blurButtonLongPressed:isStart:)]) {
                [self.delegate blurButtonLongPressed:self isStart:NO];
            }
            self.longGesture.enabled = NO;
        }
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end

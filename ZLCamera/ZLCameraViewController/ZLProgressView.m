//
//  ZLProgressView.m
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import "ZLProgressView.h"

@interface ZLProgressView ()
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation ZLProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = [UIColor colorWithRed:78/255.0 green:148/255.0 blue:77/255.0 alpha:1.0].CGColor;
        self.progressLayer.opacity = 1.0f;
        self.progressLayer.lineWidth = 4.0f;
        
        self.progressLayer.shadowColor = [UIColor blackColor].CGColor;
        self.progressLayer.shadowOffset = CGSizeMake(1, 1);
        self.progressLayer.shadowOpacity = 0.5;
        self.progressLayer.shadowRadius = 2;
        [self.layer addSublayer:self.progressLayer];
    }
    return self;
}

- (void)updateProgress:(CGFloat)progress{
    self.progress = progress;
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = self.bounds.size.width/2;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = -M_PI_2 + M_PI * 2 * self.progress;
    self.progressLayer.frame = self.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
}

@end

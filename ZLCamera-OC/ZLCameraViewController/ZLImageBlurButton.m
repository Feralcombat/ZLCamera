//
//  ZLImageBlurButton.m
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import "ZLImageBlurButton.h"
#import <Masonry/Masonry.h>

@interface ZLImageBlurButton ()
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ZLImageBlurButton

- (instancetype)initWithEffect:(UIVisualEffect *)effect{
    self = [super initWithEffect:effect];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setContentImage:(UIImage *)image{
    self.imageView.image = image;
}
@end

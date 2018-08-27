//
//  NSBundle+ZLCamera.m
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/8/27.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import "NSBundle+ZLCamera.h"
#import "ZLCameraComponent.h"

@implementation NSBundle (ZLCamera)

+ (instancetype)zl_Bundle{
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ZLCameraComponent class]] pathForResource:@"ZLCameraBundle" ofType:@"bundle"]];
    }
    return bundle;
}

@end

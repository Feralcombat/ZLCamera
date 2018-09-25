//
//  ZLCameraViewController.h
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import <UIKit/UIKit.h>

/**是否允许拍照*/
UIKIT_EXTERN NSString const* ZLCameraPhotoEnabledKey;
/**是否允许录视频*/
UIKIT_EXTERN NSString const* ZLCameraVideoEnabledKey;
/**视频允许的最大时间*/
UIKIT_EXTERN NSString const* ZLCameraVideoMaxDurationKey;

@class ZLCameraViewController;
@protocol ZLCameraViewControllerDelegate <NSObject>
@optional
- (void)cameraViewControllerDidDismiss:(ZLCameraViewController *)cameraViewController;
- (void)cameraViewController:(ZLCameraViewController *)cameraViewController didFinishPickImage:(UIImage *)image;
- (void)cameraViewController:(ZLCameraViewController *)cameraViewController didFinishPickVideoUrl:(NSURL *)url;
@end

@interface ZLCameraViewController : UINavigationController

/**
 初始化相机

 @param delegate 代理
 @param options 配置
 @return 实例
 */
- (instancetype)initWithDelegate:(id<ZLCameraViewControllerDelegate>)delegate
                         options:(NSDictionary *)options;

@end

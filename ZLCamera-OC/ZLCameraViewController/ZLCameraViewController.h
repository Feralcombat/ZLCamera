//
//  ZLCameraViewController.h
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLCameraViewController;
@protocol ZLCameraViewControllerDelegate <NSObject>
@optional
- (void)cameraViewControllerDidDismiss:(ZLCameraViewController *)cameraViewController;
- (void)cameraViewController:(ZLCameraViewController *)cameraViewController didFinishPickImage:(UIImage *)image;
- (void)cameraViewController:(ZLCameraViewController *)cameraViewController didFinishPickVideoUrl:(NSURL *)url;
@end

@interface ZLCameraViewController : UINavigationController

- (instancetype)initWithDelegate:(id<ZLCameraViewControllerDelegate>)delegate;
@end

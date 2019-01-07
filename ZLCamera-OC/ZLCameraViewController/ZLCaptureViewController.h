//
//  ZLCaptureViewController.h
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLCaptureViewController;
@protocol ZLCaptureViewControllerDelegate <NSObject>
@optional
- (void)captureViewControllerDidDismiss:(ZLCaptureViewController *)captureViewController;
- (void)captureViewController:(ZLCaptureViewController *)captureViewController didFinishPickImage:(UIImage *)image;
- (void)captureViewController:(ZLCaptureViewController *)captureViewController didFinishPickVideo:(NSURL *)url;
@end

@interface ZLCaptureViewController : UIViewController
@property (nonatomic, weak) id<ZLCaptureViewControllerDelegate> delegate;
@property (nonatomic, assign) CGFloat maxVideoDuration;
@property (nonatomic, assign) BOOL photoEnabled;
@property (nonatomic, assign) BOOL videoEnabled;
/**裁剪框默认允许的比例*/
@property (nonatomic, assign) CGSize customAspectRatio;
/**是否是等比例裁切*/
@property (nonatomic, assign)  BOOL aspectRatioLockEnabled;
@end

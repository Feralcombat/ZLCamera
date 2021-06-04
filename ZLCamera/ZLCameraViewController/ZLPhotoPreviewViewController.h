//
//  ZLPhotoPreviewViewController.h
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLPhotoPreviewViewController;
@protocol ZLPhotoPreviewViewControllerDelegate <NSObject>

@optional
- (void)photoPreviewViewController:(ZLPhotoPreviewViewController *)previewViewController didFinishPickImage:(UIImage *)image;

@end

@interface ZLPhotoPreviewViewController : UIViewController
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, weak) id<ZLPhotoPreviewViewControllerDelegate> delegate;

/**裁剪框默认允许的比例*/
@property (nonatomic, assign) CGSize customAspectRatio;
/**是否是等比例裁切*/
@property (nonatomic, assign)  BOOL aspectRatioLockEnabled;
@end

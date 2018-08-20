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
@end

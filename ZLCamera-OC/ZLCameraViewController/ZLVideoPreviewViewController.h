//
//  ZLVideoPreviewViewController.h
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZLVideoPreviewViewController;
@protocol ZLVideoPreviewViewControllerDelegate <NSObject>

@optional
- (void)videoPreviewViewController:(ZLVideoPreviewViewController *)videoPreviewViewController didFinishPickVideoUrl:(NSURL *)url;

@end

@interface ZLVideoPreviewViewController : UIViewController
@property (nonatomic, copy) NSURL *playerUrl;
@property (nonatomic, weak) id<ZLVideoPreviewViewControllerDelegate> delegate;
@end

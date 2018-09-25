//
//  ZLCameraViewController.m
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import "ZLCameraViewController.h"
#import "ZLCaptureViewController.h"

NSString const* ZLCameraPhotoEnabledKey = @"ZLCameraPhotoEnabledKey";
NSString const* ZLCameraVideoEnabledKey = @"ZLCameraVideoEnabledKey";
NSString const* ZLCameraVideoMaxDurationKey = @"ZLCameraVideoMaxDurationKey";

@interface ZLCameraViewController ()<UINavigationControllerDelegate,ZLCaptureViewControllerDelegate>
@property (nonatomic, weak) id<ZLCameraViewControllerDelegate> cameraDelegate;
@end

@implementation ZLCameraViewController

- (instancetype)initWithDelegate:(id<ZLCameraViewControllerDelegate>)delegate options:(NSDictionary *)options{
    ZLCaptureViewController *captureVC = [[ZLCaptureViewController alloc] init];
    self = [super initWithRootViewController:captureVC];
    if (self) {
        self.cameraDelegate = delegate;
        BOOL photoEnabled = YES;
        BOOL videoEnabled = YES;
        CGFloat maxVideoDuration = 30;
        if (options) {
            NSNumber *photoEnabledValue = [options objectForKey:ZLCameraPhotoEnabledKey];
            NSNumber *videoEnabledValue = [options objectForKey:ZLCameraVideoEnabledKey];
            NSNumber *maxVideoDurationValue = [options objectForKey:ZLCameraVideoMaxDurationKey];
            if (photoEnabledValue) {
                photoEnabled = [photoEnabledValue boolValue];
            }
            if (videoEnabledValue) {
                videoEnabled = [videoEnabledValue boolValue];
            }
            if (maxVideoDurationValue) {
                maxVideoDuration = [maxVideoDurationValue floatValue];
            }
        }
        captureVC.photoEnabled = photoEnabled;
        captureVC.videoEnabled = videoEnabled;
        captureVC.maxVideoDuration = maxVideoDuration;
        captureVC.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZLCaptureViewControllerDelegate
- (void)captureViewControllerDidDismiss:(ZLCaptureViewController *)captureViewController{
    if ([self.cameraDelegate respondsToSelector:@selector(cameraViewControllerDidDismiss:)]){
        [self.cameraDelegate cameraViewControllerDidDismiss:self];
    }
}

- (void)captureViewController:(ZLCaptureViewController *)captureViewController didFinishPickImage:(UIImage *)image{
    if ([self.cameraDelegate respondsToSelector:@selector(cameraViewController:didFinishPickImage:)]){
        [self.cameraDelegate cameraViewController:self didFinishPickImage:image];
    }
}

- (void)captureViewController:(ZLCaptureViewController *)captureViewController didFinishPickVideo:(NSURL *)url{
    if ([self.cameraDelegate respondsToSelector:@selector(cameraViewController:didFinishPickVideoUrl:)]){
        [self.cameraDelegate cameraViewController:self didFinishPickVideoUrl:url];
    }
}

#pragma mark - UINavigationControllerDelegate
- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController{
    return UIInterfaceOrientationPortrait;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationNone) {
        return nil;
    }
    else if (operation == UINavigationControllerOperationPush){
        return toVC;
    }
    else{
        return fromVC;
    }
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

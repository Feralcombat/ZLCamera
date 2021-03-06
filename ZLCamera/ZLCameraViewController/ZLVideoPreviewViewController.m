//
//  ZLVideoPreviewViewController.m
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import "ZLVideoPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZLImageBlurButton.h"
#import "ZLConstant.h"
#import <Masonry/Masonry.h>

@interface ZLVideoPreviewViewController ()<UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) ZLImageBlurButton *backButton;
@property (nonatomic, strong) UIButton *confirmButton;
@end

@implementation ZLVideoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadUI];
    self.transitioningDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)confirmButton_pressed:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(videoPreviewViewController:didFinishPickVideoUrl:)]) {
        [self.delegate videoPreviewViewController:self didFinishPickVideoUrl:self.playerUrl];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)backButton_pressed:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)loadUI{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerItem = [[AVPlayerItem alloc] initWithURL:self.playerUrl];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playerLayer];
    
    [player play];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0f];
    self.confirmButton.frame = CGRectMake((ZLDeviceWidth - 80)/2, ZLDeviceHeight - 112, 80, 80);
    [self.confirmButton setImage:[UIImage imageNamed:@"video_icon_back_student" inBundle:[NSBundle bundleWithPath:ZLBundlePath] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.confirmButton.layer.cornerRadius = 40.0f;
    self.confirmButton.clipsToBounds = YES;
    [self.confirmButton addTarget:self action:@selector(confirmButton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
    
    self.backButton = [[ZLImageBlurButton alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    [self.backButton setContentImage:[UIImage imageNamed:@"video_icon_back" inBundle:[NSBundle bundleWithPath:ZLBundlePath] compatibleWithTraitCollection:nil]];
    self.backButton.frame = CGRectMake((ZLDeviceWidth - 80)/2, ZLDeviceHeight - 112, 80, 80);
    self.backButton.layer.cornerRadius = 40;
    self.backButton.clipsToBounds = true;
    [self.view addSubview:self.backButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backButton_pressed:)];
    [self.backButton addGestureRecognizer:tapGesture];
    
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    __weak typeof(self)weakSelf = self;
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:self.view];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        weakSelf.backButton.frame = CGRectMake((ZLDeviceWidth - 80)/2 - 64, ZLDeviceHeight - 112, 80, 80);
        weakSelf.confirmButton.frame = CGRectMake((ZLDeviceWidth - 80)/2 + 64, ZLDeviceHeight - 112, 80, 80);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self;
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

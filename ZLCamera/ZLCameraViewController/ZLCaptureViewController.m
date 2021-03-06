//
//  ZLCaptureViewController.m
//  ZLCamera-OC
//
//  Created by 周麟 on 2018/7/5.
//  Copyright © 2018年 周麟. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ZLCaptureViewController.h"
#import "ZLVideoPreviewViewController.h"
#import "ZLPhotoPreviewViewController.h"
#import "ZLBlurButton.h"
#import "ZLConstant.h"
#import "UIImage+ZLFixOrientation.h"
#import <Masonry/Masonry.h>
#import <TOCropViewController/TOCropViewController.h>

@interface ZLCaptureViewController ()<ZLBlurButtonDelegate,UIAlertViewDelegate,AVCaptureFileOutputRecordingDelegate,ZLVideoPreviewViewControllerDelegate,ZLPhotoPreviewViewControllerDelegate,UIGestureRecognizerDelegate, TOCropViewControllerDelegate>
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDevice *audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) ZLBlurButton *snapButton;
@property (nonatomic, strong) UILabel *noticeLabel;
@property (nonatomic, strong) CALayer *focusBoxLayer;
@property (nonatomic, strong) CAAnimation *focusBoxAnimation;

@property (nonatomic, assign) BOOL hasPriority;
@property (nonatomic, assign) BOOL setupComplete;
@property (nonatomic, assign) BOOL needStartSession;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, assign) CGFloat beginGestureScale;
@property (nonatomic, assign) CGFloat effectiveScale;
@property (nonatomic, strong) NSTimer *countTimer;
@property (nonatomic, assign) NSInteger currentTime;
/// 监听当前设备方向
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@end

@implementation ZLCaptureViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self)weakSelf = self;
    [self.navigationController setNavigationBarHidden:YES];
    [self didInitialize];
    
    [self checkAuthorization:^(BOOL granted) {
        if (granted) {
            [self setupCamera:^(BOOL completion) {
                if (completion) {
                    weakSelf.setupComplete = YES;
                    [weakSelf startSession];
                    [weakSelf performSelector:@selector(hideTip) withObject:nil afterDelay:1.5];
                }
            }];
        }
    }];
}

- (void)didInitialize{
    self.needStartSession = YES;
    self.beginGestureScale = 1.0f;
    self.effectiveScale = 1.0f;
    [self setupNotification];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.hasPriority && self.setupComplete && self.needStartSession) {
        [self startSession];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.hasPriority) {
        [self stopSession];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)setupNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)handleDeviceRotate:(NSNotification *)noti{
    UIDevice *currentDevice = noti.object;
    if (UIDeviceOrientationIsFlat(currentDevice.orientation)) {
        return;
    }
    self.currentOrientation = currentDevice.orientation;
}

- (void)startRecord{
    NSString * fileName = [[NSUUID UUID] UUIDString];

    self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(calculateMaxDuration:) userInfo:nil repeats:YES];
    
    NSURL *outputUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mov",NSTemporaryDirectory(),fileName]];
    [self.movieOutput startRecordingToOutputFileURL:outputUrl recordingDelegate:self];
}

- (void)endRecord{
    [self.countTimer invalidate];
    self.countTimer = nil;
    self.currentTime = 0;
    [self.movieOutput stopRecording];
}

- (void)calculateMaxDuration:(NSTimer *)sender{
    self.currentTime++;
    if (self.currentTime > self.maxVideoDuration) {
        [self.snapButton requestEndLongPress];
        [self endRecord];
    }
    else{
        [self.snapButton setProgress:self.currentTime/self.maxVideoDuration];
    }
}

- (void)switchCameraPosition:(UIButton *)sender{
    if (self.videoDevice.position == AVCaptureDevicePositionBack) {
        if ([self isFrontCameraAvailable]) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
        }
        
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionFront) {
                self.videoDevice = device;
                break;
            }
        }
        self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
        
        if ([self.session canAddInput:self.videoInput]) {
            [self.session addInput:self.videoInput];
        }
        [self.session commitConfiguration];
    }
    else{
        if ([self isRearCameraAvailable]) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
        }
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionBack) {
                self.videoDevice = device;
                break;
            }
        }
        self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
        
        if ([self.session canAddInput:self.videoInput]) {
            [self.session addInput:self.videoInput];
        }
        [self.session commitConfiguration];
    }
}

- (void)backButton_pressed:(UIButton *)sender{
    __weak typeof(self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.delegate captureViewControllerDidDismiss:weakSelf];
    }];
}

- (void)captureTapped:(UITapGestureRecognizer *)sender{
    
    CGPoint touchedPoint = [sender locationInView:self.view];
    CGPoint pointOfInterest = [self convertToPointOfInterestFromViewCoordinates:touchedPoint
                                                                   previewLayer:self.previewLayer
                                                                          ports:self.videoInput.ports];
    [self focusAtPoint:pointOfInterest];
    [self showFocusBox:touchedPoint];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.view.layer convertPoint:location fromLayer:self.view.layer];
        if ( ! [self.view.layer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer) {
        _effectiveScale = _beginGestureScale * recognizer.scale;
        if (_effectiveScale < 1.0f)
            _effectiveScale = 1.0f;
        if (_effectiveScale > self.videoDevice.activeFormat.videoMaxZoomFactor)
            _effectiveScale = self.videoDevice.activeFormat.videoMaxZoomFactor;
        NSError *error = nil;
        if ([self.videoDevice lockForConfiguration:&error]) {
            [self.videoDevice rampToVideoZoomFactor:_effectiveScale withRate:100];
            [self.videoDevice unlockForConfiguration];
        } else {
//            [self passError:error];
        }
    }
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = previewLayer.frame.size;
    
    if ( [previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize] ) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in ports) {
            if (port.mediaType == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)addDefaultFocusBox
{
    CALayer *focusBox = [[CALayer alloc] init];
    focusBox.cornerRadius = 5.0f;
    focusBox.bounds = CGRectMake(0.0f, 0.0f, 70, 60);
    focusBox.borderWidth = 3.0f;
    focusBox.borderColor = [[UIColor yellowColor] CGColor];
    focusBox.opacity = 0.0f;
    [self.view.layer addSublayer:focusBox];
    
    CABasicAnimation *focusBoxAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    focusBoxAnimation.duration = 0.75;
    focusBoxAnimation.autoreverses = NO;
    focusBoxAnimation.repeatCount = 0.0;
    focusBoxAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    focusBoxAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    [self alterFocusBox:focusBox animation:focusBoxAnimation];
}

- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation
{
    self.focusBoxLayer = layer;
    self.focusBoxAnimation = animation;
}

- (void)focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = self.videoDevice;
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
//            [self passError:error];
        }
    }
}

- (void)showFocusBox:(CGPoint)point
{
    if(self.focusBoxLayer) {
        // clear animations
        [self.focusBoxLayer removeAllAnimations];
        
        // move layer to the touch point
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        self.focusBoxLayer.position = point;
        [CATransaction commit];
    }
    
    if(self.focusBoxAnimation) {
        // run the animation
        [self.focusBoxLayer addAnimation:self.focusBoxAnimation forKey:@"animateOpacity"];
    }
}

- (void)hideTip{
    self.noticeLabel.hidden = YES;
}

- (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL)isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (void)setupCamera:(void(^)(BOOL completion))completion{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        weakSelf.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        weakSelf.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:weakSelf.videoDevice error:nil];
        
        weakSelf.imageOutput = [[AVCaptureStillImageOutput alloc] init];
        
        weakSelf.session = [[AVCaptureSession alloc] init];
        if ([weakSelf.session canSetSessionPreset:AVCaptureSessionPresetInputPriority]) {
            [weakSelf.session setSessionPreset:AVCaptureSessionPresetInputPriority];
        }
        
        if ([weakSelf.session canAddInput:weakSelf.videoInput]) {
            [weakSelf.session addInput:weakSelf.videoInput];
        }
        
        if ([weakSelf.session canAddOutput:weakSelf.imageOutput]) {
            [weakSelf.session addOutput:weakSelf.imageOutput];
        }
        
        if (weakSelf.videoEnabled) {
            weakSelf.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            weakSelf.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:weakSelf.audioDevice error:nil];
            weakSelf.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
            
            if ([weakSelf.session canAddInput:weakSelf.audioInput]) {
                [weakSelf.session addInput:weakSelf.audioInput];
            }
            
            if ([weakSelf.session canAddOutput:weakSelf.movieOutput]) {
                [weakSelf.session addOutput:weakSelf.movieOutput];
                AVCaptureConnection *connection = [weakSelf.movieOutput connectionWithMediaType:AVMediaTypeVideo];
                if (connection.supportsVideoStabilization) {
                    connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:weakSelf.session];
            weakSelf.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            weakSelf.previewLayer.frame = weakSelf.view.bounds;
            [weakSelf.view.layer addSublayer:weakSelf.previewLayer];
            
            [weakSelf loadUI];
            completion(YES);
        });
    });
}

- (void)startSession{
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)stopSession{
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

- (void)alertMessage{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有相机权限" message:@"请去设置-隐私-相机中对应用授权" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];
}

- (void)checkAuthorization:(void(^)(BOOL granted))completion{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hasPriority = granted;
            if (!granted) {
                [self alertMessage];
            }
            if (completion) {
                completion(granted);
            }
        });
    }];
}

- (void)loadUI{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"photo_icon_hide" inBundle:[NSBundle bundleWithPath:ZLBundlePath] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButton_pressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchButton setImage:[UIImage imageNamed:@"photo_icon_cut" inBundle:[NSBundle bundleWithPath:ZLBundlePath] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.switchButton addTarget:self action:@selector(switchCameraPosition:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchButton];

    self.noticeLabel = [[UILabel alloc] init];
    self.noticeLabel.font = [UIFont systemFontOfSize:14.0f];
    if (self.photoEnabled && self.videoEnabled) {
        self.noticeLabel.text = @"轻触拍照，按住摄像";
    }
    else if (self.photoEnabled && !self.videoEnabled){
        self.noticeLabel.text = @"轻触拍照";
    }
    else if (!self.photoEnabled && self.videoEnabled){
        self.noticeLabel.text = @"按住摄像";
    }
    self.noticeLabel.textColor = [UIColor whiteColor];
    self.noticeLabel.hidden = !self.photoEnabled;
    [self.view addSubview:self.noticeLabel];
    
    self.snapButton = [[ZLBlurButton alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.snapButton.circleView.layer.cornerRadius = 30;
    self.snapButton.circleView.layer.masksToBounds = YES;
    self.snapButton.layer.cornerRadius = 40;
    self.snapButton.layer.masksToBounds = YES;
    self.snapButton.delegate = self;
    [self.snapButton setSingleClickEnabled:self.photoEnabled];
    [self.snapButton setLongPressEnabled:self.videoEnabled];
    [self.view addSubview:self.snapButton];

    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captureTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    [self.tapGesture setDelaysTouchesEnded: NO];
    [self.view addGestureRecognizer:self.tapGesture];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    self.pinchGesture.delegate = self;
    [self.view addGestureRecognizer:self.pinchGesture];
    
    self.effectiveScale = 1.0f;
    
    [self addDefaultFocusBox];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.snapButton);
        make.right.mas_equalTo(self.snapButton.mas_left).offset(-48);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(28);
    }];
    
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(16);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(28);
    }];

    [self.noticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.snapButton.mas_top).offset(-12);
        make.width.mas_lessThanOrEqualTo(200);
        make.height.mas_equalTo(14);
        make.centerX.mas_equalTo(self.view);
    }];

    [self.snapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-24);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(80);
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    __weak typeof(self)weakSelf = self;
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.delegate captureViewControllerDidDismiss:weakSelf];
    }];
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - ZLPhotoPreviewViewControllerDelegate
- (void)photoPreviewViewController:(ZLPhotoPreviewViewController *)previewViewController didFinishPickImage:(UIImage *)image{
    __weak typeof(self)weakSelf = self;
    self.needStartSession = NO;
    if ([self.delegate respondsToSelector:@selector(captureViewController:didFinishPickImage:)]) {
        [self.delegate captureViewController:self didFinishPickImage:image];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.delegate captureViewControllerDidDismiss:weakSelf];
    }];
}

#pragma mark - ZLVideoPreviewViewControllerDelegate
- (void)videoPreviewViewController:(ZLVideoPreviewViewController *)videoPreviewViewController didFinishPickVideoUrl:(NSURL *)url{
    __weak typeof(self)weakSelf = self;
    self.needStartSession = NO;
    if ([self.delegate respondsToSelector:@selector(captureViewController:didFinishPickVideo:)]) {
        [self.delegate captureViewController:self didFinishPickVideo:url];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.delegate captureViewControllerDidDismiss:weakSelf];
    }];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    ZLVideoPreviewViewController *preViewVC = [[ZLVideoPreviewViewController alloc] init];
    preViewVC.playerUrl = outputFileURL;
    preViewVC.delegate = self;
    [self.navigationController pushViewController:preViewVC animated:YES];
}

#pragma mark - ZLBlurButtonDelegate
- (void)blurButtonPressed:(ZLBlurButton *)button{
    __weak typeof(self)weakSelf = self;
    if (self.photoEnabled) {
        [self.imageOutput captureStillImageAsynchronouslyFromConnection:[self.imageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
            if (error) {
                return ;
            }
            if (imageDataSampleBuffer) {
                NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [UIImage imageWithData:data];
                //当横着拍照片时需要强制设置一下照片方向
                if (weakSelf.currentOrientation == UIDeviceOrientationLandscapeRight) {
                    image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationDown];
                }
                else if (weakSelf.currentOrientation == UIDeviceOrientationLandscapeLeft){
                    image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUp];
                }
                image = [image fixOrientation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf previewWithImage:image];
                });
            }
        }];
    }
}

- (UIImage *)resizeImage:(UIImage *)image{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat scale = MAX(image.size.width / screenWidth, image.size.height / screenHeight);
    CGSize newSize = CGSizeMake(screenWidth *scale, screenHeight * scale);

    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake((image.size.width - newSize.width)/2, (image.size.height - newSize.height)/2, newSize.width, newSize.height));
    UIImage *croppedimage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return croppedimage;
}

- (void)previewWithImage:(UIImage *)image{
    image = [self resizeImage:image];
    if (self.photoEnabled && !self.videoEnabled && self.directEdit) {
        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
        cropViewController.customAspectRatio = self.customAspectRatio;
        cropViewController.aspectRatioLockEnabled = self.aspectRatioLockEnabled;
        cropViewController.aspectRatioPickerButtonHidden = YES;
        cropViewController.delegate = self;
        [self.navigationController pushViewController:cropViewController animated:YES];
    }
    else{
        ZLPhotoPreviewViewController *previewVC = [[ZLPhotoPreviewViewController alloc] init];
        previewVC.image = image;
        previewVC.aspectRatioLockEnabled = self.aspectRatioLockEnabled;
        previewVC.customAspectRatio = self.customAspectRatio;
        previewVC.delegate = self;
        [self.navigationController pushViewController:previewVC animated:YES];
    }
}

#pragma mark - TOCropViewControllerDelegate
- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled{
    [cropViewController.navigationController popViewControllerAnimated:NO];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle{
    if ([self.delegate respondsToSelector:@selector(captureViewController:didFinishPickImage:)]) {
        [self.delegate captureViewController:self didFinishPickImage:image];
    }
    [cropViewController dismissViewControllerAnimated:YES completion:^{

    }];;
}

- (void)blurButtonLongPressed:(ZLBlurButton *)button isStart:(BOOL)isStart{
    __weak typeof(self)weakSelf = self;
    if (isStart) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf.snapButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(102);
                make.height.mas_equalTo(102);
            }];
            
            [weakSelf.snapButton.circleView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(44);
                make.height.mas_equalTo(44);
            }];
            
            weakSelf.snapButton.layer.cornerRadius = 51.0f;
            weakSelf.snapButton.circleView.layer.cornerRadius = 22.0f;
            
            [weakSelf.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [weakSelf startRecord];
        }];
    }
    else{
        [self.snapButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
        }];
        
        [self.snapButton.circleView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(60);
        }];
        
        self.snapButton.layer.cornerRadius = 40.0f;
        self.snapButton.circleView.layer.cornerRadius = 30.0f;
        [self endRecord];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

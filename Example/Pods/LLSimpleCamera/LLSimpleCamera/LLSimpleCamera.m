//
//  CameraViewController.m
//  LLSimpleCamera
//
//  Created by Ömer Faruk Gül on 24/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import "LLSimpleCamera.h"
#import <ImageIO/CGImageProperties.h>
#import "UIImage+FixOrientation.h"

@interface LLSimpleCamera () <AVCaptureFileOutputRecordingDelegate>
@property (strong, nonatomic) UIView *preview;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *videoCaptureDevice;
@property (strong, nonatomic) AVCaptureDevice *audioCaptureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (strong, nonatomic) AVCaptureDeviceInput *audioDeviceInput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) CALayer *focusBoxLayer;
@property (strong, nonatomic) CAAnimation *focusBoxAnimation;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, copy) void (^didRecord)(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error);
@end

NSString *const LLSimpleCameraErrorDomain = @"LLSimpleCameraErrorDomain";

@implementation LLSimpleCamera

- (instancetype)init {
    self = [self initWithVideoEnabled:NO];
    if(self) {
    }
    
    return self;
}

- (instancetype)initWithVideoEnabled:(BOOL)videoEnabled {
    self = [self initWithQuality:AVCaptureSessionPresetHigh position:CameraPositionBack videoEnabled:videoEnabled];
    if(self) {
    }
    
    return self;
}

- (instancetype)initWithQuality:(NSString *)quality position:(CameraPosition)position videoEnabled:(BOOL)videoEnabled {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        _cameraQuality = quality;
        _position = position;
        _fixOrientationAfterCapture = NO;
        _tapToFocus = YES;
        _useDeviceOrientation = NO;
        _flash = CameraFlashOff;
        _videoEnabled = videoEnabled;
        _recording = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    self.preview = [[UIView alloc] initWithFrame:CGRectZero];
    self.preview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.preview];
    
    // tap to focus
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    [self.tapGesture setDelaysTouchesEnded:NO];
    [self.preview addGestureRecognizer:self.tapGesture];
    
    // add focus box to view
    [self addDefaultFocusBox];
}

- (void)addDefaultFocusBox {
    
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

- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation {
    self.focusBoxLayer = layer;
    self.focusBoxAnimation = animation;
}

- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame {
    [vc.view addSubview:self.view];
    [vc addChildViewController:self];
    [self didMoveToParentViewController:vc];
    
    vc.view.frame = frame;
}

# pragma mark Touch Delegate

- (void) previewTapped: (UIGestureRecognizer *) gestureRecognizer
{
    if(!self.tapToFocus) {
        return;
    }
    
    CGPoint touchedPoint = (CGPoint) [gestureRecognizer locationInView:self.preview];
    
    // focus
    CGPoint pointOfInterest = [self convertToPointOfInterestFromViewCoordinates:touchedPoint];
    [self focusAtPoint:pointOfInterest];
    
    // show the box
    [self showFocusBox:touchedPoint];
}

#pragma mark Camera Actions

- (void)start {
    [LLSimpleCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            // request microphone permission if video is enabled
            if(self.videoEnabled) {
                [LLSimpleCamera requestMicrophonePermission:^(BOOL granted) {
                    if(granted) {
                        [self initialize];
                    }
                    else {
                        NSError *error = [NSError errorWithDomain:LLSimpleCameraErrorDomain
                                                             code:LLSimpleCameraErrorCodeMicrophonePermission
                                                         userInfo:nil];
                        if(self.onError) {
                            self.onError(self, error);
                        }
                    }
                }];
            }
            else {
                [self initialize];
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:LLSimpleCameraErrorDomain
                                                 code:LLSimpleCameraErrorCodeCameraPermission
                                             userInfo:nil];
            if(self.onError) {
                self.onError(self, error);
            }
        }
    }];
}

- (void)initialize {
    if(!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = self.cameraQuality;
        
        // preview layer
        CGRect bounds = self.preview.layer.bounds;
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _captureVideoPreviewLayer.bounds = bounds;
        _captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        [self.preview.layer addSublayer:_captureVideoPreviewLayer];
        
        AVCaptureDevicePosition devicePosition;
        switch (self.position) {
            case CameraPositionBack:
                devicePosition = AVCaptureDevicePositionBack;
                break;
            case CameraPositionFront:
                devicePosition = AVCaptureDevicePositionFront;
                break;
            default:
                devicePosition = AVCaptureDevicePositionUnspecified;
                break;
        }
        
        if(devicePosition == AVCaptureDevicePositionUnspecified) {
            _videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        }
        else {
            _videoCaptureDevice = [self cameraWithPosition:devicePosition];
        }
        
        NSError *error = nil;
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoCaptureDevice error:&error];
        
        if (!_videoDeviceInput) {
            if(self.onError) {
                self.onError(self, error);
            }
            return;
        }
        
        if([self.session canAddInput:_videoDeviceInput]) {
            [self.session  addInput:_videoDeviceInput];
        }
        
        // add audio if video is enabled
        if(self.videoEnabled) {
            _audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioCaptureDevice error:&error];
            if (!_audioDeviceInput) {
                if(self.onError) {
                    self.onError(self, error);
                }
            }
        
            if([self.session canAddInput:_audioDeviceInput]) {
                [self.session addInput:_audioDeviceInput];
            }
        
            _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
            if([self.session canAddOutput:_movieFileOutput]) {
                [self.session addOutput:_movieFileOutput];
            }
        }
        
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [self.session addOutput:self.stillImageOutput];
    }
    
    //if we had disabled the connection on capture, re-enable it
    if (![self.captureVideoPreviewLayer.connection isEnabled]) {
        [self.captureVideoPreviewLayer.connection setEnabled:YES];
    }
    
    [self.session startRunning];
}

- (void)stop {
    [self.session stopRunning];
}


#pragma mark Image Methods

-(void)capture:(void (^)(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage {
    
    if(!self.session) {
        NSError *error = [NSError errorWithDomain:LLSimpleCameraErrorDomain
                                    code:LLSimpleCameraErrorCodeSession
                                userInfo:nil];
        onCapture(self, nil, nil, error);
        return;
    }
    
    // get connection and set orientation
    AVCaptureConnection *videoConnection = [self captureConnection];
    videoConnection.videoOrientation = [self orientationForConnection];
    
    // freeze the screen
    [self.captureVideoPreviewLayer.connection setEnabled:NO];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         
         UIImage *image = nil;
         NSDictionary *metadata = nil;
         
         // check if we got the image buffer
         if (imageSampleBuffer != NULL) {
             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if(exifAttachments) {
                 metadata = (__bridge NSDictionary*)exifAttachments;
             }
             
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             image = [[UIImage alloc] initWithData:imageData];
             
             if(exactSeenImage) {
                 image = [self cropImageUsingPreviewBounds:image];
             }
             
             if(self.fixOrientationAfterCapture) {
                 image = [image fixOrientation];
             }
         }
         
         // trigger the block
         if(onCapture) {
             onCapture(self, image, metadata, error);
         }
     }];
}

-(void)capture:(void (^)(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture {
    [self capture:onCapture exactSeenImage:NO];
}

#pragma mark Video Methods

- (void)startRecordingWithOutputUrl:(NSURL *)url {
    
    // check if video is enabled
    if(!self.videoEnabled) {
        NSError *error = [NSError errorWithDomain:LLSimpleCameraErrorDomain
                                             code:LLSimpleCameraErrorCodeVideoNotEnabled
                                         userInfo:nil];
        if(self.onError) {
            self.onError(self, error);
        }
        
        return;
    }
    
    if(self.flash == CameraFlashOn) {
        [self enableTorch:YES];
    }
    [self.movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
}

- (void)stopRecording:(void (^)(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error))completionBlock {
    
    if(!self.videoEnabled) {
        return;
    }
    
    self.didRecord = completionBlock;
    [self.movieFileOutput stopRecording];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    self.recording = YES;
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
    self.recording = NO;
    [self enableTorch:NO];
    
    if(self.didRecord) {
        self.didRecord(self, outputFileURL, error);
    }
}

- (void)enableTorch:(BOOL)enabled {
    // check if the device has a toch, otherwise don't even bother to take any action.
    if([self isTorchAvailable]) {
        [self.session beginConfiguration];
        [self.videoCaptureDevice lockForConfiguration:nil];
        if (enabled) {
            [self.videoCaptureDevice setTorchMode:AVCaptureTorchModeOn];
        } else {
            [self.videoCaptureDevice setTorchMode:AVCaptureTorchModeOff];
        }
        [self.videoCaptureDevice unlockForConfiguration];
        [self.session commitConfiguration];
    }
}

#pragma mark Helper Methods

- (UIImage *)cropImageUsingPreviewBounds:(UIImage *)image {
    
    CGRect previewBounds = self.captureVideoPreviewLayer.bounds;
    CGRect outputRect = [self.captureVideoPreviewLayer metadataOutputRectOfInterestForRect:previewBounds];
    
    CGImageRef takenCGImage = image.CGImage;
    size_t width = CGImageGetWidth(takenCGImage);
    size_t height = CGImageGetHeight(takenCGImage);
    CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height,
                                 outputRect.size.width * width, outputRect.size.height * height);
    
    CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
    image = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:image.imageOrientation];
    CGImageRelease(cropCGImage);
    
    return image;
}

- (AVCaptureConnection *)captureConnection {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    return videoConnection;
}

- (void)setVideoCaptureDevice:(AVCaptureDevice *)videoCaptureDevice {
    _videoCaptureDevice = videoCaptureDevice;
    
    if(videoCaptureDevice.flashMode == AVCaptureFlashModeAuto) {
        _flash = CameraFlashAuto;
    }
    else if(videoCaptureDevice.flashMode == AVCaptureFlashModeOn) {
        _flash = CameraFlashOn;
    }
    else if(videoCaptureDevice.flashMode == AVCaptureFlashModeOff) {
        _flash = CameraFlashOff;
    }
    else {
        _flash = CameraFlashOff;
    }
    
    // trigger block
    if(self.onDeviceChange) {
        self.onDeviceChange(self, videoCaptureDevice);
    }
}

- (BOOL)isFlashAvailable {
    return self.videoCaptureDevice.hasFlash && self.videoCaptureDevice.isFlashAvailable;
}

- (BOOL)isTorchAvailable {
    return self.videoCaptureDevice.hasTorch && self.videoCaptureDevice.isTorchAvailable;
}

- (BOOL)updateFlashMode:(CameraFlash)cameraFlash {
    if(!self.session)
        return NO;
    
    AVCaptureFlashMode flashMode;
    
    if(cameraFlash == CameraFlashOn) {
        flashMode = AVCaptureFlashModeOn;
    }
    else if(cameraFlash == CameraFlashAuto) {
        flashMode = AVCaptureFlashModeAuto;
    }
    else {
        flashMode = AVCaptureFlashModeOff;
    }
    
    
    if([self.videoCaptureDevice isFlashModeSupported:flashMode]) {
        NSError *error;
        if([self.videoCaptureDevice lockForConfiguration:&error]) {
            self.videoCaptureDevice.flashMode = flashMode;
            [self.videoCaptureDevice unlockForConfiguration];
            
            _flash = cameraFlash;
            return YES;
        }
        else {
            if(self.onError) {
                self.onError(self, error);
            }
            return NO;
        }
    }
    else {
        return NO;
    }
}

- (CameraPosition)togglePosition {
    if(!self.session) {
        return self.position;
    }
    
    if(self.position == CameraPositionBack) {
        self.cameraPosition = CameraPositionFront;
    }
    else {
        self.cameraPosition = CameraPositionBack;
    }
    
    return self.position;
}

- (void)setCameraPosition:(CameraPosition)cameraPosition
{
    if(_position == cameraPosition || !self.session) {
        return;
    }
    
    [self.session beginConfiguration];
    
    // remove existing input
    [self.session removeInput:self.videoDeviceInput];
    
    // get new input
    AVCaptureDevice *device = nil;
    if(self.videoDeviceInput.device.position == AVCaptureDevicePositionBack) {
        device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }
    else {
        device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    
    if(!device) {
        return;
    }
    
    // add input to session
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if(error) {
        if(self.onError) {
            self.onError(self, error);
        }
        [self.session commitConfiguration];
        return;
    }
    
    _position = cameraPosition;
    
    [self.session addInput:videoInput];
    [self.session commitConfiguration];
    
    self.videoCaptureDevice = device;
    self.videoDeviceInput = videoInput;
}


// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) return device;
    }
    return nil;
}

#pragma mark Focus

- (void) focusAtPoint:(CGPoint)point
{
    //NSLog(@"Focusing at point %@", NSStringFromCGPoint(point));
    
    AVCaptureDevice *device = self.videoCaptureDevice;
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        
        if(error && self.onError) {
            self.onError(self, error);
        }
    }
}

- (void)showFocusBox:(CGPoint)point {
    
    if(self.focusBoxLayer) {
        // clear animations
        [self.focusBoxLayer removeAllAnimations];
        
        // move layer to the touc point
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

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    AVCaptureVideoPreviewLayer *previewLayer = self.captureVideoPreviewLayer;
    
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = previewLayer.frame.size;
    
    if ( [previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize] ) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [self.videoDeviceInput ports]) {
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


#pragma mark - Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
//    NSLog(@"layout cameraVC : %d", self.interfaceOrientation);
    
    self.preview.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    CGRect bounds = self.preview.bounds;
    self.captureVideoPreviewLayer.bounds = bounds;
    self.captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    self.captureVideoPreviewLayer.connection.videoOrientation = [self orientationForConnection];
}

- (AVCaptureVideoOrientation)orientationForConnection
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    
    if(self.useDeviceOrientation) {
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationLandscapeLeft:
                // yes we to the right, this is not bug!
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    else {
        switch (self.interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    
    return videoOrientation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark static methods

+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock {
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    } else {
        completionBlock(YES);
    }
    
}

+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock {
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    }
}

@end
//
//  CameraViewController.h
//  LLSimpleCamera
//
//  Created by Ömer Faruk Gül on 24/10/14.
//  Copyright (c) 2014 Ömer Farul Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    CameraPositionBack,
    CameraPositionFront
} CameraPosition;

typedef enum : NSUInteger {
    // The default state has to be off
    CameraFlashOff,
    CameraFlashOn,
    CameraFlashAuto
} CameraFlash;

extern NSString *const LLSimpleCameraErrorDomain;
typedef enum : NSUInteger {
    LLSimpleCameraErrorCodeCameraPermission = 10,
    LLSimpleCameraErrorCodeMicrophonePermission = 11,
    LLSimpleCameraErrorCodeSession = 12,
    LLSimpleCameraErrorCodeVideoNotEnabled = 13
} LLSimpleCameraErrorCode;

@interface LLSimpleCamera : UIViewController

/**
 * Triggered on device change.
 */
@property (nonatomic, copy) void (^onDeviceChange)(LLSimpleCamera *camera, AVCaptureDevice *device);

/**
 * Triggered on any kind of error.
 */
@property (nonatomic, copy) void (^onError)(LLSimpleCamera *camera, NSError *error);

/**
 * Camera quality, set a constants prefixed with AVCaptureSessionPreset.
 * Make sure to call before calling -(void)initialize method, otherwise it would be late.
 */
@property (copy, nonatomic) NSString *cameraQuality;

/**
 * Camera flash mode.
 */
@property (nonatomic, readonly) CameraFlash flash;

/**
 * Position of the camera.
 */
@property (nonatomic) CameraPosition position;

/**
 * Boolean value to indicate if the video is enabled.
 */
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/**
 * Boolean value to indicate if the camera is recording a video at the current moment.
 */
@property (nonatomic, getter=isRecording) BOOL recording;

/**
 * Fixess the orientation after the image is captured is set to Yes.
 * see: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
 */
@property (nonatomic) BOOL fixOrientationAfterCapture;

/**
 * Set NO if you don't want ot enable user triggered focusing. Enabled by default.
 */
@property (nonatomic) BOOL tapToFocus;

/**
 * Set YES if you your view controller does not allow autorotation,
 * however you want to take the device rotation into account no matter what. Disabled by default.
 */
@property (nonatomic) BOOL useDeviceOrientation;

/**
 * Use this method to request camera permission before initalizing LLSimpleCamera.
 */
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock;

/**
 * Use this method to request microphone permission before initalizing LLSimpleCamera.
 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock;

/**
 * Returns an instance of LLSimpleCamera with the given quality.
 * Quality parameter could be any variable starting with AVCaptureSessionPreset.
 */
- (instancetype)initWithQuality:(NSString *)quality position:(CameraPosition)position videoEnabled:(BOOL)videoEnabled;

/**
 * Returns an instance of LLSimpleCamera with quality "AVCaptureSessionPresetHigh" and position "CameraPositionBack".
 * @param videEnabled: Set to YES to enable video recording.
 */
- (instancetype)initWithVideoEnabled:(BOOL)videoEnabled;

/**
 * Starts running the camera session.
 */
- (void)start;

/**
 * Stops the running camera session. Needs to be called when the app doesn't show the view.
 */
- (void)stop;

/**
 * Capture an image.
 * @param onCapture a block triggered after the capturing the photo.
 * @param exactSeenImage If set YES, then the image is cropped to the exact size as the preview. So you get exactly what you see.
 */
-(void)capture:(void (^)(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage;

/**
 * Capture an image.
 * @param onCapture a block triggered after the capturing the photo.
 */
-(void)capture:(void (^)(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture;

/*
 * Start recording a video. Video is saved to the given url.
 */
- (void)startRecordingWithOutputUrl:(NSURL *)url;

/**
 * Stop recording video with a completion block.
 */
- (void)stopRecording:(void (^)(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error))completionBlock;

/**
 * Attaches the LLSimpleCamera to another view controller with a frame. It basically adds the LLSimpleCamera as a
 * child vc to the given vc.
 * @param vc A view controller.
 * @param frame The frame of the camera.
 */
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame;

/**
 * Changes the posiition of the camera (either back or front) and returns the final position.
 */
- (CameraPosition)togglePosition;

/**
 * Update the flash mode of the camera. Returns true if it is successful. Otherwise false.
 */
- (BOOL)updateFlashMode:(CameraFlash)cameraFlash;

/**
 * Checks if flash is avilable for the currently active device.
 */
- (BOOL)isFlashAvailable;

/**
 * Checks if torch (flash for video) is avilable for the currently active device.
 */
- (BOOL)isTorchAvailable;

/**
 * Alter the layer and the animation displayed when the user taps on screen.
 * @param layer Layer to be displayed
 * @param animation to be applied after the layer is shown
 */
- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;

@end

# LLSimpleCamera: A simple customizable camera - video recorder control

![Screenshot](https://raw.githubusercontent.com/omergul123/LLSimpleCamera/master/screenshot.png)

LLSimpleCamera is a library for creating a customized camera - video recorder screens similar to snapchat's. You don't have to present the camera in a new view controller.

###LLSimpleCamera:###
* lets you easily capture photos and record videos (finally)
* handles the position and flash of the camera
* hides the nitty gritty details from the developer
* doesn't have to be presented in a new modal view controller, simply can be embedded inside any of your VCs. (like Snapchat)

## Install

pod 'LLSimpleCamera', '~> 3.0'

## Example usage

Initialize the LLSimpleCamera
````
CGRect screenRect = [[UIScreen mainScreen] bounds];

// create camera with standard settings
self.camera = [[LLSimpleCamera alloc] init];

// camera with video recording capability
self.camera =  [[LLSimpleCamera alloc] nitWithVideoEnabled:YES];

// camera with precise quality, position and video parameters.
self.camera = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh
                                             position:CameraPositionBack
                                         videoEnabled:YES];
// attach to the view
[self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];

````

To capture a photo:
````
// capture
[self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
    if(!error) {    
        // we should stop the camera, since we don't need it anymore. We will open a new vc.
        // this very important, otherwise you may experience memory crashes
        [camera stop];
            
        // show the image
        ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];
        [self presentViewController:imageVC animated:NO completion:nil];
       }
}];
````

To start recording a video:
````
// start recording
NSURL *outputURL = [[[self applicationDocumentsDirectory]
                     URLByAppendingPathComponent:@"test1"] URLByAppendingPathExtension:@"mov"];
[self.camera startRecordingWithOutputUrl:outputURL];
````

To stop recording the video:
````
[self.camera stopRecording:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
    VideoViewController *vc = [[VideoViewController alloc] initWithVideoUrl:outputFileUrl];
    [self.navigationController pushViewController:vc animated:YES];
}];
````

Changing the focus layer and animation:
````
- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;
````

## Adding the camera controls

You have to add your own camera controls (flash, camera switch etc). Simply add the controls to the view where LLSimpleCamera is attached to. You can see a full camera example in the example project. Download and try it on your device.

## Stopping and restarting the camera

You should never forget to stop the camera either after the capture block is triggered, or inside somewhere **-viewWillDisappear** of the parent controller to make sure that the app doesn't use the camera when it is not needed. You can call **-start()** to reuse the camera. So it may be good idea to to place **-start()** inside **-viewWillAppear** or in another relevant method.

## Contact

Ömer Faruk Gül

[Personal Site][2]
omer@omerfarukgul.com

 [2]: http://omerfarukgul.com

 ## Version History ##

 #### Version 2.2.0
- camera permissions are supported, if the permission is not given by the user, onError will be triggered.
- camera flash methods are altered. Now you have to call **- (BOOL)updateFlashMode:(CameraFlash)cameraFlash;**
- cameraFlash and cameraPosition property names are simplified to: **flash** and **position**.
- added support for device orientation in case your vc orientation is locked but you want to use the device orientation no matter what.

#### Version 2.1.1
- freezing the screen just after the photo is taken for better user experience.

#### Version 2.1.0
- added an extra parameter exactSeenImage:(BOOL)exactSeenImage to -capture method to easily get the exact seen image on the screen instead of the raw uncropped image. The default value is NO.
- fixed an orientation bug inside capture method.

#### Version 2.0.0
Some significant changes have been made at both internal structure and  api.
- added tap to focus feature (it is fully customizable, if you don't like the default layer and animation)
- removed delegates and added blocks
- interface is significantly improved

#### Version 1.1.1
- fixed a potential crash scenario if -stop() is called multiple times

#### Version 1.1.0
- fixed a problem that sometimes caused a crash after capturing a photo.
- improved code structure, didChangeDevice delegate is now also triggered for the first default device.





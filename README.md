![alt text](https://cloud.githubusercontent.com/assets/4034956/4519852/caadef06-4ccd-11e4-98f3-287ad6ee05db.gif "Demo gif")

A mix between the native iOS 7 gallery and facebooks image picker.

# Install
## Pod
Put this into your Podfile:
```shell
pod 'BSImagePicker', '~> 0.7'
```
# Use
Import header
```objc
#import <BSImagePickerController/BSImagePickerController.h>
```

Present the image picker from a view controller
```objc
[self presentImagePickerController:anImagePicker
                          animated:YES
                        completion:nil
                            toggle:^(ALAsset *asset, BOOL select) {
                                if(select) {
                                    NSLog(@"Image selected");
                                } else {
                                    NSLog(@"Image deselected");
                                }
                            }
                            cancel:^(NSArray *assets) {
                                NSLog(@"User canceled...!");
                            } finish:^(NSArray *assets) {
                                NSLog(@"User finished :)!");
                            }];
```
All blocks are optional and can be nil, so you could for an instance just handle the finish case if you wanted. Why the toggle block then? Well, in my case I use it for starting image upload to give the apperance of a faster upload (many times it has already finished when user presses done.
* Toggle get called with an ALAsset and a BOOL indicating if it was selected or deselected.
* cancel gets called when the user cancels. It will have an array of ALAssets (if any).
* finish gets called when the user finishes. It will have an array of ALAssets (if any).

Blocks are always called on the main thread.

### Customize (see BSImagePickerController.h)
* You can disable previews by setting previewDisabled to YES.
* Setting keepSelection to YES will keep your image selection after dismissing the controller.
* Set maximumNumberOfImages to a value to limit selection to a certain number of images.
* Set itemSize to change the size of photos and albums.
* Tint color will change colors on buttons, album checkmark and photo checkmark.
* Navigation bar tint color will also affect the album view.
* Navigation bar foreground color will also affect text color in album cells.

##### Example
This will give you a dark picker
```objc
[anImagePicker.view setTintColor:[UIColor redColor]];
[anImagePicker.navigationBar setBarTintColor:[UIColor blackColor]];
[anImagePicker.view setBackgroundColor:[UIColor blackColor]];
[anImagePicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
```

# License
MIT License (see LICENSE file)

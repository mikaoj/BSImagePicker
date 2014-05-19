![alt text](https://cloud.githubusercontent.com/assets/4034956/2754014/8dde8a08-c948-11e3-8a48-2e8be82d63b1.gif "Demo gif")

A mix between the native iOS 7 gallery and facebooks image picker.

# Install
## Pod
Put this into your Podfile:
```shell
pod 'BSImagePicker', '~> 0.1'
```
## Framework
### Download framework
[Download the framework](https://github.com/mikaoj/BSImagePicker/releases/download/0.1/BSImagePickerController.framework.zip "framework") and drop into your project.
### Or build it yourself
* Clone project
```shell
git clone git@bitbucket.org:backslashed/bsimagepicker.git
```
* Build framework
```shell
cd bsimagepicker
xcodebuild  -target BuildFramework
open -a Finder Products/
```
* Drag & Drop framework into your project

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
All blocks are optional and can be nil, so you could for an istance just handle the finish case if you wanted.
* Toggle get called with an ALAsset and a BOOL indicating if it was selected or deselected.
* cancel gets called when the user cancels. It will have an array of ALAssets (if any).
* finish gets called when the user finishes. It will have an array of ALAssets (if any).

Blocks are always called on the main thread.

### Customization (view BSImagePickerController.h to see all properties you can set)
* You can disable previews by setting previewDisabled to YES.
* Setting keepSelection to YES will keep your image selection after dismissing the controller.
* Set maximumNumberOfImages to a value to limit selection to a certain number of images.
* Set itemSize to change the size of photos and albums.
* Tint color will change colors on buttons, album checkmark and photo checkmark.
* Navigation bar tint color will also affect the album view.
* Navigation bar foreground color will also affect text color in album cells.

##### Example
```objc
[anImagePicker.view setTintColor:[UIColor redColor]];
[anImagePicker.navigationBar setBarTintColor:[UIColor blackColor]];
[anImagePicker.view setBackgroundColor:[UIColor blackColor]];
[anImagePicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
```
![alt text](https://cloud.githubusercontent.com/assets/4034956/2754017/9733c9ec-c948-11e3-932c-f2642526ae3c.png "Color demo gif")![alt text](https://cloud.githubusercontent.com/assets/4034956/2754018/9733d41e-c948-11e3-9cf5-a4b0cb0c8d9e.png "Color demo gif")![alt text](https://cloud.githubusercontent.com/assets/4034956/2754019/97341cf8-c948-11e3-8578-d876d1f3db0c.png "Color demo gif")
# TODO's
* Edit - support for editing images in the preview view
* Movies - for now only images are supported. Add support for movies as well

# License
The MIT License (MIT)

Copyright (c) 2014 Joakim Gyllström

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

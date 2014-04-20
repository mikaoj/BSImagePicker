![alt text](https://bitbucket.org/backslashed/bsimagepicker/downloads/demo.gif "Demo gif")

A mix between the native iOS 7 gallery and facebooks image picker.
# Note
This is still in pre-alpha stage. There are known bugs and features that needs to be implemented for "production" use. See TODO section.
# Install
### Download framework
[Download the framework](https://bitbucket.org/backslashed/bsimagepicker/downloads/BSImagePickerController.framework.zip "framework") and drop into your project.
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
### Cocoapods
INSERT COCOAPODS DESCRIPTION HERE
### Source
INSERT DESCRIPTION HERE
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
                            toggle:^(NSDictionary *info, BOOL select) {
                                if(select) {
                                    NSLog(@"Image selected");
                                } else {
                                    NSLog(@"Image deselected");
                                }
                            }
                             reset:^(NSArray *infoArray, BSImageReset reset) {
                                 switch (reset) {
									 //Selection gets reset after these actions
                                     case BSImageResetCancel:
                                         NSLog(@"Image picker canceled");
                                         break;
                                     case BSImageResetAlbum:
                                         NSLog(@"Image picker changed album");
                                         break;
                                     case BSImageResetDone:
                                         NSLog(@"Image picker done");
                                         break;
                                 }
                             }];
```
# TODO's
* Handle rotation - rotating the device will mess things up.
* iPad - not tested on an iPad, probably needs some tweaking
* Edit - support for editing images in the preview view
* Movies - for now only images are supported. Add support for movies as well
* Performance - probably needs some tweaking to make it fly :)
* Customization - support for customization, sizes, colors, etc
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

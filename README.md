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
* iPad - not tested on the iPad
* Edit - support for editing images in the preview view
* Movies - for now only images are supported. Add support for movies as well
* Performance - probably needs some tweaking to make it fly :)
* Customization - support for customization, sizes, colors, etc
# License
MIT License
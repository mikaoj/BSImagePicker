# Showcase
A mix between the native iOS 7 gallery and facebooks image picker.
![alt text](/path/img.jpg "Title")
# Note
This is still in alpha stage. There are known bugs and stuff that needs to be implemented for "production" use. See TODO section.
# Install
### Framework
Download the framework INSERT LINK and drop into your project.
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
                            toggle:^(NSDictionary *info, BOOL selected) {
                                if(selected) {
                                    NSLog(@"Handle selection");
                                } else {
                                    NSLog(@"Handle deselection");
                                }
                            } finish:^(NSArray *infoArray, BOOL canceled) {
                                if(canceled) {
                                    NSLog(@"Handle canceled");
                                } else {
                                    NSLog(@"Handle done");
                                }
                            }];
```
# TODO's
* Handle rotation
* iPad
* Edit
* Movies
* Performance
* Customization
# License
MIT License
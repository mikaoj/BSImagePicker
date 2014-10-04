// The MIT License (MIT)
//
// Copyright (c) 2014 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "UIViewController+BSImagePicker.h"
#import "BSImagePickerController.h"

@implementation UIViewController (BSImagePicker)

- (void)presentImagePickerController:(BSImagePickerController *)viewControllerToPresent
                            animated:(BOOL)flag
                          completion:(void (^)(void))completion
                              toggle:(BSImageToggleBlock)toggleBlock
                              cancel:(BSImageGroupBlock)cancelBlock
                              finish:(BSImageGroupBlock)finishBlock
{
    if([viewControllerToPresent isKindOfClass:[BSImagePickerController class]]) {
        [viewControllerToPresent setToggleBlock:toggleBlock];
        [viewControllerToPresent setCancelBlock:cancelBlock];
        [viewControllerToPresent setFinishBlock:finishBlock];
    }
    
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end

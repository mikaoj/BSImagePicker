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

#import <UIKit/UIKit.h>

@class ALAsset;
typedef NS_ENUM(NSInteger, BSImageReset) {
    BSImageResetCancel,
    BSImageResetDone
};

typedef void (^BSImageToggleBlock)(ALAsset *asset, BOOL select);
typedef void (^BSImageResetBlock)(NSArray *assets, BSImageReset reset);

@class BSImagePickerController;
@interface UIViewController (MultipleImagePicker)

/**
 *  Present image picker controller (wrapper around presentViewController)
 *
 *  @param viewControllerToPresent A BSImagePickerController to present
 *  @param flag                    Present with animation or not
 *  @param completion              Presention completion handler or nil
 *  @param toggle                  Image toggle handler block (select/deselect) or nil
 *  @param reset                   Image reset handler block (cancel/album change/done) or nil
 *  @discussion Blocks will allways be called on the main thread
 */
- (void)presentImagePickerController:(BSImagePickerController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion toggle:(BSImageToggleBlock)toggle reset:(BSImageResetBlock)reset;

@end

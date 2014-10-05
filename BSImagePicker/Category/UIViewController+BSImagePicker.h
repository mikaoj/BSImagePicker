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

typedef NS_OPTIONS(NSInteger, BSAssetType) {
    BSAssetTypeImage = 1 << 0,
    BSAssetTypeVideo = 1 << 1
};

typedef void (^BSImageToggleBlock)(ALAsset *asset, BOOL select);
typedef void (^BSImageGroupBlock)(NSArray *assets);

@class BSImagePickerController;
@interface UIViewController (BSImagePicker)

/**
 *  Present image picker controller (wrapper around presentViewController)
 *
 *  @param viewControllerToPresent A BSImagePickerController to present
 *  @param flag                    Present with animation or not
 *  @param completion              Presention completion handler or nil
 *  @param toggle                  Image toggle handler block (select/deselect) or nil
 *  @param cancelBlock             Block that gets called when user cancels, contains assets that was selected when user canceled. Can be nil
 *  @param finishBlock             Block that gets called when user finishes, contains asset that was selected when user finished. Can be nil
*  @discussion Blocks will allways be called on the main thread
 */
- (void)presentImagePickerController:(BSImagePickerController *)viewControllerToPresent
                            animated:(BOOL)flag
                          completion:(void (^)(void))completion
                              toggle:(BSImageToggleBlock)toggleBlock
                              cancel:(BSImageGroupBlock)cancelBlock
                              finish:(BSImageGroupBlock)finishBlock;

@end

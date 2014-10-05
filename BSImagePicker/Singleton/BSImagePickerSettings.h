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

@interface BSImagePickerSettings : NSObject

+ (instancetype)sharedSetting;

/**
 *  Defaults to NSUIntegerMax (i.e shitloads of images)
 */
@property (nonatomic, assign) NSUInteger maximumNumberOfImages;

/**
 *  Block that gets called on select/deselect
 */
@property (nonatomic, copy) BSImageToggleBlock toggleBlock;

/**
 *  Block that gets called on cancel
 */
@property (nonatomic, copy) BSImageGroupBlock cancelBlock;

/**
 *  Block that gets called on finish
 */
@property (nonatomic, copy) BSImageGroupBlock finishBlock;

/**
 * What types of assets you want the picker to handle
 */
@property (nonatomic, assign) BSAssetType assetType;

/**
 *  Set to YES to disable preview on long press
 */
@property (nonatomic, assign) BOOL previewDisabled;

/**
 *  Set to YES to disable edit mode in preview.
 *  This isn't supported yet. Placeholder for future feature :)
 */
@property (nonatomic, assign) BOOL disableEdit;

/**
 *  Set this to customize the size of items (photos and albums)
 */
@property (nonatomic, assign) CGSize itemSize;

/**
 * Set this to yes to keep selection after close
 */
@property (nonatomic, assign) BOOL keepSelection;

/**
 * Background tint color for the album view. If nil it will match the navigationbar color.
 */
@property (nonatomic, strong) UIColor *albumTintColor;

@end

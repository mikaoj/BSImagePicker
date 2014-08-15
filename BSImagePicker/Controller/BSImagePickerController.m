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

#import "BSImagePickerController.h"
#import "BSPhotosController.h"
#import "BSImagePickerSettings.h"

@interface BSImagePickerController ()

@property (nonatomic, strong) BSPhotosController *imagePicker;

@end

@implementation BSImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self pushViewController:self.imagePicker animated:NO];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.imagePicker.collectionView reloadData];
}

#pragma mark - Lazy load

- (BSPhotosController *)imagePicker {
    if(!_imagePicker) {
        _imagePicker = [[BSPhotosController alloc] init];
    }
    
    return _imagePicker;
}

#pragma mark - Settings forward

- (NSUInteger)maximumNumberOfImages {
    return [[BSImagePickerSettings sharedSetting] maximumNumberOfImages];
}

- (void)setMaximumNumberOfImages:(NSUInteger)maximumNumberOfImages {
    [[BSImagePickerSettings sharedSetting] setMaximumNumberOfImages:maximumNumberOfImages];
}

- (BSImageToggleBlock)toggleBlock {
    return [[BSImagePickerSettings sharedSetting] toggleBlock];
}

- (void)setToggleBlock:(BSImageToggleBlock)toggleBlock {
    [[BSImagePickerSettings sharedSetting] setToggleBlock:toggleBlock];
}

- (BSImageGroupBlock)cancelBlock {
    return [[BSImagePickerSettings sharedSetting] cancelBlock];
}

- (void)setCancelBlock:(BSImageGroupBlock)cancelBlock {
    [[BSImagePickerSettings sharedSetting] setCancelBlock:cancelBlock];
}

- (BSImageGroupBlock)finishBlock {
    return [[BSImagePickerSettings sharedSetting] finishBlock];
}

- (void)setFinishBlock:(BSImageGroupBlock)finishBlock {
    [[BSImagePickerSettings sharedSetting] setFinishBlock:finishBlock];
}

- (BSAssetType)assetType {
    return [[BSImagePickerSettings sharedSetting] assetType];
}

- (void)setAssetType:(BSAssetType)assetType {
    [[BSImagePickerSettings sharedSetting] setAssetType:assetType];
}

- (BOOL)previewDisabled {
    return [[BSImagePickerSettings sharedSetting] previewDisabled];
}

- (void)setPreviewDisabled:(BOOL)previewDisabled {
    [[BSImagePickerSettings sharedSetting] setPreviewDisabled:previewDisabled];
}

- (BOOL)disableEdit {
    return [[BSImagePickerSettings sharedSetting] disableEdit];
}

- (void)setDisableEdit:(BOOL)disableEdit {
    [[BSImagePickerSettings sharedSetting] setDisableEdit:disableEdit];
}

- (CGSize)itemSize {
    return [[BSImagePickerSettings sharedSetting] itemSize];
}

- (void)setItemSize:(CGSize)itemSize {
    [[BSImagePickerSettings sharedSetting] setItemSize:itemSize];
}

- (BOOL)keepSelection {
    return [[BSImagePickerSettings sharedSetting] keepSelection];
}

- (void)setKeepSelection:(BOOL)keepSelection {
    [[BSImagePickerSettings sharedSetting] setKeepSelection:keepSelection];
}

- (UIColor *)albumTintColor {
    return [[BSImagePickerSettings sharedSetting] albumTintColor];
}

- (void)setAlbumTintColor:(UIColor *)albumTintColor {
    [[BSImagePickerSettings sharedSetting] setAlbumTintColor:albumTintColor];
}

@end

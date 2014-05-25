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
#import "BSImageSelectionController.h"
#import "BSNewPhotosController.h"

@interface BSImagePickerController ()

@property (nonatomic, strong) BSImageSelectionController *imagePicker;
@property (nonatomic, strong) BSNewPhotosController *newImagePicker;

@end

@implementation BSImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
//        [self pushViewController:self.imagePicker animated:NO];
        [self pushViewController:self.newImagePicker animated:NO];
    }
    return self;
}

- (BSImagePickerSettings *)settings {
    return [BSImagePickerSettings sharedSetting];
}

#pragma mark - Lazy load

- (BSImageSelectionController *)imagePicker
{
    if(!_imagePicker) {
        _imagePicker = [[BSImageSelectionController alloc] init];
    }
    
    return _imagePicker;
}

- (BSNewPhotosController *)newImagePicker {
    if(!_newImagePicker) {
        _newImagePicker = [[BSNewPhotosController alloc] init];
    }
    
    return _newImagePicker;
}

@end

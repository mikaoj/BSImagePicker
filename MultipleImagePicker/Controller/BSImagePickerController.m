//
//  BSImagePickerController.m
//  MultipleImagePicker
//
//  Created by Joakim Gyllström on 2014-04-13.
//  Copyright (c) 2014 Joakim Gyllström. All rights reserved.
//

#import "BSImagePickerController.h"
#import "BSImageSelectionController.h"

@interface BSImagePickerController ()

@property (nonatomic, strong) BSImageSelectionController *imagePicker;

@end

@implementation BSImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Default to shitloads of images
        _maximumNumberOfImages = NSUIntegerMax;
        
        [self pushViewController:self.imagePicker animated:NO];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [self setImagePicker:nil];
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Lazy load

- (BSImageSelectionController *)imagePicker
{
    if(!_imagePicker) {
        _imagePicker = [[BSImageSelectionController alloc] init];
    }
    
    return _imagePicker;
}

@end

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

@end

@implementation BSImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Default to shitloads of images
        _maximumNumberOfImages = NSUIntegerMax;
        
        BSImageSelectionController *imagePicker = [[BSImageSelectionController alloc] init];
        
        [self pushViewController:imagePicker animated:NO];
    }
    return self;
}

@end
